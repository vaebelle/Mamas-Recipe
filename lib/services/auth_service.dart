import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Password validation function
  String? validatePassword(String password) {
    List<String> errors = [];

    if (password.length < 6) {
      errors.add("Password must be at least 6 characters long");
    }

    if (password.length > 4096) {
      errors.add("Password must not exceed 4096 characters");
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add("Password must contain at least one uppercase letter");
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add("Password must contain at least one lowercase letter");
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add("Password must contain at least one number");
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add("Password must contain at least one special character");
    }

    if (errors.isNotEmpty) {
      return errors.join("\n");
    }

    return null;
  }

  // Check if email exists in Firebase Auth
  Future<bool> checkEmailExists(String email) async {
    try {
      final signInMethods = await firebaseAuth.fetchSignInMethodsForEmail(
        email,
      );
      return signInMethods.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking email existence: $e");
      return false;
    }
  }

  Future<UserCredential?> loginWithGoogle() async {
    try {
      // Sign out from Google first to ensure account picker shows
      await googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled by user");
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      debugPrint("Google Sign-In successful: ${userCredential.user?.email}");
      return userCredential;
    } catch (e) {
      debugPrint("Google Sign-In failed: $e");
      return null;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password,
      );
    } catch (e) {
      debugPrint("Sign-in error: $e");
      rethrow;
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: passwordError,
      );
    }

    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password,
      );
    } catch (e) {
      debugPrint("Account creation error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint("Sign-out error: $e");
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint("Reset password error: $e");
      rethrow;
    }
  }

  Future<void> updateEmail({required String username}) async {
    try {
      await currentUser!.updateDisplayName(username);
    } catch (e) {
      debugPrint("Update email error: $e");
      rethrow;
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      // Re-authenticate the user before deleting the account
      AuthCredential credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint("Delete account error: $e");
      rethrow;
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      // Validate new password
      final passwordError = validatePassword(newPassword);
      if (passwordError != null) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: passwordError,
        );
      }

      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update the password
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      debugPrint("Reset password from current password error: $e");
      rethrow;
    }
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return e.message ?? 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
