import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// PathSaathi AI — Firebase Authentication Service
/// Handles: Email/Password, Google Sign-In, Guest mode, Forgot Password

class FirebaseAuthService {
  // Use late to avoid crashing if Firebase is not yet initialized
  FirebaseAuth? _authInstance;
  FirebaseAuth get _auth {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized');
    }
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }
  
  bool get _isFirebaseReady { if (AppConstants.useMockData) return false; try { return Firebase.apps.isNotEmpty; } catch (_) { return false; } }

  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn {
    _googleSignInInstance ??= GoogleSignIn();
    return _googleSignInInstance!;
  }

  final FirestoreService _firestoreService = FirestoreService();

  // ── Current User ──────────────────────────────────────────────────────────

  User? get currentUser => _isFirebaseReady ? _authInstance?.currentUser : null;
  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _isFirebaseReady ? _auth.authStateChanges() : Stream.empty();

  // ── Email / Password Login ────────────────────────────────────────────────

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (AppConstants.useMockData || !_isFirebaseReady) {
      // Local fallback for hackathon demo if Firebase isn't configured
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('local_user_email');
      final savedPass = prefs.getString('local_user_password');
      if (savedEmail == email.trim() && savedPass == password) {
        final uid = prefs.getString('local_user_uid') ?? 'local_${DateTime.now().millisecondsSinceEpoch}';
        if (rememberMe) await _saveLoginPreference(uid);
        return UserModel(
          uid: uid,
          name: prefs.getString('local_user_name') ?? 'User',
          email: email,
          role: prefs.getString('local_user_role') ?? 'student',
          createdAt: DateTime.now(),
        );
      }
      throw Exception('No account found or incorrect password.');
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Login failed. Please try again.');
    }

    if (rememberMe) {
      await _saveLoginPreference(credential.user!.uid);
    }

    final userModel = await _firestoreService.getUser(credential.user!.uid);
    return userModel ?? _createDefaultUser(credential.user!, email, 'email');
  }

  // ── Email / Password Registration ─────────────────────────────────────────

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (AppConstants.useMockData || !_isFirebaseReady) {
      // Local fallback for hackathon demo
      final prefs = await SharedPreferences.getInstance();
      final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('local_user_uid', uid);
      await prefs.setString('local_user_name', name);
      await prefs.setString('local_user_email', email.trim());
      await prefs.setString('local_user_password', password);
      await prefs.setString('local_user_role', role);
      await _saveLoginPreference(uid);
      
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    // Update display name
    await credential.user!.updateDisplayName(name);

    // Create Firestore user document
    final userModel = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(userModel);
    await _saveLoginPreference(credential.user!.uid);

    return userModel;
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<UserModel> signInWithGoogle() async {
    if (AppConstants.useMockData || !_isFirebaseReady) {
      // Mock Google Login for Hackathon
      final uid = 'google_mock_${DateTime.now().millisecondsSinceEpoch}';
      await _saveLoginPreference(uid);
      return UserModel(
        uid: uid,
        name: 'Google User',
        email: 'user@gmail.com',
        role: 'student',
        createdAt: DateTime.now(),
      );
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In cancelled.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user == null) {
      throw Exception('Google login failed. Please try again.');
    }

    // Check if user exists in Firestore
    final existingUser = await _firestoreService.getUser(userCredential.user!.uid);
    if (existingUser != null) {
      await _saveLoginPreference(userCredential.user!.uid);
      return existingUser;
    }

    // Create new user document
    final userModel = UserModel(
      uid: userCredential.user!.uid,
      name: userCredential.user!.displayName ?? googleUser.displayName ?? 'User',
      email: userCredential.user!.email ?? googleUser.email,
      photoUrl: userCredential.user!.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(userModel);
    await _saveLoginPreference(userCredential.user!.uid);

    return userModel;
  }

  // ── Guest Login ───────────────────────────────────────────────────────────

  Future<UserModel> signInAsGuest() async {
    final credential = await _auth.signInAnonymously();

    if (credential.user == null) {
      throw Exception('Guest login failed.');
    }

    final guestUser = UserModel(
      uid: credential.user!.uid,
      name: 'Guest Learner',
      email: '',
      role: AppConstants.roleGuest,
      createdAt: DateTime.now(),
      isOnboardingDone: true,
    );

    return guestUser;
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    if (AppConstants.useMockData || !_isFirebaseReady) return;
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    if (_isFirebaseReady) {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserToken);
    await prefs.remove(AppConstants.prefUserId);
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    if (AppConstants.useMockData || !_isFirebaseReady) return;
    final user = currentUser;
    if (user != null) {
      await _firestoreService.deleteUser(user.uid);
      await user.delete();
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  Future<void> updateDisplayName(String name) async {
    if (AppConstants.useMockData || !_isFirebaseReady) return;
    await currentUser?.updateDisplayName(name);
  }

  Future<void> updateEmail(String newEmail) async {
    if (AppConstants.useMockData || !_isFirebaseReady) return;
    await currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    if (AppConstants.useMockData || !_isFirebaseReady) return;
    final user = currentUser;
    if (user == null || user.email == null) {
      throw Exception('Not authenticated.');
    }

    // Re-authenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveLoginPreference(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserId, uid);
    await prefs.setBool(AppConstants.prefRememberLogin, true);
  }

  UserModel _createDefaultUser(
      User user, String email, String provider) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'Learner',
      email: email,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
  }

  /// Check if user has previously logged in (for auto-login)
  Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefRememberLogin) ?? false;
  }

  /// Get saved user ID
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserId);
  }

  // ── Error Message Helpers ─────────────────────────────────────────────────

  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
