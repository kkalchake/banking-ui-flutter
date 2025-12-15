// lib/state/auth_model.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Although not used here, often needed with Provider
import 'package:flutter_banking_app_ui/models/account.dart';
import 'package:flutter_banking_app_ui/services/api_service.dart';

// This is the core state management class for the entire application.
class AuthModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- State Variables ---
  String? _username;
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _message;

  // --- Getters (Read-only access for UI) ---
  String? get username => _username;
  bool get isAuthenticated => _username != null;
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get message => _message;

  // --- Helper: Message/Feedback Management ---

  void setMessage(String msg) {
    _message = msg;
    notifyListeners();
    // Clears the message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_message == msg) { // Only clear if it hasn't been replaced
        _message = null;
        notifyListeners();
      }
    });
  }

  // --- CORE LOGIN/REGISTER LOGIC ---

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.authenticate(username, password, false);
    
    if (response == "Login success") {
      _username = username;
      // Fetch accounts immediately after successful login
      await _fetchUserAccounts(username); 
      setMessage('Login successful.');
    } else {
      _username = null;
      _accounts = [];
      setMessage(response.contains("Invalid") ? 'Invalid username or password.' : 'Login failed. Please register.');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.authenticate(username, password, true);

    if (response == "Registered") {
      _username = username;
      // Fetch accounts (should be an empty list initially unless the backend auto-creates)
      await _fetchUserAccounts(username); 
      setMessage('Registered and logged in!');
    } else {
      _username = null;
      _accounts = [];
      setMessage('Registration failed. ${response.contains("exists") ? "User already exists." : "Try a different username."}');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- ACCOUNT MANAGEMENT ---

  // Fetches accounts from the backend and updates the state.
  Future<void> _fetchUserAccounts(String username) async {
    _accounts = await _apiService.fetchAccounts(username);
    notifyListeners();
  }
  
  // Refreshes the account list for the current user.
  Future<void> refreshAccounts() async {
      if (_username != null) {
          await _fetchUserAccounts(_username!);
      }
  }

  Future<void> createAccount() async {
    if (_username == null) return;
    _isLoading = true;
    notifyListeners();

    // The backend's /account endpoint returns the account number on success.
    final response = await _apiService.processTransaction(
      '/account', 
      {'username': _username!},
    );
    
    // We check if the response starts with a UUID (an account number is returned).
    // Note: This relies on the backend returning a non-error string as the accNum.
    if (!response.contains("No such user") && response.length > 10) { 
      await _fetchUserAccounts(_username!); // Refresh the list to include the new account
      setMessage('Account created successfully: $response');
    } else {
      setMessage('Account creation failed.');
    }

    _isLoading = false;
    notifyListeners();
  }


  // --- TRANSACTION LOGIC ---
  
  Future<void> deposit(String accNum, String amountStr) async {
    await _handleTransaction('/deposit', {'accNum': accNum, 'amount': amountStr});
  }

  Future<void> withdraw(String accNum, String amountStr) async {
    await _handleTransaction('/withdraw', {'accNum': accNum, 'amount': amountStr});
  }

  Future<void> transfer(String fromAcc, String toAcc, String amountStr) async {
    await _handleTransaction('/transfer', {
      'from': fromAcc, 
      'to': toAcc, 
      'amount': amountStr
    });
  }
  
  // Consolidated Handler for all financial operations
  Future<void> _handleTransaction(String endpoint, Map<String, dynamic> params) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _apiService.processTransaction(endpoint, params);
    
    // Check for success keywords from the Java backend
    if (response.contains("Deposited") || response.contains("Withdrawn") || response.contains("Transferred")) {
      await _fetchUserAccounts(_username!); // Refresh balances on success
      setMessage('${endpoint.substring(1)} successful!');
    } else {
      // Show the exact error message from the backend (e.g., "Insufficient funds")
      setMessage('${endpoint.substring(1)} failed: $response');
    }
    
    _isLoading = false;
    notifyListeners();
  }


  // --- LOGOUT ---
  void logout() {
    _username = null;
    _accounts = [];
    setMessage('Logged out successfully.');
    notifyListeners();
  }
}