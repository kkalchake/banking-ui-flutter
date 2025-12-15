// lib/screens/transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_banking_app_ui/state/auth_model.dart';
import 'package:flutter_banking_app_ui/models/account.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // State for inputs and dropdown selections
  String? _selectedFromAccNum;
  String? _selectedToAccNum;
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set the initial 'From Account' to the first account available
    final accounts = Provider.of<AuthModel>(context, listen: false).accounts;
    if (accounts.isNotEmpty) {
      _selectedFromAccNum = accounts.first.accNum;
    }
  }

  // --- Core Transaction Handler ---
  void _handleTransaction(BuildContext context, AuthModel authModel, String type) {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    final amountStr = _amountController.text.trim();
    final fromAcc = _selectedFromAccNum;
    final toAcc = _selectedToAccNum;
    
    // Safety checks
    if (fromAcc == null || amountStr.isEmpty) return;

    // Execute the appropriate transaction
    switch (type) {
      case 'deposit':
        authModel.deposit(fromAcc, amountStr);
        break;
      case 'withdraw':
        authModel.withdraw(fromAcc, amountStr);
        break;
      case 'transfer':
        if (toAcc == null) {
          authModel.setMessage('Please select a recipient account for transfer.');
          return;
        }
        if (fromAcc == toAcc) {
          authModel.setMessage('Cannot transfer to the same account.');
          return;
        }
        authModel.transfer(fromAcc, toAcc, amountStr);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        final accounts = authModel.accounts;
        final selectedFromAccount = accounts.firstWhere(
          (acc) => acc.accNum == _selectedFromAccNum,
          orElse: () => accounts.isEmpty ? Account(accNum: 'N/A', owner: '', balance: 0.0) : accounts.first,
        );
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Centralized Transactions'),
            actions: [
               // Back button (matches your onBack logic)
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
          body: authModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Card( // Main Transaction Card
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Account Operations',
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const Divider(height: 32),

                              // 1. From Account Dropdown
                              _buildAccountDropdown(
                                context,
                                label: 'From Account:',
                                accounts: accounts,
                                selectedAccNum: _selectedFromAccNum,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFromAccNum = newValue;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              
                              // Display current balance
                              Text(
                                'Current Balance: \$${selectedFromAccount.balance.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: selectedFromAccount.balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 24),

                              // 2. Amount Input
                              TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  prefixIcon: Icon(Icons.money),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                                    return 'Please enter a positive amount.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // 3. Deposit/Withdraw Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _handleTransaction(context, authModel, 'deposit'),
                                      icon: const Icon(Icons.add_circle),
                                      label: const Text('Deposit'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _handleTransaction(context, authModel, 'withdraw'),
                                      icon: const Icon(Icons.remove_circle),
                                      label: const Text('Withdraw'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // 4. Transfer Section
                              Text(
                                'Transfer Funds',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),

                              // To Account Dropdown
                              _buildAccountDropdown(
                                context,
                                label: 'To Account:',
                                accounts: accounts.where((acc) => acc.accNum != _selectedFromAccNum).toList(), // Exclude "From" account
                                selectedAccNum: _selectedToAccNum,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedToAccNum = newValue;
                                  });
                                },
                                allowEmpty: true,
                              ),
                              const SizedBox(height: 16),
                              
                              // Transfer Button
                              FilledButton.icon(
                                onPressed: (_selectedToAccNum != null) 
                                    ? () => _handleTransaction(context, authModel, 'transfer') 
                                    : null,
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text('Transfer'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),

                              // Feedback Message
                              if (authModel.message != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Text(
                                    authModel.message!,
                                    style: TextStyle(
                                      color: authModel.message!.contains('successful') ? Colors.green : Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  // Widget builder for consistent dropdown appearance
  Widget _buildAccountDropdown(
    BuildContext context, {
    required String label,
    required List<Account> accounts,
    required String? selectedAccNum,
    required ValueChanged<String?> onChanged,
    bool allowEmpty = false,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: selectedAccNum,
      items: [
        if (allowEmpty)
          const DropdownMenuItem(value: null, child: Text('Select Account')),
        ...accounts.map((Account acc) {
          return DropdownMenuItem<String>(
            value: acc.accNum,
            child: Text('${acc.accNum.substring(0, 8)}... (\$${acc.balance.toStringAsFixed(2)})'),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }
}