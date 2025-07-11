import 'package:cleanconnect/core/components/spaces.dart';
import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/presentation/admin/home/pemesanan_detail_screen.dart';
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
    _loadData();
  }

  void _loadData() {
    context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
  }

  Future<void> _onRefresh() async {
    _loadData();
    // Wait for the bloc to finish loading
    await Future.delayed(const Duration(milliseconds: 500));
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.lightSheet),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Penting untuk RefreshIndicator
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
              child: BlocConsumer<PemesananCustomerBloc, PemesananCustomerState>(
                listener: (context, state) {
                  if (state is PemesananCustomerErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Coba Lagi',
                          textColor: Colors.white,
                          onPressed: _loadData,
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PemesananCustomerLoadingState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SpaceHeight(16),
                            Text('Memuat data pemesanan...'),
                          ],
                        ),
                      ),
                    );
                  } else if (state is PemesananCustomerErrorState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SpaceHeight(16),
                            Text(
                              'Terjadi Kesalahan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SpaceHeight(8),
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SpaceHeight(24),
                            ElevatedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
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
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SpaceHeight(16),
                              Text(
                                'Belum Ada Pemesanan Aktif',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SpaceHeight(8),
                              Text(
                                'Tarik ke bawah untuk refresh atau buat pemesanan baru',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SpaceHeight(24),
                              // ElevatedButton.icon(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => const InputPemesananScreen(),
                              //       ),
                              //     ).then((_) => _loadData());
                              //   },
                              //   icon: const Icon(Icons.add),
                              //   label: const Text('Buat Pemesanan'),
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: AppColors.primary,
                              //     foregroundColor: Colors.white,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${data.length} pesanan aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SpaceHeight(8),
                        Text(
                          'Tarik ke bawah untuk refresh data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SpaceHeight(16.0),
                        ListView.separated(
                          itemCount: data.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final pemesanan = data[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PemesananDetailScreen(data: pemesanan),
                                    ),
                                  );
                                  
                                  // Refresh jika ada perubahan
                                  if (result == true) {
                                    _loadData();
                                  }
                                },
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _getStatusColor(pemesanan.status).withOpacity(0.1),
                                  child: (pemesanan.foto != null && pemesanan.foto!.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            pemesanan.foto!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.cleaning_services,
                                                color: _getStatusColor(pemesanan.status),
                                                size: 24,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.cleaning_services,
                                          color: _getStatusColor(pemesanan.status),
                                          size: 24,
                                        ),
                                ),
                                title: Text(
                                  pemesanan.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SpaceHeight(4),
                                    Text(
                                      '${pemesanan.layanan} - ${_formatCurrency(pemesanan.harga)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SpaceHeight(4),
                                    Text(
                                      '${_formatDate(pemesanan.tanggalPesan)} • ${pemesanan.jam}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SpaceHeight(8),
                                    Container(
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
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            );
                          },
                        ),
                        const SpaceHeight(20),
                        // Bottom spacing for better scrolling
                        Container(height: 1),
                      ],
                    );
                  }

                  return Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: Text('Ada masalah, silakan coba lagi'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const InputPemesananScreen(),
      //       ),
      //     ).then((_) => _loadData()); // Refresh setelah tambah data
      //   },
      //   backgroundColor: AppColors.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatCurrency(String amount) {
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