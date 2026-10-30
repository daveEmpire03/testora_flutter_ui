export type ApiErrorStatus =
  | 400
  | 401
  | 403
  | 404
  | 409
  | 413
  | 422
  | 500
  | 502
  | 503;

export class AppError extends Error {
  constructor(
    readonly status: ApiErrorStatus,
    readonly code: string,
    readonly publicMessage: string,
  ) {
    super(publicMessage);
    this.name = "AppError";
  }
}
