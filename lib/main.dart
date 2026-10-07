import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testora_flutter_ui/core/router/app_router.dart';
import 'package:testora_flutter_ui/core/theme/app_theme.dart';
import 'package:testora_flutter_ui/core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TestoraApp()));
}

class TestoraApp extends ConsumerWidget {
  const TestoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Testora',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
