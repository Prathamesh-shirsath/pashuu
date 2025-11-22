// lib/screens/home/milk_profit_history_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Enum for time frame selection
enum TimeFrame { Daily, Weekly, Monthly }

class MilkAnalytics {
  double totalEarnings = 0.0;
  double totalLiters = 0.0;
  double avgPrice = 0.0;

  DateTime? firstEntryDate;
  DateTime? lastEntryDate;

  double avgDailyEarnings = 0.0;
  double avgDailyLiters = 0.0;
  double avgMonthlyEarnings = 0.0;
  double avgMonthlyLiters = 0.0;

  void processDocs(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return;

    totalEarnings = 0.0;
    totalLiters = 0.0;
    firstEntryDate = null;
    lastEntryDate = null;
    avgPrice = 0.0;
    avgDailyEarnings = 0.0;
    avgDailyLiters = 0.0;
    avgMonthlyEarnings = 0.0;
    avgMonthlyLiters = 0.0;

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

    if (firstEntryDate != null && lastEntryDate != null) {
      final days =
      max(1, lastEntryDate!.difference(firstEntryDate!).inDays + 1)
          .toDouble();

      avgDailyEarnings = totalEarnings / days;
      avgDailyLiters = totalLiters / days;

      final months = max(1, days / 30.0);
      avgMonthlyEarnings = totalEarnings / months;
      avgMonthlyLiters = totalLiters / months;
    }
  }

