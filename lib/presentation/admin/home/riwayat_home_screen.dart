import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/data/model/response/user/customer_pemesanan_response_model.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/bloc/pemesanan_customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RiwayatHomeScreen extends StatefulWidget {
  const RiwayatHomeScreen({super.key});

  @override
  State<RiwayatHomeScreen> createState() => _RiwayatHomeScreenState();
}

class _RiwayatHomeScreenState extends State<RiwayatHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data pemesanan saat screen dibuka
    context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return Colors.green;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _formatCurrency(String amount) {
    final numAmount = int.tryParse(amount) ?? 0;
    return "Rp ${numAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh data
              context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<PemesananCustomerBloc, PemesananCustomerState>(
        builder: (context, state) {
          if (state is PemesananCustomerLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is PemesananCustomerErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (state is PemesananCustomerSuccessState) {
            // Filter hanya pesanan yang selesai atau ditolak
            final riwayatFiltered = state.responseModel.data.where((item) => 
              item.status.toLowerCase() == 'selesai' || 
              item.status.toLowerCase() == 'completed' ||
              item.status.toLowerCase() == 'ditolak' ||
              item.status.toLowerCase() == 'rejected'
            ).toList();
            
            if (riwayatFiltered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Riwayat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Riwayat pesanan yang selesai atau ditolak\nakan muncul di sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PemesananCustomerBloc>().add(PemesananCustomerGetAllEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: riwayatFiltered.length,
                itemBuilder: (context, index) {
                  final riwayat = riwayatFiltered[index];
                  return _buildRiwayatCard(riwayat);
                },
              ),
            );
          }
          
          return const Center(
            child: Text('Tidak ada data'),
          );
        },
      ),
    );
  }

  Widget _buildRiwayatCard(GetPemesananCustomer riwayat) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan ID dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${riwayat.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            riwayat.nama,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(riwayat.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _getStatusColor(riwayat.status),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getStatusText(riwayat.status),
                      style: TextStyle(
                        color: _getStatusColor(riwayat.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Detail pesanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.cleaning_services, 'Layanan', riwayat.layanan),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.attach_money, 'Harga', _formatCurrency(riwayat.harga)),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.calendar_today, 'Tanggal', 
                        '${riwayat.tanggalPesan.day}/${riwayat.tanggalPesan.month}/${riwayat.tanggalPesan.year}'),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.access_time, 'Jam', riwayat.jam),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.location_on, 'Alamat', riwayat.alamat),
                    
                    if (riwayat.deskripsi != null && riwayat.deskripsi!.isNotEmpty) ...[
                      const Divider(height: 20),
                      _buildDetailRow(Icons.description, 'Deskripsi', riwayat.deskripsi!),
                    ],
                  ],
                ),
              ),
              
              // Rating section untuk pesanan selesai
              if (riwayat.status.toLowerCase() == 'selesai' || riwayat.status.toLowerCase() == 'completed') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Rating: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        riwayat.rating != null && riwayat.rating!.isNotEmpty 
                            ? '${riwayat.rating}/5'
                            : 'Belum diberi rating',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Footer dengan foto jika ada
              if (riwayat.foto != null && riwayat.foto!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Foto lokasi tersedia',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Implementasi untuk melihat foto
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur lihat foto akan segera tersedia')),
                          );
                        },
                        child: Text(
                          'Lihat',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}