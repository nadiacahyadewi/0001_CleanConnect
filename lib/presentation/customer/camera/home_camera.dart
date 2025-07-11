import 'dart:io';
import 'package:cleanconnect/presentation/customer/camera/native_camera.dart';
import 'package:cleanconnect/presentation/customer/camera/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

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

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final saved = await StorageHelper.saveImage(File(picked.path), 'gallery');
      setState(() => _imageFile = saved);
      _showSnackBar('Gambar berhasil dipilih!', Colors.green);
    }
  }

  void _deleteImage() async {
    await _imageFile?.delete();
    setState(() => _imageFile = null);
    _showSnackBar('Gambar berhasil dihapus', Colors.red);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'PlantApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // <- Tambahkan ini
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C9869), Color(0xFF0C9869)],
            ),
          ),
        ),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    Icons.camera_alt,
                    'Ambil Foto',
                    Colors.blue.shade600,
                    _takePicture,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    Icons.photo_library,
                    'Pilih Galeri',
                    Colors.purple.shade600,
                    _pickFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Image Section
            Expanded(
              child:
                  _imageFile != null
                      ? _buildImagePreview()
                      : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _deleteImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0C9869),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Gambar berhasil disimpan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
  return Container(
    padding: const EdgeInsets.only(),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(0),
      // border: Border.all(color: Colors.grey.shade200, width: 2), // HAPUS ATAU KOMENTAR INI
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('Belum ada foto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Text('Ambil foto atau pilih dari galeri', style: TextStyle(fontSize: 13, color: Colors.grey.shade500), textAlign: TextAlign.center),
      ],
    ),
  );
}


}
