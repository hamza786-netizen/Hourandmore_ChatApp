import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final BiometricService _biometricService = BiometricService.instance;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get biometricAvailable => _biometricAvailable;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    // Check biometric availability
    _biometricAvailable = await _biometricService.isBiometricAvailable();
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  // Load user data
  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _authService.getUserData(uid);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _errorMessage = 'Registration failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    bool saveBiometric = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        
        // Save credentials for biometric login if requested
        if (saveBiometric && _biometricAvailable) {
          await _biometricService.saveCredentials(
            email: email,
            password: password,
          );
          await _authService.setBiometricEnabled(user.uid, true);
          _currentUser = _currentUser?.copyWith(biometricEnabled: true);
        }

        _setLoading(false);
        return true;
      }

      _errorMessage = 'Sign in failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign in with biometric
  Future<bool> signInWithBiometric() async {
    if (!_biometricAvailable) {
      _errorMessage = 'Biometric authentication not available';
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Check if credentials are saved
      final hasCredentials = await _biometricService.hasCredentials();
      if (!hasCredentials) {
        _errorMessage = 'No saved credentials for biometric login';
        _setLoading(false);
        return false;
      }

      // Authenticate with biometric
      final authenticated = await _biometricService.authenticateWithBiometrics(
        reason: 'Authenticate to sign in',
      );

      if (!authenticated) {
        _errorMessage = 'Biometric authentication failed';
        _setLoading(false);
        return false;
      }

      // Get saved credentials
      final credentials = await _biometricService.getCredentials();
      if (credentials == null) {
        _errorMessage = 'Failed to retrieve credentials';
        _setLoading(false);
        return false;
      }

      // Sign in with saved credentials
      return await signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  // Enable biometric authentication
  Future<bool> enableBiometric(String password) async {
    if (!_biometricAvailable || _currentUser == null) return false;

    try {
      // Verify password first
      final success = await signIn(
        email: _currentUser!.email,
        password: password,
        saveBiometric: true,
      );

      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Disable biometric authentication
  Future<bool> disableBiometric() async {
    if (_currentUser == null) return false;

    try {
      await _biometricService.deleteCredentials();
      await _authService.setBiometricEnabled(_currentUser!.uid, false);
      _currentUser = _currentUser?.copyWith(biometricEnabled: false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}