  // Earnings aggregation
  Map<String, double> getAggregatedEarnings(
      List<QueryDocumentSnapshot> docs, TimeFrame timeFrame) {
    final Map<String, double> aggregatedData = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      final key = _bucketKey(timestamp, timeFrame);
      aggregatedData[key] = (aggregatedData[key] ?? 0) + revenue;
    }
    return aggregatedData;
  }

  // Liters aggregation
  Map<String, double> getAggregatedLiters(
      List<QueryDocumentSnapshot> docs, TimeFrame timeFrame) {
    final Map<String, double> aggregatedData = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final liters = (data['litersSold'] as num?)?.toDouble() ?? 0.0;
      final key = _bucketKey(timestamp, timeFrame);
      aggregatedData[key] = (aggregatedData[key] ?? 0) + liters;
    }
    return aggregatedData;
  }

  String _bucketKey(DateTime timestamp, TimeFrame timeFrame) {
    switch (timeFrame) {
      case TimeFrame.Daily:
        return DateFormat('d MMM').format(timestamp);
      case TimeFrame.Weekly:
        final startOfWeek =
        timestamp.subtract(Duration(days: timestamp.weekday - 1));
        return DateFormat('d MMM').format(startOfWeek);
      case TimeFrame.Monthly:
        return DateFormat('MMM y').format(timestamp);
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
  TimeFrame _selectedTimeFrame = TimeFrame.Monthly;

  Future<void> _resetAllHistory() async {
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Milk History'),
        content: const Text(
          'इससे आपकी सारी milk profit history delete हो जाएगी.\n\n'
              'क्या आप सच में reset करना चाहते हैं?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final colRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('milkProfits');

      final snapshots = await colRef.get();
      if (snapshots.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to reset.')),
        );
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Milk profit history reset successfully.'),
        ),
      );
    } catch (e) {
      print('Error resetting history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset history.')),
      );
    }
  }

  void _showReportDialog(
      MilkAnalytics analytics, List<QueryDocumentSnapshot> docs) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateRange = (analytics.firstEntryDate != null &&
        analytics.lastEntryDate != null)
        ? '${DateFormat('d MMM y').format(analytics.firstEntryDate!)} – '
        '${DateFormat('d MMM y').format(analytics.lastEntryDate!)}'
        : 'N/A';

    final totalDays = (analytics.firstEntryDate != null &&
        analytics.lastEntryDate != null)
        ? analytics.lastEntryDate!
        .difference(analytics.firstEntryDate!)
        .inDays +
        1
        : 0;

    final report = StringBuffer()
      ..writeln('📊 Milk Production & Earnings Report')
      ..writeln('------------------------------------')
      ..writeln('Entries    : ${docs.length}')
      ..writeln('Period     : $dateRange')
      ..writeln('Total Days : $totalDays')
      ..writeln('')
      ..writeln(
          'Total Milk : ${analytics.totalLiters.toStringAsFixed(1)} L')
      ..writeln(
          'Total Earn : ${currency.format(analytics.totalEarnings)}')
      ..writeln(
          'Avg Price  : ₹${analytics.avgPrice.toStringAsFixed(2)} / L')
      ..writeln('')
      ..writeln('📅 Daily Averages')
      ..writeln(
          'Milk : ${analytics.avgDailyLiters.toStringAsFixed(1)} L / day')
      ..writeln(
          'Earn : ${currency.format(analytics.avgDailyEarnings)} / day')
      ..writeln('')
      ..writeln('📆 Monthly (Approx.)')
      ..writeln(
          'Milk : ${analytics.avgMonthlyLiters.toStringAsFixed(1)} L / month')
      ..writeln(
          'Earn : ${currency.format(analytics.avgMonthlyEarnings)} / month');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Milk Analytics Report'),
        content: SingleChildScrollView(
          child: Text(
            report.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Analytics Dashboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            tooltip: 'Reset History',
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetAllHistory,
          ),
        ],
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
                  Icon(Icons.bar_chart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Milk Data Found',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Add your first milk sale to see your analytics!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
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
                  title: 'Cumulative Earnings Over Time',
                  child: _buildEarningsLineChart(historyDocs, theme),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Earnings by ${_selectedTimeFrame.name}',
                  dropdown: _buildTimeFrameDropdown(theme),
                  child: _buildEarningsHistogram(historyDocs,
                      _selectedTimeFrame, theme, analytics),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Milk Production by ${_selectedTimeFrame.name}',
                  child: _buildProductionHistogram(historyDocs,
                      _selectedTimeFrame, theme, analytics),
                ),
                const SizedBox(height: 24),
                _buildReportButton(analytics, historyDocs, theme),
                const SizedBox(height: 16),
                _buildRecentEntriesCard(
                    historyDocs.reversed.toList(), theme),
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Earnings',
                currencyFormatter.format(analytics.totalEarnings),
                Icons.currency_rupee,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Total Milk',
                '${analytics.totalLiters.toStringAsFixed(1)} L',
                Icons.opacity,
                theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Avg Price / L',
                '₹${analytics.avgPrice.toStringAsFixed(2)}',
                Icons.price_change,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Avg Daily Earn',
                currencyFormatter.format(analytics.avgDailyEarnings),
                Icons.calendar_today,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Icon(icon, size: 22, color: theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      {required String title, Widget? dropdown, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 260,
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
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
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

  /// 🔥 Advanced cumulative earnings chart
  Widget _buildEarningsLineChart(
      List<QueryDocumentSnapshot> docs, ThemeData theme) {
    if (docs.isEmpty) {
      return const Center(child: Text("No data for chart."));
    }

    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // 1) Build spots (sorted by time)
    final List<FlSpot> spots = [];
    double cumulativeEarnings = 0.0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      cumulativeEarnings += revenue;

      spots.add(
        FlSpot(
          timestamp.millisecondsSinceEpoch.toDouble(),
          cumulativeEarnings,
        ),
      );
    }

    // 2) Compute bounds for nicer view
    final xs = spots.map((e) => e.x).toList();
    final ys = spots.map((e) => e.y).toList();

    final minX = xs.reduce(min);
    final maxX = xs.reduce(max);
    final minY = 0.0;
    final maxY = ys.reduce(max) * 1.1; // 10% headroom

    // Label step on X axis (max 6 labels)
    const int stepCount = 6;
    final double xStep = (maxX - minX) / max(1, stepCount - 1);

    // Latest value for overlay
    final latestSpot = spots.last;
    final latestDate =
    DateTime.fromMillisecondsSinceEpoch(latestSpot.x.toInt());
    final latestValue = latestSpot.y;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small header row with latest info
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest: ${DateFormat('d MMM y').format(latestDate)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                currency.format(latestValue),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                          barSpot.x.toInt());
                      return LineTooltipItem(
                        '${DateFormat('d MMM y').format(date)}\n',
                        theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: currency.format(barSpot.y),
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('0');
                      }
                      String label;
                      if (value >= 100000) {
                        label = '${(value / 100000).toStringAsFixed(1)}L';
                      } else if (value >= 1000) {
                        label = '${(value / 1000).toStringAsFixed(0)}k';
                      } else {
                        label = value.toStringAsFixed(0);
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value < minX || value > maxX) {
                        return const SizedBox.shrink();
                      }
                      // Only show near multiples of xStep
                      final double relative =
                          (value - minX) / (xStep == 0 ? 1 : xStep);
                      if ((relative - relative.round()).abs() > 0.3) {
                        return const SizedBox.shrink();
                      }
                      final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('d MMM').format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) => spot.x == latestSpot.x,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: theme.scaffoldBackgroundColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.35),
                        theme.colorScheme.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsHistogram(
      List<QueryDocumentSnapshot> docs,
      TimeFrame timeFrame,
      ThemeData theme,
      MilkAnalytics analytics,
      ) {
    if (docs.isEmpty) {
      return const Center(child: Text("No data for chart."));
    }

    final aggregatedData = analytics.getAggregatedEarnings(docs, timeFrame);
    if (aggregatedData.isEmpty) {
      return const Center(child: Text("No data for chart."));
    }

    final entries = aggregatedData.entries.toList();
    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
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
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = entries[group.x.toInt()].key;
              return BarTooltipItem(
                '$label\n',
                theme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: '₹${rod.toY.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              );
            },
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      entries[index].key,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 2,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildProductionHistogram(
      List<QueryDocumentSnapshot> docs,
      TimeFrame timeFrame,
      ThemeData theme,
      MilkAnalytics analytics,
      ) {
    if (docs.isEmpty) {
      return const Center(child: Text("No data for chart."));
    }

    final aggregatedData = analytics.getAggregatedLiters(docs, timeFrame);
    if (aggregatedData.isEmpty) {
      return const Center(child: Text("No data for chart."));
    }

    final entries = aggregatedData.entries.toList();
    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: theme.colorScheme.secondary,
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
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = entries[group.x.toInt()].key;
              return BarTooltipItem(
                '$label\n',
                theme.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(1)} L',
                    style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              );
            },
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      entries[index].key,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 2,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildReportButton(MilkAnalytics analytics,
      List<QueryDocumentSnapshot> docs, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.description_outlined),
        label: const Text('Generate Detailed Report'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => _showReportDialog(analytics, docs),
      ),
    );
  }

  Widget _buildRecentEntriesCard(
      List<QueryDocumentSnapshot> docs, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Recent Entries', style: theme.textTheme.titleLarge),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(docs.length, 5),
            separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final liters =
                  (data['litersSold'] as num?)?.toDouble() ?? 0.0;
              final price =
                  (data['pricePerLiter'] as num?)?.toDouble() ?? 0.0;
              final revenue =
                  (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
              final date = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  '₹${revenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${liters.toStringAsFixed(1)} L  @ '
                      '₹${price.toStringAsFixed(2)}/L',
                ),
                trailing: Text(DateFormat('MMM y').format(date)),
              );
            },
          ),
        ],
      ),
    );
  }
}
