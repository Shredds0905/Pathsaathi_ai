import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';

/// PathSaathi AI — Auth Provider
/// Manages authentication state across the app.

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _user?.role == 'guest';

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    try {
      // Listen to Firebase auth state changes
      _authService.authStateChanges.listen(
        (User? firebaseUser) async {
          try {
            if (firebaseUser == null) {
              _status = AuthStatus.unauthenticated;
              _user = null;
            } else {
              // Load user data from Firestore
              final userModel =
                  await _firestoreService.getUser(firebaseUser.uid);
              _user = userModel;
              _status = AuthStatus.authenticated;
            }
          } catch (_) {
            _status = AuthStatus.unauthenticated;
            _user = null;
          }
          notifyListeners();
        },
        onError: (_) {
          // Firebase unavailable (e.g. no config in dev mode)
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        },
      );
    } catch (_) {
      // Firebase not initialized at all — run in demo mode
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _status = AuthStatus.authenticated;
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Registration ──────────────────────────────────────────────────────────

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _status = AuthStatus.authenticated;
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      _status = AuthStatus.authenticated;
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getErrorMessage(e));
      return false;
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        _clearError();
        return false;
      }
      _setError('Google sign-in failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Guest Login ───────────────────────────────────────────────────────────

  Future<bool> signInAsGuest() async {
    _setLoading(true);
    try {
      _user = await _authService.signInAsGuest();
      _status = AuthStatus.authenticated;
      _clearError();
      return true;
    } catch (e) {
      // Firebase unavailable — use local demo guest account
      _user = UserModel(
        uid: 'demo-guest-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest Learner',
        email: '',
        role: 'guest',
        createdAt: DateTime.now(),
        isOnboardingDone: true,
        totalXp: 120,
        level: 1,
        currentStreak: 3,
      );
      _status = AuthStatus.authenticated;
      _clearError();
      return true;
    } finally {
      _setLoading(false);
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(FirebaseAuthService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  // ── Update User ───────────────────────────────────────────────────────────

  Future<void> updateUserData(UserModel updatedUser) async {
    _user = updatedUser;
    await _firestoreService.updateUser(updatedUser);
    notifyListeners();
  }

  Future<void> markOnboardingDone() async {
    if (_user == null) return;
    final updated = _user!.copyWith(isOnboardingDone: true);
    await updateUserData(updated);
  }

  Future<void> updateLanguage(String languageCode) async {
    if (_user == null) return;
    final updated = _user!.copyWith(language: languageCode);
    await updateUserData(updated);
  }

  Future<void> addXp(int xp) async {
    if (_user == null) return;
    final newXp = _user!.totalXp + xp;
    final newLevel = (newXp ~/ 500) + 1;
    final updated = _user!.copyWith(totalXp: newXp, level: newLevel);
    await updateUserData(updated);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
