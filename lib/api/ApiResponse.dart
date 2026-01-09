class ApiResponse<T> {
  final bool success;
  final T? data;
  final T? error;
  final int? statusCode;

  ApiResponse.success(this.data, {this.statusCode})
      : success = true,
        error = null;

  ApiResponse.error(this.error, {this.statusCode})
      : success = false,
        data = null;
}


