import 'dart:convert';
import 'dart:developer';
import 'package:cleanconnect/data/model/request/customer/customer_profile_request_model.dart';
import 'package:cleanconnect/data/model/response/user/customer_profile_response_model.dart';
import 'package:cleanconnect/services/service_http_client.dart';
import 'package:dartz/dartz.dart';

class ProfileBuyerRepository {
  final ServiceHttpClient _serviceHttpClient;
  ProfileBuyerRepository(this._serviceHttpClient);

  Future<Either<String, CustomerProfileResponseModel>> addProfileBuyer(
    CustomerProfileRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.postWithToken(
        "buyer/profile",
        requestModel.toMap(),
      );

      log(response.statusCode.toString());

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = CustomerProfileResponseModel.fromJson(
          jsonResponse,
        );
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while adding profile: $e");
    }
  }

  Future<Either<String, CustomerProfileResponseModel>> getProfileBuyer() async {
    try {
      final response = await _serviceHttpClient.get("buyer/profile");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = CustomerProfileResponseModel.fromJson(
          jsonResponse,
        );
        print("Profile Response: $profileResponse");
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while fetching profile: $e");
    }
  }
}