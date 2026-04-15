// Datasource for Cloudinary image upload
abstract class CloudinaryDatasource {
  Future<String> uploadImage(String filePath);
}

class CloudinaryDatasourceImpl implements CloudinaryDatasource {
  @override
  Future<String> uploadImage(String filePath) async {
    // TODO: Implement Cloudinary upload
    throw UnimplementedError();
  }
}
