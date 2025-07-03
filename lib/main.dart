import 'package:cleanconnect/data/repository/auth_repository.dart';
import 'package:cleanconnect/data/repository/profile_admin_repository.dart';
import 'package:cleanconnect/data/repository/profile_customer_repository.dart';
import 'package:cleanconnect/presentation/admin/profile/bloc/add_profile/add_profile_bloc.dart';
import 'package:cleanconnect/presentation/admin/profile/bloc/get_profile/get_profile_bloc.dart';
import 'package:cleanconnect/presentation/auth/bloc/login/login_bloc.dart';
import 'package:cleanconnect/presentation/auth/bloc/register/register_bloc.dart';
import 'package:cleanconnect/presentation/auth/login_screen.dart';
import 'package:cleanconnect/presentation/customer/profile/bloc/profile_customer_bloc.dart';
import 'package:cleanconnect/services/service_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LoginBloc(authRepository: AuthRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create: (context) =>
              RegisterBloc(authRepository: AuthRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create: (context) => ProfileBuyerBloc(
            profileBuyerRepository: ProfileBuyerRepository(ServiceHttpClient()),
          ),
        ),
        BlocProvider(
          create: (context) =>
              AddProfileBloc(PrifileAdminRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create: (context) =>
              GetProfileBloc(PrifileAdminRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create: (context) =>
              GetProfileBloc(PrifileAdminRepository(ServiceHttpClient())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: LoginScreen(),
      ),
    );
  }
}

