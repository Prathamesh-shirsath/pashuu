// lib/screens/home/milk_profit_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pashuu/screens/home/milk_profit_history_screen.dart';

class MilkProfitCalculatorScreen extends StatefulWidget {
  const MilkProfitCalculatorScreen({super.key});

  @override
  State<MilkProfitCalculatorScreen> createState() => _MilkProfitCalculatorScreenState();
}

class _MilkProfitCalculatorScreenState extends State<MilkProfitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _milkPriceController = TextEditingController();
  final _litersSoldController = TextEditingController();
  double? _totalRevenue;
  final double _totalCost = 0.0;
  double? _netProfit;
  bool _isSaving = false;
  final double _borderRadius = 12.0;

  void _calculateProfit() {
    if (_formKey.currentState!.validate()) {
      final double baseMilkPrice = double.tryParse(_milkPriceController.text) ?? 0;
      final double litersSold = double.tryParse(_litersSoldController.text) ?? 0;
      double calculatedRevenue = baseMilkPrice * litersSold;
      double calculatedNetProfit = calculatedRevenue - _totalCost;
      setState(() {
        _totalRevenue = calculatedRevenue;
        _netProfit = calculatedNetProfit;
      });
    }
  }

  Future<void> _saveProfitToHistory() async {
    if (_netProfit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please calculate the profit first.')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save history.')),
      );
      return;
    }
    setState(() { _isSaving = true; });
    final double pricePerLiter = double.tryParse(_milkPriceController.text) ?? 0;
    final double litersSold = double.tryParse(_litersSoldController.text) ?? 0;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milkProfits')
          .add({
        'litersSold': litersSold,
        'pricePerLiter': pricePerLiter,
        'totalRevenue': _totalRevenue,
        'totalCost': _totalCost,
        'netProfit': _netProfit,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to history!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save. Check your connection or permissions.'), backgroundColor: Colors.red),
      );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Profit Calculator'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Milk Sale Details', theme),
              const SizedBox(height: 10),
              _buildTextFormField(
                  _milkPriceController, 'Price per Liter (₹)', Icons.currency_rupee),
              const SizedBox(height: 15),
              _buildTextFormField(
                  _litersSoldController, 'Liters Sold', Icons.water_drop),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _calculateProfit,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Profit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
                ),
              ),
              const SizedBox(height: 30),

              if (_netProfit != null) ...[
                _buildResultCard(theme),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveProfitToHistory,
                  icon: _isSaving
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_alt),
                  label: const Text('Save to History'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a value';
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    bool isProfit = _netProfit! >= 0;
    Color cardColor = isProfit
        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
        : theme.colorScheme.errorContainer.withOpacity(0.4);
    Color textColor = isProfit ? theme.colorScheme.primary : theme.colorScheme.error;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildResultRow('Total Revenue:', '₹${_totalRevenue!.toStringAsFixed(2)}', theme),
            const Divider(height: 24, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isProfit ? 'Net Profit:' : 'Net Loss:',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '₹${_netProfit!.abs().toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}