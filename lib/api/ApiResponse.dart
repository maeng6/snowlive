class ApiResponse<T> {
  final bool success;
  final T? data;
  final T? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.error(this.error)
      : success = false,
        data = null;
}


