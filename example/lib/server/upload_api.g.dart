// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class UploadApiImpl implements UploadApi {
  @override
  Future<Map<String, dynamic>?> upload(File file, String name) async {
    final response = await NetRequest.request<dynamic>(
      url: '${NetRequest.resolveBaseUrl('upload')}/post',
      method: HttpMethod.post,
      body: FormData.fromMap(
          {'file': MultipartFile.fromFileSync(file.path), 'name': name}),
      clientKey: 'upload',
    );
    return response.data as Map<String, dynamic>;
  }
}
