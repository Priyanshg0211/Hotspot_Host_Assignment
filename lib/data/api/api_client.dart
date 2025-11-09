import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://staging.chamberofsecrets.8club.co/v1',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Future<Response> getExperiences() async {
    try {
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection. Please check your network settings.');
      }

      final response = await _dio.get('/experiences', queryParameters: {
        'active': 'true',
      });
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error. Please check your internet connection.');
      }
      throw Exception('Failed to load experiences: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}