import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/data/model/response/user/customer_pemesanan_response_model.dart';
import 'package:cleanconnect/presentation/admin/home/view_location_map_screen.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/bloc/pemesanan_customer_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PemesananDetailScreen extends StatefulWidget {
  final GetPemesananCustomer data;

  const PemesananDetailScreen({super.key, required this.data});

  @override
  State<PemesananDetailScreen> createState() => _PemesananDetailScreenState();
}

class _PemesananDetailScreenState extends State<PemesananDetailScreen> {
  String? selectedNewStatus;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () {
              _showContactCustomer();
            },
          ),
        ],
      ),
      body: BlocListener<PemesananCustomerBloc, PemesananCustomerState>(
        listener: (context, state) {
          if (state is PemesananCustomerUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status pesanan berhasil diupdate'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true untuk refresh
          } else if (state is PemesananCustomerErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Order ID Card
                _buildOrderStatusCard(),
                
                const SizedBox(height: 16),
                
                // Customer Info Card
                _buildCustomerInfoCard(),
                
                const SizedBox(height: 16),
                
                // Service Details Card
                _buildServiceDetailsCard(),
                
                const SizedBox(height: 16),
                
                // Schedule & Location Card
                _buildScheduleLocationCard(),
                
                const SizedBox(height: 16),
                
                // Price & Payment Card
                _buildPricePaymentCard(),
                
                if (widget.data.deskripsi != null && widget.data.deskripsi!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(),
                ],
                
                const SizedBox(height: 24),
                
                // Admin Action Buttons
                _buildAdminActions(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    Color statusColor = _getStatusColor(widget.data.status);
    IconData statusIcon = _getStatusIcon(widget.data.status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.data.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(widget.data.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.data.status == 'menunggu konfirmasi')
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notification_important,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return _buildInfoCard(
      title: 'Informasi Pelanggan',
      icon: Icons.person,
      iconColor: Colors.blue.shade600,
      children: [
        _buildInfoRow(Icons.person, 'Nama', widget.data.nama),
        const Divider(height: 20),
        _buildInfoRow(Icons.phone, 'No. Telepon', widget.data.noTlp),
        const Divider(height: 20),
        _buildAddressRow(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showContactCustomer();
                },
                icon: const Icon(Icons.phone, size: 20),
                label: const Text('Hubungi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _openLocationMap();
                },
                icon: const Icon(Icons.map, color: Colors.white, size: 20),
                label: const Text(
                  'Lihat Lokasi',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.data.alamat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, 
                         color: Colors.orange.shade600, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Tap untuk lihat di map',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetailsCard() {
    return _buildInfoCard(
      title: 'Detail Layanan',
      icon: Icons.cleaning_services,
      iconColor: Colors.green.shade600,
      children: [
        _buildInfoRow(Icons.home_repair_service, 'Jenis Layanan', widget.data.layanan),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.assignment_turned_in, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pastikan peralatan dan bahan pembersih sudah disiapkan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleLocationCard() {
    return _buildInfoCard(
      title: 'Jadwal & Lokasi',
      icon: Icons.schedule,
      iconColor: Colors.orange.shade600,
      children: [
        _buildInfoRow(Icons.calendar_today, 'Tanggal', _formatDate(widget.data.tanggalPesan)),
        const Divider(height: 20),
        _buildInfoRow(Icons.access_time, 'Waktu', widget.data.jam),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Koordinasi dengan tim lapangan 30 menit sebelum jadwal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _openLocationMap();
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Buka Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade600,
                        side: BorderSide(color: Colors.orange.shade600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _openGoogleMapsDirections();
                      },
                      icon: const Icon(Icons.directions, color: Colors.white, size: 18),
                      label: const Text(
                        'Navigasi',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricePaymentCard() {
    return _buildInfoCard(
      title: 'Pembayaran',
      icon: Icons.payment,
      iconColor: Colors.purple.shade600,
      children: [
        _buildInfoRow(Icons.attach_money, 'Biaya Layanan', _formatCurrency(widget.data.harga)),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.purple.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              _formatCurrency(widget.data.harga),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple.shade600, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pembayaran akan dilakukan setelah layanan selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return _buildInfoCard(
      title: 'Catatan Khusus',
      icon: Icons.note,
      iconColor: Colors.teal.shade600,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Text(
            widget.data.deskripsi!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
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

  // Method untuk membuka map view dengan alamat customer
  void _openLocationMap() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewLocationMap(
            address: widget.data.alamat,
            customerName: widget.data.nama,
            orderId: widget.data.id.toString(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka maps: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method untuk membuka Google Maps dengan directions
  void _openGoogleMapsDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka Google Maps untuk navigasi ke ${widget.data.nama}...'),
        backgroundColor: Colors.green,
      ),
    );
    // Implement URL launcher untuk Google Maps
    // final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.data.alamat)}';
    // launchUrl(Uri.parse(url));
  }

  Widget _buildAdminActions() {
    bool canProcess = widget.data.status == 'menunggu konfirmasi';
    bool inProgress = widget.data.status == 'diterima' || widget.data.status == 'diproses';
    bool isCompleted = widget.data.status == 'selesai';
    bool isRejected = widget.data.status == 'ditolak';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (canProcess) ...[
          // Accept and Reject buttons for pending orders
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _updateOrderStatus('diterima');
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Terima Pesanan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Tolak Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        
        if (inProgress) ...[
          // Update status dropdown for accepted orders
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Status Pesanan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('Pilih status baru'),
                  value: selectedNewStatus,
                  items: _getAvailableStatuses().map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(_getStatusIcon(status), 
                               color: _getStatusColor(status), size: 20),
                          const SizedBox(width: 8),
                          Text(_getStatusText(status)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNewStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedNewStatus != null 
                        ? () {
                            _updateOrderStatus(selectedNewStatus!);
                          }
                        : null,
                    icon: const Icon(Icons.update, color: Colors.white),
                    label: const Text(
                      'Update Status',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (isCompleted || isRejected) ...[
          // Show completion info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: isCompleted ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCompleted 
                        ? 'Pesanan telah selesai dikerjakan'
                        : 'Pesanan telah ditolak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<String> _getAvailableStatuses() {
    switch (widget.data.status) {
      case 'diterima':
        return ['diproses'];
      case 'diproses':
        return ['selesai'];
      default:
        return [];
    }
  }

  void _updateOrderStatus(String newStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Konfirmasi"),
          content: Text("Ubah status pesanan menjadi '${_getStatusText(newStatus)}'?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text("Ya, Update"),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<PemesananCustomerBloc>().add(
                  PemesananCustomerUpdateStatusEvent(widget.data.id, newStatus),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Tolak Pesanan"),
          content: const Text("Apakah Anda yakin ingin menolak pesanan ini?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("Ya, Tolak"),
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus('ditolak');
              },
            ),
          ],
        );
      },
    );
  }

  void _showContactCustomer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hubungi ${widget.data.nama}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, color: Colors.green.shade600),
                  ),
                  title: const Text('Telepon'),
                  subtitle: Text(widget.data.noTlp),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Menghubungi ${widget.data.noTlp}...')),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.message, color: Colors.blue.shade600),
                  ),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('Chat via WhatsApp'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle WhatsApp
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka WhatsApp...')),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    List<String> monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return Icons.access_time;
      case 'diterima':
        return Icons.check_circle_outline;
      case 'diproses':
        return Icons.settings;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'selesai':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'diterima':
        return 'Diterima';
      case 'diproses':
        return 'Sedang Diproses';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Status Tidak Diketahui';
    }
  }
}