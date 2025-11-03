
// lib/screens/home/milk_profit_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// No need to import 'package:pashuu/theme.dart' directly in this file anymore.

class MilkProfitHistoryScreen extends StatelessWidget {
  const MilkProfitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit History'),
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see history.'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('milkProfits')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No history found.', style: TextStyle(fontSize: 18)),
                  Text('Your saved calculations will appear here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final historyDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyDocs.length,
            itemBuilder: (context, index) {
              final record = historyDocs[index].data() as Map<String, dynamic>;
              final timestamp = record['timestamp'] as Timestamp?;
              final netProfit = record['netProfit'] as double;
              bool isProfit = netProfit >= 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp != null
                            ? DateFormat('EEEE, MMM d, yyyy').format(timestamp.toDate())
                            : 'Date not available',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(height: 20),
                      _buildHistoryRow(context, 'Revenue:', '₹${(record['totalRevenue'] as double).toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildHistoryRow(context, 'Costs:', '- ₹${(record['totalCost'] as double).toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isProfit ? 'Net Profit' : 'Net Loss', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '₹${netProfit.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              // --- FIX #1: Use Theme.of(context) for the color ---
                              color: isProfit ? Theme.of(context).primaryColor : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Pass BuildContext to this helper widget
  Widget _buildHistoryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- FIX #2: Use Theme.of(context) which gets the color from your AppTheme class ---
        Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
        Text(value),
      ],
    );
  }
}
