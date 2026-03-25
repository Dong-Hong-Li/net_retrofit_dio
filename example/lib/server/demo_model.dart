// 示例模型：生成代码用 (json) => DemoModel.fromJson(json)。

class DemoModel {
  DemoModel({
    this.userId,
    this.token,
    this.mobile,
  });

  factory DemoModel.fromJson(Map<String, dynamic> json) {
    return DemoModel(
      userId: json['user_id'] as String?,
      token: json['token'] as String?,
      mobile: json['mobile'] as String?,
    );
  }

  final String? userId;
  final String? token;
  final String? mobile;
}
