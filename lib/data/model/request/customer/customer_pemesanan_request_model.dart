import 'dart:convert';

class PemesananCustomerRequestModel {
  final String nama;
  final String noTlp;
  final String alamat;
  final String? foto; // nullable
  final String? deskripsi; // nullable
  final String layanan;
  final String harga;
  final DateTime tanggalPesan;
  final String jam;
  final String? status; // nullable
  final String? rating; // nullable

  PemesananCustomerRequestModel({
    required this.nama,
    required this.noTlp,
    required this.alamat,
    this.foto, // nullable constructor param
    this.deskripsi, // nullable constructor param
    required this.layanan,
    required this.harga,
    required this.tanggalPesan,
    required this.jam,
    this.status, // nullable constructor param
    this.rating, // nullable constructor param
  });

  PemesananCustomerRequestModel copyWith({
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
  }) => PemesananCustomerRequestModel(
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

  factory PemesananCustomerRequestModel.fromRawJson(String str) =>
      PemesananCustomerRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PemesananCustomerRequestModel.fromJson(Map<String, dynamic> json) =>
      PemesananCustomerRequestModel(
        nama: json["nama"],
        noTlp: json["no_tlp"],
        alamat: json["alamat"],
        foto: json["foto"], // nullable, can be null
        deskripsi: json["deskripsi"], // nullable, can be null
        layanan: json["layanan"],
        harga: json["harga"],
        tanggalPesan: DateTime.parse(json["tanggal_pesan"]),
        jam: json["jam"],
        status: json["status"], // nullable, can be null
        rating: json["rating"], // nullable, can be null
      );

  Map<String, dynamic> toJson() => {
    "nama": nama,
    "no_tlp": noTlp,
    "alamat": alamat,
    if (foto != null) "foto": foto,
    if (deskripsi != null) "deskripsi": deskripsi,
    "layanan": layanan,
    "harga": harga,
    "tanggal_pesan":
        "${tanggalPesan.year.toString().padLeft(4, '0')}-${tanggalPesan.month.toString().padLeft(2, '0')}-${tanggalPesan.day.toString().padLeft(2, '0')}",
    "jam": jam,
    if (status != null) "status": status,
    if (rating != null) "rating": rating,
  };
}