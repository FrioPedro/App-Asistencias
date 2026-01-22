import 'package:app_asistencias/core/enpoinService.dart';
import 'package:dio/dio.dart';
import 'package:app_asistencias/domain/token/token.dart';
import 'dart:convert';

class LoginUser {

  static Future<bool> authenticate(String user, String password) async{
    final api = EndpointService.instance;

    final response = await api.post("/token", data: {"username": user, "password": password});

    print("[authenticate] body: ${response.data}");

    if (response.statusCode == 200){
      final token = response.data['token'];
      await Token.saveToken(token);
      return true;
    }

    return false;
  }

}