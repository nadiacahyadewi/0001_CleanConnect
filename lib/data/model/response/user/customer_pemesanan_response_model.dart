import 'dart:convert';

class GetPemesananCustomerById {
  final String message;
  final int statusCode;
  final GetPemesananCustomer data;

  GetPemesananCustomerById({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  GetPemesananCustomerById copyWith({
    String? message, 
    int? statusCode, 
    GetPemesananCustomer? data
  }) => GetPemesananCustomerById(
        message: message ?? this.message,
        statusCode: statusCode ?? this.statusCode,
        data: data ?? this.data,
      );

  factory GetPemesananCustomerById.fromRawJson(String str) =>
      GetPemesananCustomerById.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetPemesananCustomerById.fromJson(Map<String, dynamic> json) => 
      GetPemesananCustomerById(
        message: json["message"],
        statusCode: json["status_code"],
        data: GetPemesananCustomer.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class GetAllPemesananCustomerModel {
  final String message;
  final int statusCode;
  final List<GetPemesananCustomer> data;

  GetAllPemesananCustomerModel({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  GetAllPemesananCustomerModel copyWith({
    String? message,
    int? statusCode,
    List<GetPemesananCustomer>? data,
  }) => GetAllPemesananCustomerModel(
    message: message ?? this.message,
    statusCode: statusCode ?? this.statusCode,
    data: data ?? this.data,
  );

  factory GetAllPemesananCustomerModel.fromRawJson(String str) =>
      GetAllPemesananCustomerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetAllPemesananCustomerModel.fromJson(Map<String, dynamic> json) =>
      GetAllPemesananCustomerModel(
        message: json["message"],
        statusCode: json["status_code"],
        data: List<GetPemesananCustomer>.from(
          json["data"].map((x) => GetPemesananCustomer.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class GetPemesananCustomer {
  final int id;
  final String nama;
  final String noTlp;
  final String alamat;
  final String? foto;
  final String? deskripsi;
  final String layanan;
  final String harga;
  final DateTime tanggalPesan;
  final String jam;
  final String status;
  final String? rating;

  GetPemesananCustomer({
    required this.id,
    required this.nama,
    required this.noTlp,
    required this.alamat,
    required this.foto,
    required this.deskripsi,
    required this.layanan,
    required this.harga,
    required this.tanggalPesan,
    required this.jam,
    required this.status,
    required this.rating,
  });

  GetPemesananCustomer copyWith({
    int? id,
    String? nama,
    String? noTlp,
    String? alamat,
    String? foto,
    String? deskripsi,
    String? layanan,
    String? harga,
    DateTime? tanggalPesan,
    String? jam,
    String? status,
    String? rating,
  }) => GetPemesananCustomer(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    noTlp: noTlp ?? this.noTlp,
    alamat: alamat ?? this.alamat,
    foto: foto ?? this.foto,
    deskripsi: deskripsi ?? this.deskripsi,
    layanan: layanan ?? this.layanan,
    harga: harga ?? this.harga,
    tanggalPesan: tanggalPesan ?? this.tanggalPesan,
    jam: jam ?? this.jam,
    status: status ?? this.status,
    rating: rating ?? this.rating,
  );

  factory GetPemesananCustomer.fromRawJson(String str) =>
      GetPemesananCustomer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetPemesananCustomer.fromJson(Map<String, dynamic> json) => 
      GetPemesananCustomer(
        id: json["id"],
        nama: json["nama"],
        noTlp: json["no_tlp"],
        alamat: json["alamat"],
        foto: json["foto"] ?? "",
        deskripsi: json["deskripsi"] ?? "",
        layanan: json["layanan"],
        harga: json["harga"],
        tanggalPesan: DateTime.parse(json["tanggal_pesan"]),
        jam: json["jam"],
        status: json["status"],
        rating: json["rating"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "no_tlp": noTlp,
    "alamat": alamat,
    "foto": foto,
    "deskripsi": deskripsi,
    "layanan": layanan,
    "harga": harga,
    "tanggal_pesan":
        "${tanggalPesan.year.toString().padLeft(4, '0')}-${tanggalPesan.month.toString().padLeft(2, '0')}-${tanggalPesan.day.toString().padLeft(2, '0')}",
    "jam": jam,
    "status": status,
    "rating": rating,
  };
}