// lib/screens/home/milk_profit_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // --- NEW --- For using min()

// Enum for type-safe time frame selection
enum TimeFrame { Daily, Weekly, Monthly }

class MilkAnalytics {
  double totalEarnings = 0.0;
  double totalLiters = 0.0;
  double avgPrice = 0.0;
  DateTime? firstEntryDate;
  DateTime? lastEntryDate;

  // Process the raw documents to get summary stats
  void processDocs(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return;

    // Reset values
    totalEarnings = 0.0;
    totalLiters = 0.0;
    firstEntryDate = null;
    lastEntryDate = null;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      final liters = (data['litersSold'] as num?)?.toDouble() ?? 0.0;
      final timestamp = (data['timestamp'] as Timestamp).toDate();

      totalEarnings += revenue;
      totalLiters += liters;

      if (firstEntryDate == null || timestamp.isBefore(firstEntryDate!)) {
        firstEntryDate = timestamp;
      }
      if (lastEntryDate == null || timestamp.isAfter(lastEntryDate!)) {
        lastEntryDate = timestamp;
      }
    }

    if (totalLiters > 0) {
      avgPrice = totalEarnings / totalLiters;
    }
  }

  // Centralized logic for aggregating histogram data
  Map<String, double> getAggregatedEarnings(
      List<QueryDocumentSnapshot> docs, TimeFrame timeFrame) {
    Map<String, double> aggregatedData = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;

      String key;
      switch (timeFrame) {
        case TimeFrame.Daily:
          key = DateFormat('d MMM').format(timestamp);
          break;
        case TimeFrame.Weekly:
        // Find the start of the week (assuming Monday is the first day)
          final startOfWeek =
          timestamp.subtract(Duration(days: timestamp.weekday - 1));
          key = DateFormat('d MMM').format(startOfWeek);
          break;
        case TimeFrame.Monthly:
          key = DateFormat('MMM y').format(timestamp);
          break;
      }
      aggregatedData[key] = (aggregatedData[key] ?? 0) + revenue;
    }
    return aggregatedData;
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
  TimeFrame _selectedTimeFrame = TimeFrame.Monthly;

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
            .orderBy('timestamp', descending: true)
            .limit(365)
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
                  Icon(Icons.bar_chart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Milk Data Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Add your first milk sale to see your analytics!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          final historyDocs = snapshot.data!.docs.reversed.toList();
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
                  child: _buildEarningsHistogram(historyDocs, _selectedTimeFrame, theme, analytics), // --- FIX: Pass analytics instance
                ),
                const SizedBox(height: 24),
                _buildRecentEntriesCard(historyDocs.reversed.toList(), theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(MilkAnalytics analytics, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    if (analytics.firstEntryDate == null || analytics.lastEntryDate == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
            child: _summaryCard(
                'Total Earnings',
                currencyFormatter.format(analytics.totalEarnings),
                Icons.trending_up,
                theme)),
        const SizedBox(width: 12),
        Expanded(
            child: _summaryCard(
                'Total Liters',
                '${analytics.totalLiters.toStringAsFixed(1)} L',
                Icons.opacity,
                theme)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: theme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(value,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIX --- Restored the implementation of this method.
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
                Text(title, style: Theme.of(context).textTheme.titleLarge),
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
        child: DropdownButton<TimeFrame>(
          value: _selectedTimeFrame,
          items: TimeFrame.values.map((TimeFrame value) {
            return DropdownMenuItem<TimeFrame>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeFrame = newValue;
              });
            }
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
           // tooltipBgColor: theme.colorScheme.secondaryContainer,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final date = DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                return LineTooltipItem(
                  '${DateFormat('d MMM').format(date)}\n',
                  theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '₹${barSpot.y.toStringAsFixed(0)}',
                      style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: false),
        // --- FIX --- Restored the titlesData implementation.
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

  Widget _buildEarningsHistogram(List<QueryDocumentSnapshot> docs, TimeFrame timeFrame, ThemeData theme, MilkAnalytics analytics) {
    if (docs.isEmpty) return const Center(child: Text("No data for chart."));

    // --- FIX --- Use the passed-in analytics instance.
    final aggregatedData = analytics.getAggregatedEarnings(docs, timeFrame);

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
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: theme.colorScheme.secondaryContainer,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String week = aggregatedData.keys.elementAt(group.x);
              return BarTooltipItem(
                '$week\n',
                theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: '₹${(rod.toY).toStringAsFixed(0)}',
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              );
            },
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        // --- FIX --- Restored the titlesData implementation.
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

  Widget _buildRecentEntriesCard(List<QueryDocumentSnapshot> docs, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Recent Entries', style: theme.textTheme.titleLarge),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(docs.length, 5), // Show up to 5 recent entries
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final liters = (data['litersSold'] as num?)?.toDouble() ?? 0.0;
              final price = (data['pricePerLiter'] as num?)?.toDouble() ?? 0.0;
              final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
              final date = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ),
                title: Text(
                  '₹${revenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    '${liters.toStringAsFixed(1)} L  @ ₹${price.toStringAsFixed(2)}/L'),
                trailing: Text(DateFormat('MMM y').format(date)),
              );
            },
          ),
        ],
      ),
    );
  }
}
