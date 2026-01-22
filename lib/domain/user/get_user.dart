import 'package:app_asistencias/core/enpoinService.dart';
import 'package:app_asistencias/models/user_model.dart';
import 'package:dio/dio.dart';

class GetUser {

  static Future<UserModel?> fetchUser() async {
    final api = EndpointService.instance;
    
    final response = await api.get("/api/information");

    print("[authenticate] body: ${response.data}");

    if (response.statusCode == 200){
      return UserModel.fromJson(response.data);
    }

    return null;

  }
}