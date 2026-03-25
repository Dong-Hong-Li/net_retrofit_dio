/// 与 @DataPath + httpbin 回显字段 `json` 配合（示例 5）。
class NestedModel {
  NestedModel({this.value});

  factory NestedModel.fromJson(Map<String, dynamic> json) {
    return NestedModel(value: json['value'] as String?);
  }

  final String? value;
}
