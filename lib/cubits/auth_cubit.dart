import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User firebaseUser;
  final UserModel userDetails;

  Authenticated({required this.firebaseUser, required this.userDetails});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit(this._authService) : super(AuthInitial()) {
    // Monitor auth changes
    _authSubscription = _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        emit(Unauthenticated());
      } else {
        emit(AuthLoading());
        final details = await _authService.getUserDetails(user.uid);
        if (details != null) {
          emit(Authenticated(firebaseUser: user, userDetails: details));
        } else {
          // If Firestore details are missing, emit with fallback
          final fallbackDetails = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            username: user.email?.split('@')[0] ?? 'User',
            profilePictureUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=${user.uid}',
            bio: 'مرحباً بك في HM ليبيا!',
          );
          emit(Authenticated(firebaseUser: user, userDetails: fallbackDetails));
        }
      }
    });
  }

  // Login action
  Future<void> loginUser(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.login(email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // Register action
  Future<void> registerUser(String email, String password, String username) async {
    emit(AuthLoading());
    try {
      await _authService.register(email, password, username: username);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // Logout action
  Future<void> logoutUser() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
