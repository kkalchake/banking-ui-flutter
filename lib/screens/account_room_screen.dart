// lib/screens/account_room_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_banking_app_ui/state/auth_model.dart';
import 'package:flutter_banking_app_ui/screens/transaction_screen.dart'; // We will create this next

class AccountRoomScreen extends StatelessWidget {
  const AccountRoomScreen({super.key});

  // Helper to navigate to the Transaction screen
  void _goToTransactionScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds the UI whenever AuthModel changes (e.g., account balance updates)
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        final accounts = authModel.accounts;
        final username = authModel.username ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Overview'),
            automaticallyImplyLeading: false, // Hide the back button
            actions: [
              // Logout Button
              TextButton.icon(
                onPressed: authModel.logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: authModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  // Pull-to-refresh to fetch new balances
                  onRefresh: authModel.refreshAccounts,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome Banner
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Welcome, $username!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons (Matching your old account-menu)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Create New Account Button
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: authModel.createAccount,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Account'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Make a Transaction Button
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: accounts.isNotEmpty
                                    ? () => _goToTransactionScreen(context)
                                    : null, // Disable if no accounts exist
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('Transaction'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Account List Header
                        Text(
                          accounts.isEmpty ? 'No accounts found.' : 'Your Accounts:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        
                        const SizedBox(height: 12),

                        // Account List (Matching your accounts-list)
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(), // Important for nesting in SingleChildScrollView
                          shrinkWrap: true,
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                                title: Text(
                                  'Account #${account.accNum.substring(0, 8)}...', // Shorten UUID for display
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  'Owner: ${account.owner}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: Text(
                                  '\$${account.balance.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: account.balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Optional: Tapping a card could go to a detailed view
                                onTap: () => print('Tapped account ${account.accNum}'),
                              ),
                            );
                          },
                        ),
                        
                        // Feedback Message
                        if (authModel.message != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Text(
                              authModel.message!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}