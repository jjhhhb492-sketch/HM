import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cubits/auth_cubit.dart';
import 'cubits/video_cubit.dart';
import 'services/auth_service.dart';
import 'services/video_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('تنبيه Firebase: لم يتم إعداد ملفات التكوين بعد: $e');
  }
  runApp(HMLibya());
}

class HMLibya extends StatelessWidget {
  HMLibya({super.key});

  final AuthService _authService = AuthService();
  final VideoService _videoService = VideoService();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(_authService),
        ),
        BlocProvider<VideoCubit>(
          create: (context) => VideoCubit(_videoService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HM ليبيا',
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            secondary: Colors.blueAccent,
            surface: Colors.black87,
          ),
          scaffoldBackgroundColor: Colors.black,
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        home: const AuthStateRouter(),
      ),
    );
  }
}

class AuthStateRouter extends StatelessWidget {
  const AuthStateRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        } else if (state is Unauthenticated) {
          return const LoginScreen();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        } else {
          // Fallback splash or login page
          return const LoginScreen();
        }
      },
    );
  }
}
