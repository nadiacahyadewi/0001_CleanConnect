import 'dart:convert';

class CustomerProfileResponseModel {
  String message;
  int statusCode;
  Data data;

  CustomerProfileResponseModel({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  CustomerProfileResponseModel copyWith({
    String? message,
    int? statusCode,
    Data? data,
  }) => CustomerProfileResponseModel(
    message: message ?? this.message,
    statusCode: statusCode ?? this.statusCode,
    data: data ?? this.data,
  );

  factory CustomerProfileResponseModel.fromRawJson(String str) =>
      CustomerProfileResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomerProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      CustomerProfileResponseModel(
        message: json["message"],
        statusCode: json["status_code"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String name;
  String address;
  String phone;
  String? photo;

  Data({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.photo,
  });

  Data copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? photo,
  }) => Data(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    photo: photo ?? this.photo,
  );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    phone: json["phone"],
    photo: json["photo"] ?? "", // Handle null case for photo
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "phone": phone,
    "photo": photo,
  };
}
