import 'package:flutter/material.dart';

class MilkProfitCalculatorScreen extends StatefulWidget {
  const MilkProfitCalculatorScreen({super.key});

  @override
  State<MilkProfitCalculatorScreen> createState() => _MilkProfitCalculatorScreenState();
}

class _MilkProfitCalculatorScreenState extends State<MilkProfitCalculatorScreen> {
  // Placeholder values
  double _morningMilk = 2;
  double _eveningMilk = 1.5;
  double _fatContent = 3.2;
  double _milkRate = 55.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Profit Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Enter Daily Details'),
          const SizedBox(height: 16),
          _buildInputRow('Morning (Liters)', _morningMilk, (val) => setState(() => _morningMilk = val)),
          _buildInputRow('Evening (Liters)', _eveningMilk, (val) => setState(() => _eveningMilk = val)),
          _buildInputRow('Fat Content (%)', _fatContent, (val) => setState(() => _fatContent = val)),
          _buildInputRow('Milk Rate (₹/L)', _milkRate, (val) => setState(() => _milkRate = val)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Calculate logic here
              setState(() {}); // Trigger a rebuild to show results
            },
            icon: const Icon(Icons.calculate, color: Colors.white),
            label: const Text('Calculate'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),
          _buildSectionHeader('Daily Profit Summary'),
          const SizedBox(height: 20),
          _buildResultRow('Total Revenue:', '₹${((_morningMilk + _eveningMilk) * _milkRate).toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildResultRow('Total Expenses:', '₹150.00'), // Placeholder
          const SizedBox(height: 12),
          _buildResultRow('Net Profit:', '₹11.00', isProfit: true), // Placeholder
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View Report'),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInputRow(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isProfit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isProfit ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}
