// lib/screens/home/milk_profit_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MilkAnalytics {
  double totalEarnings = 0.0;
  double totalLiters = 0.0;
  double avgPrice = 0.0;
  int uniqueMonths = 0;
  DateTime? firstEntryDate;
  DateTime? lastEntryDate;

  void processDocs(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return;
    totalEarnings = 0.0;
    totalLiters = 0.0;
    firstEntryDate = null;
    lastEntryDate = null;
    Set<String> monthSet = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      final liters = (data['litersSold'] as num?)?.toDouble() ?? 0.0;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      totalEarnings += revenue;
      totalLiters += liters;
      monthSet.add(DateFormat('yyyy-MM').format(timestamp));
      if (firstEntryDate == null || timestamp.isBefore(firstEntryDate!)) {
        firstEntryDate = timestamp;
      }
      if (lastEntryDate == null || timestamp.isAfter(lastEntryDate!)) {
        lastEntryDate = timestamp;
      }
    }
    uniqueMonths = monthSet.length;
    if (totalLiters > 0) {
      avgPrice = totalEarnings / totalLiters;
    }
  }
}

class MilkProfitHistoryScreen extends StatefulWidget {
  const MilkProfitHistoryScreen({super.key});

  @override
  State<MilkProfitHistoryScreen> createState() =>
      _MilkProfitHistoryScreenState();
}

class _MilkProfitHistoryScreenState extends State<MilkProfitHistoryScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String _selectedTimeFrame = 'Monthly';
  final List<String> _timeFrameOptions = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Analytics Dashboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see your analytics.'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('milkProfits')
            .orderBy('timestamp', descending: false)
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
                child: Text('No milk profit data found.'));
          }

          final historyDocs = snapshot.data!.docs;
          final analytics = MilkAnalytics()..processDocs(historyDocs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(analytics, theme),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Earnings over Time',
                  child: _buildEarningsLineChart(historyDocs, theme),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Earnings Histogram',
                  dropdown: _buildTimeFrameDropdown(theme),
                  child: _buildEarningsHistogram(
                      historyDocs, _selectedTimeFrame, theme),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Recent Entries',
                  child: _buildRecentEntriesTable(historyDocs.reversed.toList()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(MilkAnalytics analytics, ThemeData theme) {
    final currencyFormatter =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    if (analytics.firstEntryDate == null || analytics.lastEntryDate == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
            child: _summaryCard(
                'Total Earnings',
                currencyFormatter.format(analytics.totalEarnings),
                'Period: ${DateFormat('d MMM').format(analytics.firstEntryDate!)} - ${DateFormat('d MMM').format(analytics.lastEntryDate!)}',
                theme)),
        const SizedBox(width: 12),
        Expanded(
            child: _summaryCard(
                'Total Liters',
                '${analytics.totalLiters.toStringAsFixed(0)} L',
                'Avg price: ${currencyFormatter.format(analytics.avgPrice)}/L',
                theme)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
            )),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      {required String title, Widget? dropdown, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge),
                if (dropdown != null) dropdown,
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameDropdown(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimeFrame,
          items: _timeFrameOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedTimeFrame = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEarningsLineChart(List<QueryDocumentSnapshot> docs, ThemeData theme) {
    if (docs.isEmpty) return const Center(child: Text("No data for chart."));
    List<FlSpot> spots = [];
    double cumulativeEarnings = 0.0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      cumulativeEarnings += revenue;
      spots.add(FlSpot(
        timestamp.millisecondsSinceEpoch.toDouble(),
        cumulativeEarnings,
      ));
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 10)));
          })),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5))),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsHistogram(List<QueryDocumentSnapshot> docs, String timeFrame, ThemeData theme) {
    if (docs.isEmpty) return const Center(child: Text("No data for chart."));
    Map<String, double> aggregatedData = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      String key;
      switch (timeFrame) {
        case 'Daily':
          key = DateFormat('d MMM').format(timestamp);
          break;
        case 'Weekly':
          final startOfWeek = timestamp.subtract(Duration(days: timestamp.weekday - 1));
          key = DateFormat('d MMM').format(startOfWeek);
          break;
        case 'Monthly':
        default:
          key = DateFormat('MMM y').format(timestamp);
          break;
      }
      aggregatedData[key] = (aggregatedData[key] ?? 0) + revenue;
    }
    final barGroups = aggregatedData.entries.toList().asMap().entries.map((entry) {
      int index = entry.key;
      var data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < aggregatedData.keys.length) {
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(aggregatedData.keys.elementAt(index), style: const TextStyle(fontSize: 10), maxLines: 2,));
            }
            return const Text('');
          })),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildRecentEntriesTable(List<QueryDocumentSnapshot> docs) {
    return DataTable(
      columnSpacing: 20,
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Liters'), numeric: true),
        DataColumn(label: Text('Price/L'), numeric: true),
        DataColumn(label: Text('Earnings'), numeric: true),
      ],
      rows: docs.take(10).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final liters = (data['litersSold'] as num?)?.toString() ?? '0';
        final price = '₹${(data['pricePerLiter'] as num?)?.toStringAsFixed(2) ?? '0.00'}';
        final revenue = '₹${(data['totalRevenue'] as num?)?.toStringAsFixed(0) ?? '0'}';
        final date = DateFormat('yyyy-MM-dd').format((data['timestamp'] as Timestamp).toDate());
        return DataRow(
          cells: [
            DataCell(Text(date)),
            DataCell(Text(liters)),
            DataCell(Text(price)),
            DataCell(Text(revenue)),
          ],
        );
      }).toList(),
    );
  }
}