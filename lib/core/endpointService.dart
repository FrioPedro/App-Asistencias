import 'package:dio/dio.dart';
import 'package:app_asistencias/domain/token/token.dart';

class EndpointService {
  EndpointService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ⚡ Carga el token al vuelo para no depender de init manual
          final token = await Token.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }

          handler.next(options);
        },
        onError: (e, handler) async {
          // Aquí puedes manejar 401 globalmente si quieres
          // (por ejemplo limpiar token y redirigir al login)
          handler.next(e);
        },
      ),
    );

    // Opcional: logs en debug
    // _dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    // ));
  }

  static final EndpointService instance = EndpointService._internal();

  static const String _baseUrl = "http://endpoint.frioteam.pe:8050";

  late final Dio _dio;

  Dio get dio => _dio;

  // ---------- Requests ----------
  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      // Si hay response, devuélvela; si no, rethrow
      if (e.response != null) return e.response as Response<T>;
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response as Response<T>;
      rethrow;
    }
  }

  Future<Response<T>> postFormData<T>(
    String endpoint, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Para multipart, deja que Dio ponga el content-type correcto
      final mergedOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );

      return await _dio.post<T>(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: mergedOptions,
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response as Response<T>;
      rethrow;
    }
  }
}
