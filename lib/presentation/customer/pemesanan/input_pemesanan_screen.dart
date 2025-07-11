import 'dart:io';
import 'package:cleanconnect/core/components/custom_text_field.dart';
import 'package:cleanconnect/core/components/spaces.dart';
import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/data/model/request/customer/customer_pemesanan_request_model.dart';
import 'package:cleanconnect/presentation/customer/customer_main_page.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/bloc/pemesanan_customer_bloc.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/maps.dart';
import 'package:cleanconnect/presentation/customer/pemesanan/pemesanan_screen.dart';
import 'package:cleanconnect/presentation/customer/camera/native_camera.dart';
import 'package:cleanconnect/presentation/customer/camera/storage_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class PemesananFormPage extends StatefulWidget {
  const PemesananFormPage({super.key});

  @override
  State<PemesananFormPage> createState() => _PemesananFormPageState();
}

class _PemesananFormPageState extends State<PemesananFormPage> {
  late final TextEditingController namaController;
  late final TextEditingController noTlpController;
  late final TextEditingController alamatController;
  late final TextEditingController deskripsiController;
  late final TextEditingController hargaController;
  late final TextEditingController tanggalPesanController;
  late final TextEditingController jamController;

  final _formKey = GlobalKey<FormState>();

  // Map layanan dengan harga
  final Map<String, int> layananHarga = {
    'Pembersihan Rumah': 150000,
    'Pembersihan Kantor': 200000,
    'Pembersihan Setelah Renovasi': 300000,
    'Pembersihan Kaca dan Jendela': 100000,
    'Pembersihan Eksterior Rumah': 250000,
  };

  String? selectedLayanan;
  String? selectedAddress; // Untuk menyimpan alamat dari map
  File? _imageFile; // Untuk menyimpan gambar

  @override
  void initState() {
    namaController = TextEditingController();
    noTlpController = TextEditingController();
    alamatController = TextEditingController();
    deskripsiController = TextEditingController();
    hargaController = TextEditingController();
    tanggalPesanController = TextEditingController();
    jamController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    namaController.dispose();
    noTlpController.dispose();
    alamatController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    tanggalPesanController.dispose();
    jamController.dispose();
    super.dispose();
  }

  void _updateHarga(String? layanan) {
    if (layanan != null && layananHarga.containsKey(layanan)) {
      hargaController.text = layananHarga[layanan].toString();
    } else {
      hargaController.clear();
    }
  }

