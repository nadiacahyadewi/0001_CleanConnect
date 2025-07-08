import 'dart:convert';


import 'package:cleanconnect/data/model/request/customer/customer_pemesanan_request_model.dart';
import 'package:cleanconnect/data/model/response/user/customer_pemesanan_response_model.dart';
import 'package:cleanconnect/services/service_http_client.dart';
import 'package:dartz/dartz.dart';

class PemesananCustomerRepository {
  final ServiceHttpClient _serviceHttpClient;

  PemesananCustomerRepository(this._serviceHttpClient);

  Future<Either<String, GetPemesananCustomerById>> addPemesanan(
    PemesananCustomerRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.postWithToken(
        "buyer/pemesanan",
        requestModel.toJson(),
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetPemesananCustomerById.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while adding pemesanan: $e");
    }
  }

  Future<Either<String, GetAllPemesananCustomerModel>> getAllPemesanan() async {
    try {
      final response = await _serviceHttpClient.get("buyer/pemesanan");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetAllPemesananCustomerModel.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while getting all pemesanan: $e");
    }
  }

  Future<Either<String, GetPemesananCustomerById>> getPemesananById(
    int id,
  ) async {
    try {
      final response = await _serviceHttpClient.get("buyer/pemesanan/$id");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetPemesananCustomerById.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while getting pemesanan detail: $e");
    }
  }

  // Method untuk buyer update status (gunakan PUT)
  Future<Either<String, GetPemesananCustomerById>> updatePemesananStatus(
    int id,
    String status,
  ) async {
    try {
      final response = await _serviceHttpClient.putWithToken(
        "buyer/pemesanan/$id/status",
        {"status": status},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetPemesananCustomerById.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while updating status: $e");
    }
  }

  // Method khusus untuk admin update status (gunakan PUT)
  Future<Either<String, GetPemesananCustomerById>> updatePemesananStatusAdmin(
    int id,
    String status,
  ) async {
    try {
      final response = await _serviceHttpClient.putWithToken(
        "admin/pemesanan/$id/status",
        {"status": status},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetPemesananCustomerById.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while updating status: $e");
    }
  }

  // Method untuk admin get all pemesanan
  Future<Either<String, GetAllPemesananCustomerModel>> getAllPemesananAdmin() async {
    try {
      final response = await _serviceHttpClient.get("admin/pemesanan");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetAllPemesananCustomerModel.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while getting all pemesanan: $e");
    }
  }

  // Method untuk admin get detail pemesanan
  Future<Either<String, GetPemesananCustomerById>> getPemesananByIdAdmin(
    int id,
  ) async {
    try {
      final response = await _serviceHttpClient.get("admin/pemesanan/$id");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final profileResponse = GetPemesananCustomerById.fromJson(jsonResponse);
        return Right(profileResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while getting pemesanan detail: $e");
    }
  }

  Future<Either<String, String>> deletePemesanan(int id) async {
    try {
      final response = await _serviceHttpClient.deleteWithToken("buyer/pemesanan/$id");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Right(jsonResponse['message'] ?? 'Pemesanan berhasil dihapus');
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while deleting pemesanan: $e");
    }
  }

  // Method untuk admin delete pemesanan
  Future<Either<String, String>> deletePemesananAdmin(int id) async {
    try {
      final response = await _serviceHttpClient.deleteWithToken("admin/pemesanan/$id");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Right(jsonResponse['message'] ?? 'Pemesanan berhasil dihapus');
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return Left("An error occurred while deleting pemesanan: $e");
    }
  }
}