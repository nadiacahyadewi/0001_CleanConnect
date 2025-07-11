import 'package:cleanconnect/core/components/spaces.dart';
import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/bloc/pemesanan_customer_bloc.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/input_pemesanan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PemesananCustomerScreen extends StatefulWidget {
  const PemesananCustomerScreen({super.key});

  @override
  State<PemesananCustomerScreen> createState() => _PemesananCustomerScreenState();
}

class _PemesananCustomerScreenState extends State<PemesananCustomerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pemesanan Layanan',
          style: TextStyle(color: AppColors.lightSheet),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.06),
                blurRadius: 10.0,
                blurStyle: BlurStyle.outer,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<PemesananCustomerBloc, PemesananCustomerState>(
              builder: (context, state) {
                if (state is PemesananCustomerLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PemesananCustomerErrorState) {
                  return Center(child: Text(state.errorMessage));
                } else if (state is PemesananCustomerSuccessState) {
                  final allData = state.responseModel.data;
                  
                  // Filter data - hanya tampilkan yang bukan selesai/ditolak
                  final data = allData.where((pemesanan) {
                    final status = pemesanan.status.toLowerCase();
                    return status != 'selesai' && 
                           status != 'completed' && 
                           status != 'ditolak' && 
                           status != 'rejected';
                  }).toList();
                  
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pemesanan'),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Daftar Pemesanan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SpaceHeight(16.0),
                      ListView.separated(
                        itemCount: data.length,
                        shrinkWrap: true, // 🟢 penting
                        physics:
                            const NeverScrollableScrollPhysics(), // biar scroll ikut SingleChildScrollView
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final pemesanan = data[index];
                          return ListTile(
                            // onTap: () {
                            //   context.push(PemesananDetailScreen(data: pemesanan));
                            // },
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  (pemesanan.foto != null &&
                                      pemesanan.foto!.isNotEmpty)
                                  ? NetworkImage(pemesanan.foto!)
                                  : AssetImage('assets/images/clean.png') as ImageProvider,
                              backgroundColor: AppColors.lightSheet,
                            ),
                            title: Text(pemesanan.nama),
                            subtitle: Text(
                              '${pemesanan.layanan} - ${_formatCurrency(pemesanan.harga)}\n'
                              '${_formatDate(pemesanan.tanggalPesan)} ${pemesanan.jam}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(pemesanan.status),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                _getStatusText(pemesanan.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text('Ada masalah, silakan coba lagi'),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tambah-pemesanan',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PemesananFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.lightSheet),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatCurrency(String amount) {
    // Simple currency formatting
    return "Rp ${amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return Colors.orange;
      case 'diterima':
        return Colors.blue;
      case 'diproses':
        return Colors.purple;
      case 'ditolak':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'diproses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }
}