import 'dart:convert';
import 'package:cleanconnect/data/model/request/auth/login_request_model.dart';
import 'package:cleanconnect/data/model/request/auth/register_request_model.dart';
import 'package:cleanconnect/data/model/response/auth_response_model.dart';
import 'package:cleanconnect/services/service_http_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final secureStorage = FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        'login',
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = AuthResponseModel.fromMap(jsonResponse);
        await secureStorage.write(
          key: 'token',
          value: loginResponse.user!.token,
        );
        await secureStorage.write(
          key: 'userRole',
          value: loginResponse.user!.role,
        );
        return Right(loginResponse);
      } else {
        return Left(jsonResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      return left('An error occured while logging in.');
    }
  }

  Future<Either<String, String>> register(
    RegisterRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        'register',
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      final registerResponse = jsonResponse['message'];
      if (response.statusCode == 201) {
        return right(registerResponse);
      } else {
        return left(jsonResponse['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return left('An occured while registering. : $e');
    }
  }
}