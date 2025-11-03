// lib/screens/home/milk_profit_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pashuu/screens/home/milk_profit_history_screen.dart'; // We will create this next
import 'package:pashuu/theme.dart';

class MilkProfitCalculatorScreen extends StatefulWidget {
  const MilkProfitCalculatorScreen({super.key});

  @override
  State<MilkProfitCalculatorScreen> createState() => _MilkProfitCalculatorScreenState();
}

class _MilkProfitCalculatorScreenState extends State<MilkProfitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _milkPriceController = TextEditingController();
  final _litersSoldController = TextEditingController();
  final _feedCostController = TextEditingController();
  final _otherCostsController = TextEditingController();

  double? _totalRevenue;
  double? _totalCost;
  double? _netProfit;

  bool _isSaving = false;

  void _calculateProfit() {
    if (_formKey.currentState!.validate()) {
      final double milkPrice = double.tryParse(_milkPriceController.text) ?? 0;
      final double litersSold = double.tryParse(_litersSoldController.text) ?? 0;
      final double feedCost = double.tryParse(_feedCostController.text) ?? 0;
      final double otherCosts = double.tryParse(_otherCostsController.text) ?? 0;

      setState(() {
        _totalRevenue = milkPrice * litersSold;
        _totalCost = feedCost + otherCosts;
        _netProfit = _totalRevenue! - _totalCost!;
      });
    }
  }

  // --- NEW FUNCTION TO SAVE DATA TO FIRESTORE ---
  Future<void> _saveProfitToHistory() async {
    if (_netProfit == null) return; // Don't save if there's no result

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save history.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milkProfits')
          .add({
        'totalRevenue': _totalRevenue,
        'totalCost': _totalCost,
        'netProfit': _netProfit,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profit saved to history!'), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  void dispose() {
    _milkPriceController.dispose();
    _litersSoldController.dispose();
    _feedCostController.dispose();
    _otherCostsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Profit Calculator'),
        actions: [
          // --- BUTTON TO NAVIGATE TO HISTORY SCREEN ---
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MilkProfitHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Revenue'),
              _buildTextFormField(_milkPriceController, 'Price per Liter (₹)'),
              const SizedBox(height: 16),
              _buildTextFormField(_litersSoldController, 'Liters Sold'),
              const SizedBox(height: 24),
              _buildSectionHeader('Costs'),
              _buildTextFormField(_feedCostController, 'Feed Cost (₹)'),
              const SizedBox(height: 16),
              _buildTextFormField(_otherCostsController, 'Other Costs (₹)'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _calculateProfit,
                child: const Text('Calculate Profit'),
              ),
              const SizedBox(height: 32),
              if (_netProfit != null) ...[
                _buildResultCard(),
                const SizedBox(height: 16),
                // --- SAVE BUTTON ---
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveProfitToHistory,
                  icon: _isSaving
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_alt),
                  label: const Text('Save to History'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a value';
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }

  Widget _buildResultCard() {
    bool isProfit = _netProfit! >= 0;
    return Card(
      color: isProfit ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildResultRow('Total Revenue:', '₹${_totalRevenue!.toStringAsFixed(2)}'),
            const Divider(height: 20),
            _buildResultRow('Total Costs:', '₹${_totalCost!.toStringAsFixed(2)}'),
            const Divider(height: 24, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isProfit ? 'Net Profit:' : 'Net Loss:',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_netProfit!.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: AppTheme.lightTextColor)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
