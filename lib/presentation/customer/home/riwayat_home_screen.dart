import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/bloc/pemesanan_customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RiwayatPemesananCustomerScreen extends StatefulWidget {
  const RiwayatPemesananCustomerScreen({super.key});

  @override
  State<RiwayatPemesananCustomerScreen> createState() => _RiwayatPemesananCustomerScreenState();
}

class _RiwayatPemesananCustomerScreenState extends State<RiwayatPemesananCustomerScreen> {
  late PemesananCustomerBloc _pemesananBloc;
  String _selectedFilter = 'semua'; // semua, selesai, ditolak

  @override
  void initState() {
    super.initState();
    _pemesananBloc = context.read<PemesananCustomerBloc>();
    _pemesananBloc.add(PemesananCustomerGetAllEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: TextStyle(color: AppColors.lightSheet, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.lightSheet),
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.lightSheet),
            onPressed: _showFilterModal,
          ),
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.lightSheet),
            onPressed: () {
              _pemesananBloc.add(PemesananCustomerGetAllEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<PemesananCustomerBloc, PemesananCustomerState>(
        bloc: _pemesananBloc,
        builder: (context, state) {
          if (state is PemesananCustomerLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is PemesananCustomerErrorState) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } 
          
          if (state is PemesananCustomerSuccessState) {
            final filteredData = _filterData(state.responseModel.data);
            
            if (filteredData.isEmpty) {
              return const Center(child: Text('Tidak ada data'));
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final pemesanan = filteredData[index];
                return _buildPemesananCard(pemesanan);
              },
            );
          }
          
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  // Filter data berdasarkan pilihan user
  List<dynamic> _filterData(List<dynamic> allData) {
    final riwayatData = allData.where((item) {
      final status = item.status.toLowerCase();
      return status == 'selesai' || status == 'completed' || 
             status == 'ditolak' || status == 'rejected';
    }).toList();

    if (_selectedFilter == 'selesai') {
      return riwayatData.where((item) {
        final status = item.status.toLowerCase();
        return status == 'selesai' || status == 'completed';
      }).toList();
    }
    
    if (_selectedFilter == 'ditolak') {
      return riwayatData.where((item) {
        final status = item.status.toLowerCase();
        return status == 'ditolak' || status == 'rejected';
      }).toList();
    }
    
    return riwayatData; // semua
  }

  // Modal untuk memilih filter
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Filter Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Filter options
            _buildFilterOption('semua', 'Semua Riwayat', Icons.history, Colors.blue),
            _buildFilterOption('selesai', 'Selesai', Icons.check_circle, Colors.green),
            _buildFilterOption('ditolak', 'Ditolak', Icons.cancel, Colors.red),
          ],
        ),
      ),
    );
  }

  // Widget untuk setiap option filter
  Widget _buildFilterOption(String value, String title, IconData icon, Color color) {
    final isSelected = _selectedFilter == value;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // Card untuk setiap pemesanan
  Widget _buildPemesananCard(dynamic pemesanan) {
    final status = pemesanan.status.toLowerCase();
    final isCompleted = status == 'selesai' || status == 'completed';
    final statusColor = isCompleted ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pesanan #${pemesanan.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Selesai' : 'Ditolak',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Info pemesanan
            _buildInfoRow('Customer', pemesanan.nama),
            _buildInfoRow('Layanan', pemesanan.layanan),
            _buildInfoRow('Harga', _formatCurrency(pemesanan.harga)),
            _buildInfoRow('Tanggal', '${_formatDate(pemesanan.tanggalPesan)} ${pemesanan.jam}'),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                if (isCompleted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(pemesanan),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Beri Rating'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showContactSupport,
                      icon: const Icon(Icons.help, size: 16),
                      label: const Text('Hubungi CS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // Delete button
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(pemesanan),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog rating
  void _showRatingDialog(dynamic pemesanan) {
    int selectedRating = 0;
    String comment = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Beri Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bagaimana pengalaman Anda dengan layanan ${pemesanan.layanan}?'),
              const SizedBox(height: 20),
              
              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => 
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      color: (index < selectedRating) ? Colors.amber : const Color.fromARGB(255, 0, 0, 0),
                      size: 35,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Rating text
              if (selectedRating > 0)
                Text(
                  _getRatingText(selectedRating),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getRatingColor(selectedRating),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Comment TextField
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar Anda (opsional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  comment = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedRating > 0 ? () {
                Navigator.pop(context);
                _submitRating(pemesanan.id, selectedRating, comment);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim Rating'),
            ),
          ],
        ),
      ),
    );
  }

  // Get rating text description
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Baik';
      case 5:
        return 'Sangat Baik';
      default:
        return '';
    }
  }

  // Get rating color
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Submit rating to server
  void _submitRating(int pemesananId, int rating, String comment) {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Mengirim rating...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Integrate with your rating API
    // For now, simulate success
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating $rating bintang berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    });

    /* 
    // Example integration with BLoC (uncomment when you have rating endpoint):
    
    _pemesananBloc.add(PemesananCustomerRatingEvent(
      pemesananId: pemesananId,
      rating: rating,
      comment: comment,
    ));
    
    _pemesananBloc.stream.listen((state) {
      if (state is PemesananCustomerRatingSuccessState) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rating $rating bintang berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is PemesananCustomerErrorState) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim rating: ${state.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    */
  }

  // Dialog delete confirmation
  void _showDeleteDialog(dynamic pemesanan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pemesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin menghapus pemesanan #${pemesanan.id}?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Data yang dihapus tidak dapat dikembalikan.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePemesanan(pemesanan.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Function untuk delete pemesanan
  void _deletePemesanan(int id) {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Menghapus pemesanan...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Call BLoC delete event
    _pemesananBloc.add(PemesananCustomerDeleteEvent(id));
    
    // Listen to delete result
    _pemesananBloc.stream.listen((state) {
      if (state is PemesananCustomerDeleteSuccessState) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemesanan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data
        _pemesananBloc.add(PemesananCustomerGetAllEvent());
      } else if (state is PemesananCustomerErrorState) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${state.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // Modal contact support
  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hubungi Customer Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Telepon'),
              subtitle: const Text('0800-1234-5678'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('WhatsApp'),
              subtitle: const Text('Chat dengan CS'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatCurrency(String amount) {
    return "Rp ${amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}