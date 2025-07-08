import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ServiceHttpClient {
  final String baseUrl = 'http://10.0.2.2:8000/api/';
  final secureStorage = FlutterSecureStorage();

  //post
  Future<http.Response> post(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  //post with token
  Future<http.Response> postWithToken(
    String endPoint,
    Map<String, dynamic> body,
  ) async {
    final token = await secureStorage.read(key: 'token');
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  //get
  Future<http.Response> get(String endPoint) async {
    final token = await secureStorage.read(key: 'token');
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  //put
  Future<http.Response> put(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  //put with token
  Future<http.Response> putWithToken(
    String endPoint,
    Map<String, dynamic> body,
  ) async {
    final token = await secureStorage.read(key: 'token');
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  //delete
  Future<http.Response> delete(String endPoint) async {
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  //delete with token
  Future<http.Response> deleteWithToken(String endPoint) async {
    final token = await secureStorage.read(key: 'token');
    final url = Uri.parse("$baseUrl$endPoint");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Method untuk multipart request (upload file)
  Future<http.StreamedResponse> postMultipartWithToken(
    String endPoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    final token = await secureStorage.read(key: 'token');
    final url = Uri.parse("$baseUrl$endPoint");
    
    try {
      var request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add files
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
      
      final response = await request.send();
      return response;
    } catch (e) {
      throw Exception('Multipart request failed: $e');
    }
  }

  // Method untuk mendapatkan token
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  // Method untuk menyimpan token
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'token', value: token);
  }

  // Method untuk menghapus token
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'token');
  }
}