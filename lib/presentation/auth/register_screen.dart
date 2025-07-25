import 'package:cleanconnect/core/components/custom_text_field.dart';
import 'package:cleanconnect/core/components/spaces.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/data/model/request/auth/register_request_model.dart';
import 'package:cleanconnect/presentation/auth/bloc/register/register_bloc.dart';
import 'package:cleanconnect/presentation/auth/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController namaController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> _key;
  bool isShowPassword = false;

  @override
  void initState() {
    namaController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _key = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _key.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpaceHeight(80),
                // Tambahan gambar di sini
                Image.asset(
                  'assets/images/logo1.png', // Ganti dengan path gambar Anda
                  width: 200,
                  height: 200,
                ),
                const SpaceHeight(10),
                Text(
                  'DAFTAR AKUN BARU',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SpaceHeight(30),
                CustomTextField(
                  controller: namaController, 
                  label: 'Username', 
                  validator: 'Username tidak boleh kosong',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.person),
                  ),
                ),
                const SpaceHeight(25),
                CustomTextField(
                  controller: emailController, 
                  label: 'Email', 
                  validator: 'Email tidak boleh kosong',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.email),
                  ),
                ),
                const SpaceHeight(25),
                CustomTextField(
                  controller: passwordController, 
                  label: 'Password', 
                  validator: 'Password tidak boleh kosong',
                  obscureText: !isShowPassword,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.lock),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(isShowPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isShowPassword = !isShowPassword;
                      });
                    },
                  ),
                ),
                const SpaceHeight(30),
                BlocConsumer<RegisterBloc, RegisterState>(
                  listener: (context, state){
                    if (state is RegisterSuccess){
                      context.pushAndRemoveUntil(
                        const LoginScreen(),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    } else if (state is RegisterFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Button.filled(
                      onPressed: state is RegisterLoading
                          ? null
                          : () {
                              if (_key.currentState!.validate()) {
                                final request = RegisterRequestModel(
                                  username: namaController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                                context.read<RegisterBloc>().add(
                                  RegisterRequested(requestModel: request),
                                );
                              }
                            },
                      label: state is RegisterLoading ? 'Memuat...' : 'Daftar',
                    );
                  },
                ),

                const SpaceHeight(20),
                Text.rich(
                  TextSpan(
                    text: 'sudah memiliki akun? Silahkan ',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                    ),
                    children: [
                      TextSpan(
                        text: 'Login disini!',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pushAndRemoveUntil(
                              const LoginScreen(),
                              (route) => false,
                            );
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}