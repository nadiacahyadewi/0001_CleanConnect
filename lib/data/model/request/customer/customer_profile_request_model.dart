import 'dart:convert';

class CustomerProfileRequestModel {
    String? name;
    String? address;
    String? phone;
    String? photo;

    CustomerProfileRequestModel({
        this.name,
        this.address,
        this.phone,
        this.photo,
    });

    factory CustomerProfileRequestModel.fromJson(String str) => CustomerProfileRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CustomerProfileRequestModel.fromMap(Map<String, dynamic> json) => CustomerProfileRequestModel(
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
        photo: json["photo"],
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "address": address,
        "phone": phone,
        "photo": photo,
    };
}
