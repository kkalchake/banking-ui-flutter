// lib/services/api_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_banking_app_ui/models/account.dart';
import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb

// --- Configuration: Define the API URL ---
// This is the CRITICAL block for local connectivity.
// It ensures the correct IP is used based on the running environment.
final String _apiBaseUrl = (kIsWeb || Platform.isIOS || Platform.isMacOS) 
    // Fix for Web: Use 127.0.0.1 for reliable connection from the browser to the host machine.
    ? 'http://127.0.0.1:8080/api' // Web, iOS Simulator, and macOS
    : 'http://10.0.2.2:8080/api'; // Android Emulator loopback IP

class ApiService {
  // --- LOGIN and REGISTER ---

  Future<String> authenticate(String username, String password, bool isRegister) async {
    final endpoint = isRegister ? '/register' : '/login';
    final uri = Uri.parse('$_apiBaseUrl$endpoint?username=$username&password=$password');

    try {
      final response = await http.post(uri);
      
      // Backend returns status 200 for everything, so we rely on the body content.
      final responseBody = response.body.trim();

      if (kDebugMode) {
        print('Authentication request sent to: $uri');
        print('Authentication response: $responseBody');
      }
      
      return responseBody; // Returns "Login success", "Invalid credentials", or "User exists"
      
    } catch (e) {
      if (kDebugMode) {
        print('API Error on $endpoint: $e');
      }
      return 'Network Error: Could not connect to server.';
    }
  }

  // --- ACCOUNT FETCHING (Using the /accounts/details endpoint) ---
  Future<List<Account>> fetchAccounts(String username) async {
    final uri = Uri.parse('$_apiBaseUrl/accounts/details?username=$username');

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        // The backend returns a JSON array of account details
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Account.fromJson(json)).toList();
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('API Error fetching accounts: $e');
      }
    }
    return []; // Return an empty list on failure
  }

  // --- TRANSACTION API (Consolidated) ---
  Future<String> processTransaction(String endpoint, Map<String, dynamic> params) async {
    final uri = Uri.parse('$_apiBaseUrl$endpoint').replace(queryParameters: {
      for (var key in params.keys) 
        key: params[key]?.toString() // Ensure all values are strings for URL encoding
    });

    try {
      final response = await http.post(uri);
      // Backend returns a success or error message string.
      return response.body.trim(); 
    } catch (e) {
      if (kDebugMode) {
        print('Transaction API Error: $e');
      }
      return 'Network Error: Failed to complete transaction.';
    }
  }
}