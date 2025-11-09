import '../../models/experience_model.dart';
import '../api/api_client.dart';

class ExperienceRepository {
  final ApiClient apiClient;

  ExperienceRepository({required this.apiClient});

  Future<List<Experience>> fetchExperiences() async {
    try {
      final response = await apiClient.getExperiences();
      final data = response.data['data']['experiences'] as List;
      return data.map((json) => Experience.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch experiences: $e');
    }
  }
}