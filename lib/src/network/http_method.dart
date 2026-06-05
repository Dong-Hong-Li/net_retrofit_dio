/// HTTP methods.
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
  head;

  String get string {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.head:
        return 'HEAD';
    }
  }
}
