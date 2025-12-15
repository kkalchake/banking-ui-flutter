// lib/models/account.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';

class Account {
  final String accNum;
  final String owner;
  final double balance; // Use double for flutter, handle BigDecimal conversion here

  Account({
    required this.accNum, 
    required this.owner, 
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    // The backend returns 'balance' as a String (from BigDecimal.toString()) or a number.
    // We convert it robustly to a double for Flutter.
    double parsedBalance;
    try {
      if (json['balance'] is String) {
        parsedBalance = double.parse(json['balance']);
      } else {
        parsedBalance = (json['balance'] as num).toDouble();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing balance: ${json['balance']}');
      }
      parsedBalance = 0.0;
    }

    return Account(
      accNum: json['accNum'] as String, 
      owner: json['owner'] as String, 
      balance: parsedBalance,
    );
  }
}