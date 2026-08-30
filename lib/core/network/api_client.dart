
import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService _storage;

  bool _isRefreshing = false;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:5023',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ),
        _storage = SecureStorageService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken =
              await _storage.getAccessToken();

          if (accessToken != null &&
              accessToken.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer $accessToken';
          }

          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }

          final request = error.requestOptions;

          if (request.path == '/api/auth/login' ||
              request.path == '/api/auth/refresh') {
            handler.next(error);
            return;
          }

          if (_isRefreshing) {
            handler.next(error);
            return;
          }

          _isRefreshing = true;

          try {
            final refreshToken =
                await _storage.getRefreshToken();

            if (refreshToken == null ||
                refreshToken.isEmpty) {
              handler.next(error);
              return;
            }

            final refreshResponse = await dio.post(
              '/api/auth/refresh',
              data: {
                'refreshToken': refreshToken,
              },
            );

            final newAccessToken =
                refreshResponse.data['accessToken'];

            final newRefreshToken =
                refreshResponse.data['refreshToken'];

            await _storage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            request.headers['Authorization'] =
                'Bearer $newAccessToken';

            final retryResponse =
                await dio.fetch(request);

            handler.resolve(retryResponse);
          } catch (_) {
            handler.next(error);
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }
}

