// Datasource for remote AI API calls
abstract class AiRemoteDatasource {
  Future<Map<String, dynamic>> analyzeFood(String imageUrl);
}

class AiRemoteDatasourceImpl implements AiRemoteDatasource {
  @override
  Future<Map<String, dynamic>> analyzeFood(String imageUrl) async {
    // TODO: Implement HTTP call to AI API
    throw UnimplementedError();
  }
}