  String _formatCurrency(int amount) {
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // Method untuk membuka map picker
  Future<void> _openMapPicker() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapPage(),
        ),
      );

      if (result != null && result is String) {
        setState(() {
          selectedAddress = result;
          alamatController.text = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alamat berhasil dipilih dari map'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka map: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method untuk request permission
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  // Method untuk mengambil foto dengan kamera
  Future<void> _takePicture() async {
    await _requestPermissions();
    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
    if (result != null) {
      final saved = await StorageHelper.saveImage(result, 'camera');
      setState(() => _imageFile = saved);
      _showSnackBar('Foto berhasil disimpan!', Colors.green);
    }
  }

  // Method untuk memilih dari galeri
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final saved = await StorageHelper.saveImage(File(picked.path), 'gallery');
      setState(() => _imageFile = saved);
      _showSnackBar('Gambar berhasil dipilih!', Colors.green);
    }
  }

  // Method untuk menghapus gambar
  void _deleteImage() async {
    await _imageFile?.delete();
    setState(() => _imageFile = null);
    _showSnackBar('Gambar berhasil dihapus', Colors.red);
  }

  // Method untuk menampilkan snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget untuk tombol aksi gambar
  Widget _buildImageActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk preview gambar
  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              _imageFile!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: _deleteImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk empty state gambar
  Widget _buildImageEmptyState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Belum ada gambar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ambil foto atau pilih dari galeri',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pemesanan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpaceHeight(30),
                CustomTextField(
                  controller: namaController,
                  label: 'Nama Lengkap',
                  validator: 'Nama tidak boleh kosong',
                ),
                const SpaceHeight(16),
                CustomTextField(
                  controller: noTlpController,
                  label: 'Nomor Telepon',
                  validator: 'Nomor telepon tidak boleh kosong',
                  keyboardType: TextInputType.phone,
                ),
                const SpaceHeight(16),
                
                // Alamat Field dengan Map Integration
                Text(
                  'Alamat Lengkap',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SpaceHeight(8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      // Text field untuk alamat
                      CustomTextField(
                        controller: alamatController,
                        label: 'Ketik alamat atau pilih dari map',
                        validator: 'Alamat tidak boleh kosong',
                        maxLines: 3,
                        showLabel: false,
                      ),
                      // Tombol untuk membuka map
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, 
                                 color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedAddress != null 
                                    ? 'Alamat dipilih dari map'
                                    : 'Tap untuk pilih dari map',
                                style: TextStyle(
                                  color: selectedAddress != null 
                                      ? Colors.green.shade700
                                      : AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openMapPicker,
                              icon: Icon(Icons.map, size: 18),
                              label: Text('Buka Map'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Show selected address preview
                if (selectedAddress != null) ...[
                  const SpaceHeight(8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, 
                             color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alamat dari Map:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedAddress!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedAddress = null;
                              alamatController.clear();
                            });
                          },
                          icon: Icon(Icons.clear, 
                                   color: Colors.green.shade600, size: 18),
                          tooltip: 'Hapus alamat map',
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SpaceHeight(16),
                
                // Section untuk Upload Gambar
                Text(
                  'Gambar Lokasi (Opsional)',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SpaceHeight(8),
                
                // Tombol untuk kamera dan galeri
                Row(
                  children: [
                    Expanded(
                      child: _buildImageActionButton(
                        Icons.camera_alt,
                        'Ambil Foto',
                        Colors.blue.shade600,
                        _takePicture,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImageActionButton(
                        Icons.photo_library,
                        'Pilih Galeri',
                        Colors.purple.shade600,
                        _pickFromGallery,
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                
                // Preview gambar atau empty state
                _imageFile != null ? _buildImagePreview() : _buildImageEmptyState(),
                
                // Status gambar
                if (_imageFile != null) ...[
                  const SpaceHeight(8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, 
                             color: Colors.green.shade600, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Gambar berhasil disimpan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SpaceHeight(16),
                Text(
                  'Jenis Layanan',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SpaceHeight(8),
                DropdownButtonFormField2<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  hint: const Text(
                    'Pilih Jenis Layanan',
                    style: TextStyle(fontSize: 14),
                  ),
                  items: layananHarga.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _formatCurrency(entry.value),
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Jenis layanan tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedLayanan = value;
                      _updateHarga(value);
                    });
                  },
                  onSaved: (value) {
                    selectedLayanan = value.toString();
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 8),
                    height: 60,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
                    iconSize: 24,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    maxHeight: 300,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 60,
                  ),
                ),
                const SpaceHeight(16),
                CustomTextField(
                  controller: hargaController,
                  label: 'Harga Layanan',
                  validator: 'Harga tidak boleh kosong',
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                ),
                const SpaceHeight(16),
                CustomTextField(
                  controller: tanggalPesanController,
                  label: 'Tanggal Pemesanan',
                  validator: 'Tanggal pemesanan tidak boleh kosong',
                  readOnly: true,
                  suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2025, 12, 31),
                    );
                    if (picked != null) {
                      tanggalPesanController.text = 
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SpaceHeight(16),
                CustomTextField(
                  controller: jamController,
                  label: 'Jam Pemesanan',
                  validator: 'Jam pemesanan tidak boleh kosong',
                  readOnly: true,
                  suffixIcon: Icon(Icons.access_time, color: AppColors.primary),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      jamController.text = 
                          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SpaceHeight(16),
                CustomTextField(
                  controller: deskripsiController,
                  label: 'Deskripsi Tambahan',
                  maxLines: 3,
                  validator: 'Deskripsi Tidak Boleh Kosong',
                ),
                const SpaceHeight(32),
                BlocConsumer<PemesananCustomerBloc, PemesananCustomerState>(
                  listener: (context, state) {
                    if (state is PemesananCustomerAddSuccessState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.responseModel.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pushAndRemoveUntil(
                        const CustomerMainPage(),
                        (route) => false,
                      );
                    } else if (state is PemesananCustomerErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Button.filled(
                      onPressed: state is PemesananCustomerLoadingState
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (selectedLayanan == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pilih jenis layanan terlebih dahulu'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                // Gunakan alamat dari map jika tersedia, jika tidak gunakan yang diketik manual
                                final finalAddress = selectedAddress ?? alamatController.text;
                                
                                if (finalAddress.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Alamat tidak boleh kosong'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                final pemesananRequest = PemesananCustomerRequestModel(
                                  nama: namaController.text,
                                  noTlp: noTlpController.text,
                                  alamat: finalAddress, // Menggunakan alamat yang sudah dipilih dari map atau diketik manual
                                  deskripsi: deskripsiController.text.isEmpty 
                                      ? null 
                                      : deskripsiController.text,
                                  layanan: selectedLayanan!,
                                  harga: hargaController.text,
                                  tanggalPesan: DateTime.parse(tanggalPesanController.text),
                                  jam: jamController.text,
                                  // Tambahkan gambar jika ada
                                  // gambar: _imageFile?.path, // Uncomment jika model mendukung gambar
                                );

                                context.read<PemesananCustomerBloc>().add(
                                  PemesananCustomerAddEvent(pemesananRequest),
                                );
                              }
                            },
                      label: state is PemesananCustomerLoadingState 
                          ? "Menyimpan..." 
                          : "Simpan Pemesanan",
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}