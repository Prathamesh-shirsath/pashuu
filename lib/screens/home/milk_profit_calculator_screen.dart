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
  // Removed: final _fatContentController = TextEditingController();
  // Removed: final _feedCostController = TextEditingController();
  // Removed: final _otherCostsController = TextEditingController();

  double? _totalRevenue;
  // Cost is now always zero as there are no input cost fields
  final double _totalCost = 0.0;
  double? _netProfit;

  bool _isSaving = false;
  final double _borderRadius = 12.0; // Consistent border radius

  void _calculateProfit() {
    if (_formKey.currentState!.validate()) {
      final double baseMilkPrice = double.tryParse(_milkPriceController.text) ?? 0;
      final double litersSold = double.tryParse(_litersSoldController.text) ?? 0;
      // Removed: final double fatContent = double.tryParse(_fatContentController.text) ?? 0;
      // Removed: final double feedCost = double.tryParse(_feedCostController.text) ?? 0;
      // Removed: final double otherCosts = double.tryParse(_otherCostsController.text) ?? 0;

      // --- Simplified Calculation Logic ---
      // No fat content adjustment, no feed or other costs
      double effectiveMilkPrice = baseMilkPrice; // Simple price per liter
      double calculatedRevenue = effectiveMilkPrice * litersSold;
      double calculatedNetProfit = calculatedRevenue - _totalCost; // _totalCost is 0.0

      setState(() {
        _totalRevenue = calculatedRevenue;
        _netProfit = calculatedNetProfit;
      });
    }
  }

  // --- FUNCTION TO SAVE DATA TO FIRESTORE (NO SNACKBAR CHANGES) ---
  Future<void> _saveProfitToHistory() async {
    if (_netProfit == null) return; // Don't save if there's no result

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Keep a basic alert if not logged in, as it's critical.
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
        'totalCost': _totalCost, // Will always be 0.0 now
        'netProfit': _netProfit,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Original snackbar removed per request.
      // If you want a silent success, you can leave this empty.
      // If you need a more visible success without a snackbar, consider a temporary icon or text change.

    } catch (e) {
      // Keep basic error indication
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
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
    // Removed: _fatContentController.dispose();
    // Removed: _feedCostController.dispose();
    // Removed: _otherCostsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Profit Calculator'),
        backgroundColor: primaryColor, // Consistent with settings screen
        foregroundColor: Colors.white, // Consistent with settings screen
        elevation: 4, // Consistent with settings screen
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
        padding: const EdgeInsets.all(16.0), // Consistent with settings screen
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Milk Sale Details', onSurfaceColor), // Changed section title
              const SizedBox(height: 10),
              _buildTextFormField(
                  _milkPriceController, 'Price per Liter (₹)', Icons.currency_rupee, onSurfaceColor, _borderRadius),
              const SizedBox(height: 15), // Spacing between input fields
              _buildTextFormField(
                  _litersSoldController, 'Liters Sold', Icons.water_drop, onSurfaceColor, _borderRadius),
              const SizedBox(height: 30),

              // Removed "Cost Details" section as all cost fields are gone.
              // Removed: _buildSectionTitle('Cost Details', onSurfaceColor),
              // Removed: const SizedBox(height: 10),
              // Removed: _buildTextFormField(...) for feed cost
              // Removed: const SizedBox(height: 15),
              // Removed: _buildTextFormField(...) for other costs
              // Removed: const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _calculateProfit,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text('Calculate Profit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
                ),
              ),
              const SizedBox(height: 30),

              if (_netProfit != null) ...[
                _buildResultCard(primaryColor, onSurfaceColor, _borderRadius),
                const SizedBox(height: 15), // Spacing below result card
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveProfitToHistory,
                  icon: _isSaving
                      ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor))
                      : Icon(Icons.save_alt, color: primaryColor),
                  label: Text('Save to History', style: TextStyle(color: primaryColor)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: primaryColor),
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

  // Helper widget to build section titles, consistent with settings screen
  Widget _buildSectionTitle(String title, Color onSurfaceColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor.withOpacity(0.8), // Muted color for section title
        ),
      ),
    );
  }

  // Helper for consistent TextFormFields
  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon, Color onSurfaceColor, double borderRadius) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onSurfaceColor.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a value';
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
      style: TextStyle(color: onSurfaceColor, fontSize: 16),
    );
  }

  // Result card styling
  Widget _buildResultCard(Color primaryColor, Color onSurfaceColor, double borderRadius) {
    bool isProfit = _netProfit! >= 0;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: isProfit ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildResultRow('Total Revenue:', '₹${_totalRevenue!.toStringAsFixed(2)}', onSurfaceColor),
            // Removed "Total Costs" row as there are no longer any input costs.
            // Removed: const Divider(height: 20),
            // Removed: _buildResultRow('Total Costs:', '₹${_totalCost!.toStringAsFixed(2)}', onSurfaceColor),
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
                    color: isProfit ? primaryColor : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color onSurfaceColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: onSurfaceColor.withOpacity(0.7))),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}