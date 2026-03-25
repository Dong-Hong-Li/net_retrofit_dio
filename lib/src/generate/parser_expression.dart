// No external dependencies. Used by both generator and tests.

bool _hasSpaceAroundAngleBrackets(String s) {
  return s.contains(' <') ||
      s.contains('< ') ||
      s.contains(' >') ||
      s.contains('> ');
}

/// Builds a `return ...;` from [response] (Dio [Response]) for the API return type.
String buildReturnStatementFromResponse(
  String returnTypeName,
  String? dataPath,
) {
  const primitives = {'bool', 'int', 'double', 'String', 'num'};
  final isPrimitive = primitives.contains(returnTypeName) ||
      returnTypeName.startsWith('Map<') ||
      returnTypeName.startsWith('List<');
  final typeForFromJson = returnTypeName.contains('<') &&
          _hasSpaceAroundAngleBrackets(returnTypeName)
      ? '($returnTypeName)'
      : returnTypeName;

  if (dataPath != null) {
    final field =
        '(response.data as Map<String, dynamic>)["$dataPath"]';
    if (isPrimitive) {
      return 'return $field as $returnTypeName;';
    }
    return 'return $typeForFromJson.fromJson($field as Map<String, dynamic>);';
  }
  if (isPrimitive) {
    return 'return response.data as $returnTypeName;';
  }
  return 'return $typeForFromJson.fromJson(response.data as Map<String, dynamic>);';
}
