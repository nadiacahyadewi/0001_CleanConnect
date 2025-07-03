import 'package:cleanconnect/core/components/custom_text_field.dart';
import 'package:cleanconnect/core/components/spaces.dart';
import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/data/model/request/customer/customer_profile_request_model.dart';
import 'package:cleanconnect/presentation/customer/profile/bloc/profile_customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBuyerForm extends StatefulWidget {
  const ProfileBuyerForm({super.key});

  @override
  State<ProfileBuyerForm> createState() => ProfileBuyerInputFormState();
}

class ProfileBuyerInputFormState extends State<ProfileBuyerForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBuyerBloc, ProfileBuyerState>(
      builder: (context, state) {
        final isLoading = state is ProfileBuyerLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SpaceHeight(60),
                    
                    // Header Section
                    Center(
                      child: Column(
                        children: [
                          // Logo atau Icon Profil
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                          const SpaceHeight(20),
                          Text(
                            'LENGKAPI PROFIL ANDA',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SpaceHeight(8),
                          Text(
                            'Isi data profil untuk melanjutkan',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SpaceHeight(40),
                    
                    // Form Fields
                    CustomTextField(
                      validator: 'Nama tidak boleh kosong',
                      controller: nameController,
                      label: 'Nama Lengkap',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.person),
                      ),
                    ),
                    
                    const SpaceHeight(20),
                    
                    CustomTextField(
                      validator: 'Alamat tidak boleh kosong',
                      controller: addressController,
                      label: 'Alamat Lengkap',
                      maxLines: 3,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.location_on),
                      ),
                    ),
                    
                    const SpaceHeight(20),
                    
                    CustomTextField(
                      validator: 'Nomor HP tidak boleh kosong',
                      controller: phoneController,
                      label: 'Nomor HP',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.phone),
                      ),
                    ),
                    
                    const SpaceHeight(40),
                    
                    // Submit Button
                    BlocConsumer<ProfileBuyerBloc, ProfileBuyerState>(
                      listener: (context, state) {
                        if (state is ProfileBuyerAdded) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.profile.message),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          
                          // Clear form setelah berhasil simpan
                          nameController.clear();
                          addressController.clear();
                          phoneController.clear();
                          
                          // Optional: Refresh profile data
                          context.read<ProfileBuyerBloc>().add(
                            GetProfileBuyerEvent(),
                          );
                          
                          // Optional: Navigate to profile view or stay in current page
                          // Navigator.of(context).pop(); // Uncomment jika ingin kembali ke halaman sebelumnya
                          
                        } else if (state is ProfileBuyerError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Button.filled(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final request = CustomerProfileRequestModel(
                                      name: nameController.text.trim(),
                                      address: addressController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      photo: "",
                                    );
                                    context.read<ProfileBuyerBloc>().add(
                                      AddProfileBuyerEvent(requestModel: request),
                                    );
                                  }
                                },
                          label: isLoading ? 'Menyimpan...' : 'Simpan Profil',
                        );
                      },
                    ),
                    
                    const SpaceHeight(20),
                    
                    // Info Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pastikan data yang Anda masukkan sudah benar dan lengkap',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SpaceHeight(30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}