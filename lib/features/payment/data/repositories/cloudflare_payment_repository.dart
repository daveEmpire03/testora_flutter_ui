import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/payment_transaction.dart';
import '../../domain/entities/user_entitlement.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_transaction_model.dart';
import '../models/user_entitlement_model.dart';

class CloudflarePaymentRepository implements PaymentRepository {
  CloudflarePaymentRepository({
    required FirebaseAuth firebaseAuth,
    required Dio dio,
  }) : _firebaseAuth = firebaseAuth,
       _dio = dio;

  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  @override
  Future<PaymentTransaction> initializeCheckout({
    required String packageId,
  }) async {
    final data = await _authenticatedDataRequest(
      (options) => _dio.post<dynamic>(
        'payments/initialize',
        data: {'packageId': packageId},
        options: options,
      ),
    );

    final transaction = _parseTransaction(data);
    final checkoutUri = Uri.tryParse(transaction.authorizationUrl ?? '');
    if (checkoutUri == null ||
        checkoutUri.scheme != 'https' ||
        checkoutUri.host != 'checkout.paystack.com') {
      throw const PaymentRepositoryException(
        'Paystack returned an invalid checkout link. Please try again.',
      );
    }

    return transaction;
  }

  @override
  Future<PaymentTransaction> getPaymentStatus({
    required String reference,
  }) async {
    final encodedReference = Uri.encodeComponent(reference);
    final data = await _authenticatedDataRequest(
      (options) => _dio.get<dynamic>(
        'payments/$encodedReference/status',
        options: options,
      ),
    );

    return _parseTransaction(data);
  }

  @override
  Future<PaymentTransaction> verifyPayment({
    required String reference,
  }) async {
    final encodedReference = Uri.encodeComponent(reference);
    final data = await _authenticatedDataRequest(
      (options) => _dio.post<dynamic>(
        'payments/$encodedReference/verify',
        options: options,
      ),
    );

    return _parseTransaction(data);
  }

  @override
  Future<bool> hasActiveEntitlement({
    required String packageId,
  }) async {
    final encodedPackageId = Uri.encodeComponent(packageId);
    final data = await _authenticatedDataRequest(
      (options) => _dio.get<dynamic>(
        'entitlements/$encodedPackageId',
        options: options,
      ),
    );

    final entitled = data['entitled'];
    if (entitled is! bool) {
      throw const PaymentRepositoryException(
        'The access service returned an invalid response. Please retry.',
      );
    }

    return entitled;
  }

  @override
  Future<List<PaymentTransaction>> getPaymentHistory() async {
    final records = await _authenticatedListRequest('payments/history');
    return records.map(_parseTransaction).toList(growable: false);
  }

  @override
  Future<List<UserEntitlement>> getUserEntitlements() async {
    final records = await _authenticatedListRequest('entitlements');

    try {
      return records
          .map(
            (record) => UserEntitlementModel.fromJson(record).toEntity(),
          )
          .toList(growable: false);
    } on FormatException {
      throw const PaymentRepositoryException(
        'The access service returned an invalid response. Please retry.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _authenticatedListRequest(
    String path,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const PaymentRepositoryException(
        'Please sign in to view your account information.',
      );
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw const PaymentRepositoryException(
          'Your sign-in session could not be verified. Please sign in again.',
        );
      }

      final response = await _dio.get<dynamic>(
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      final body = response.data;
      if (body is! Map || body['data'] is! List) {
        throw const PaymentRepositoryException(
          'The service returned an invalid response. Please retry.',
        );
      }

      final data = body['data'] as List;
      if (data.any((item) => item is! Map)) {
        throw const PaymentRepositoryException(
          'The service returned an invalid response. Please retry.',
        );
      }

      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    } on DioException catch (error) {
      throw PaymentRepositoryException(_messageFor(error));
    } on FirebaseAuthException {
      throw const PaymentRepositoryException(
        'Your sign-in session could not be verified. Please sign in again.',
      );
    } on TypeError {
      throw const PaymentRepositoryException(
        'The service returned an invalid response. Please retry.',
      );
    }
  }

  Future<Map<String, dynamic>> _authenticatedDataRequest(
    Future<Response<dynamic>> Function(Options options) request,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const PaymentRepositoryException(
        'Please sign in again before continuing with payment.',
      );
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw const PaymentRepositoryException(
          'Your sign-in session could not be verified. Please sign in again.',
        );
      }

      final response = await request(
        Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      final body = response.data;
      if (body is! Map) {
        throw const PaymentRepositoryException(
          'The payment service returned an invalid response. Please retry.',
        );
      }

      final data = body['data'];
      if (data is! Map) {
        throw const PaymentRepositoryException(
          'The payment service returned an invalid response. Please retry.',
        );
      }

      return Map<String, dynamic>.from(data);
    } on DioException catch (error) {
      throw PaymentRepositoryException(_messageFor(error));
    } on FirebaseAuthException {
      throw const PaymentRepositoryException(
        'Your sign-in session could not be verified. Please sign in again.',
      );
    } on TypeError {
      throw const PaymentRepositoryException(
        'The payment service returned an invalid response. Please retry.',
      );
    }
  }

  PaymentTransaction _parseTransaction(Map<String, dynamic> data) {
    try {
      return PaymentTransactionModel.fromJson(data).toEntity();
    } on FormatException {
      throw const PaymentRepositoryException(
        'The payment service returned an invalid transaction. Please retry.',
      );
    }
  }

  String _messageFor(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final errorBody = responseData['error'];
      if (errorBody is Map && errorBody['message'] is String) {
        return errorBody['message'] as String;
      }
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return 'Your sign-in session has expired. Please sign in again.';
    }
    if (statusCode == 503 || statusCode == 502) {
      return 'The payment service is temporarily unavailable. Please try again.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Unable to reach Testora. Check your internet connection and try again.';
    }

    return 'We could not complete this payment request. Please try again.';
  }
}
