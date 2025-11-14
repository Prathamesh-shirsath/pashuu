// lib/screens/home/milk_profit_history_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // Import for PDF creation
import 'package:pdf/widgets.dart' as pw; // Use pw for pdf widgets
// 'package:printing/printing.dart'; // Import for printing/sharing
import 'package:path_provider/path_provider.dart'; // For saving temporary file


// Helper class for monthly aggregated data
class MonthlyReportData {
  double totalRevenue = 0.0;
  double totalCost = 0.0;
  double netProfit = 0.0;
  int entryCount = 0;
  List<Map<String, dynamic>> entries = []; // To store individual records for the report

  void addEntry(Map<String, dynamic> record) {
    totalRevenue += (record['totalRevenue'] as num).toDouble();
    totalCost += (record['totalCost'] as num).toDouble();
    netProfit += (record['netProfit'] as num).toDouble();
    entryCount++;
    entries.add(record);
  }
}

class MilkProfitHistoryScreen extends StatefulWidget {
  const MilkProfitHistoryScreen({super.key});

  @override
  State<MilkProfitHistoryScreen> createState() => _MilkProfitHistoryScreenState();
}

class _MilkProfitHistoryScreenState extends State<MilkProfitHistoryScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final double borderRadius = 12.0; // Consistent border radius
  bool _isGeneratingPdf = false; // State to show loading for PDF generation

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit History'),
        backgroundColor: primaryColor, // Consistent with settings screen
        foregroundColor: Colors.white, // Consistent with settings screen
        elevation: 4, // Consistent with settings screen
        actions: [
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.share),
            // Pass context to the handler method to ensure it's available for ScaffoldMessenger
            onPressed: _isGeneratingPdf ? null : () => _generateAndSharePdfReport(context, primaryColor, onSurfaceColor),
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering options for history
            },
            tooltip: 'Filter History',
          ),
        ],
      ),
      body: currentUser == null
          ? Center(
        child: Text(
          'Please log in to see history.',
          style: TextStyle(fontSize: 16, color: onSurfaceColor.withOpacity(0.7)),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid) // It's safe to use `!` here because we've checked `currentUser == null` in the parent Widget's body condition.
            .collection('milkProfits')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: onSurfaceColor.withOpacity(0.7))));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: onSurfaceColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No history found.',
                      style: TextStyle(fontSize: 18, color: onSurfaceColor.withOpacity(0.8))),
                  Text('Your saved calculations will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: onSurfaceColor.withOpacity(0.6))),
                ],
              ),
            );
          }

          final historyDocs = snapshot.data!.docs;

          // --- Analytics Logic ---
          final Map<String, MonthlyReportData> monthlyAnalytics = {};
          for (var doc in historyDocs) {
            final record = doc.data() as Map<String, dynamic>;
            final timestamp = record['timestamp'] as Timestamp?;
            if (timestamp != null) {
              final monthKey = DateFormat('yyyy-MM').format(timestamp.toDate());
              monthlyAnalytics.putIfAbsent(monthKey, () => MonthlyReportData()).addEntry(record);
            }
          }

          final sortedMonthKeys = monthlyAnalytics.keys.toList()..sort((a, b) => b.compareTo(a));
          // --- End Analytics Logic ---

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Monthly Analytics', onSurfaceColor),
                const SizedBox(height: 10),
                if (monthlyAnalytics.isEmpty)
                  Text(
                    'No monthly data to display.',
                    style: TextStyle(fontSize: 14, color: onSurfaceColor.withOpacity(0.6)),
                  )
                else
                  ...sortedMonthKeys.map((monthKey) {
                    final data = monthlyAnalytics[monthKey]!;
                    final monthName = DateFormat('MMMM yyyy').format(DateTime.parse('$monthKey-01'));
                    return _buildMonthlyAnalyticsCard(
                        context, monthName, data, primaryColor, onSurfaceColor, borderRadius);
                  }).toList(),
                const SizedBox(height: 20),
                _buildSectionTitle('Recent Calculations', onSurfaceColor),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final record = historyDocs[index].data() as Map<String, dynamic>;
                    final timestamp = record['timestamp'] as Timestamp?;
                    final netProfit = (record['netProfit'] as num).toDouble();

                    return _buildProfitEntryCard(
                      context,
                      timestamp,
                      (record['totalRevenue'] as num).toDouble(),
                      (record['totalCost'] as num).toDouble(),
                      netProfit,
                      primaryColor,
                      onSurfaceColor,
                      borderRadius,
                    );
                  },
                ),
              ],
            ),
          );
        },
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

  // Card for monthly analytics
  Widget _buildMonthlyAnalyticsCard(BuildContext context, String monthName, MonthlyReportData data,
      Color primaryColor, Color onSurfaceColor, double borderRadius) {
    bool isProfit = data.netProfit >= 0;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      margin: const EdgeInsets.only(bottom: 10.0),
      color: isProfit ? Colors.lightGreen.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: onSurfaceColor),
            ),
            const Divider(height: 16, thickness: 1),
            _buildHistoryRow(context, 'Total Revenue:', '₹${data.totalRevenue.toStringAsFixed(2)}', onSurfaceColor),
            const SizedBox(height: 6),
            _buildHistoryRow(context, 'Total Costs:', '- ₹${data.totalCost.toStringAsFixed(2)}', onSurfaceColor),
            const SizedBox(height: 6),
            _buildHistoryRow(context, 'Entries:', '${data.entryCount} records', onSurfaceColor),
            const Divider(height: 16, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isProfit ? 'Net Monthly Profit:' : 'Net Monthly Loss:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurfaceColor)),
                Text(
                  '₹${data.netProfit.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
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

  // Reusable widget to build each profit history card, inspired by settings screen's card
  Widget _buildProfitEntryCard(
      BuildContext context,
      Timestamp? timestamp,
      double totalRevenue,
      double totalCost,
      double netProfit,
      Color primaryColor,
      Color onSurfaceColor,
      double borderRadius,
      ) {
    bool isProfit = netProfit >= 0;
    return Card(
      elevation: 3, // Consistent with settings screen cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.only(bottom: 15.0), // Spacing between cards
      child: InkWell(
        onTap: () {
          // TODO: Implement viewing/editing individual entry details
          // Removed snackbar as per request
        },
        borderRadius: BorderRadius.circular(borderRadius), // Apply radius to InkWell's ripple
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timestamp != null
                    ? DateFormat('EEEE, MMM d, yyyy').format(timestamp.toDate())
                    : 'Date not available',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: onSurfaceColor),
              ),
              const Divider(height: 20),
              _buildHistoryRow(context, 'Revenue:', '₹${totalRevenue.toStringAsFixed(2)}', onSurfaceColor),
              const SizedBox(height: 8),
              _buildHistoryRow(context, 'Costs:', '- ₹${totalCost.toStringAsFixed(2)}', onSurfaceColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isProfit ? 'Net Profit' : 'Net Loss',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurfaceColor)),
                  Text(
                    '₹${netProfit.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isProfit ? primaryColor : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent history row layout
  Widget _buildHistoryRow(BuildContext context, String label, String value, Color onSurfaceColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: onSurfaceColor.withOpacity(0.7))),
        Text(value, style: TextStyle(color: onSurfaceColor)),
      ],
    );
  }

  // --- PDF GENERATION AND SHARING LOGIC ---
  Future<void> _generateAndSharePdfReport(BuildContext context, Color primaryColor, Color onSurfaceColor) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      // --- IMPORTANT FIX: Check if currentUser is null here ---
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to generate reports.')),
          );
        }
        return; // Exit if user is not logged in
      }
      // --- END FIX ---

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid) // Now safe to use `!` after the null check
          .collection('milkProfits')
          .orderBy('timestamp', descending: true)
          .get();

      final allRecords = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      final pdf = pw.Document();

      // Aggregate data for monthly analytics
      final Map<String, MonthlyReportData> monthlyAnalytics = {};
      for (var record in allRecords) {
        final timestamp = record['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final monthKey = DateFormat('yyyy-MM').format(timestamp.toDate());
          monthlyAnalytics.putIfAbsent(monthKey, () => MonthlyReportData()).addEntry(record);
        }
      }
      final sortedMonthKeys = monthlyAnalytics.keys.toList()..sort(); // Sort ascending for report

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Milk Profit Report - ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(primaryColor.value))),
            ),
            pw.SizedBox(height: 20),

            // Monthly Analytics Section
            pw.Text('Monthly Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(primaryColor.value))),
            pw.SizedBox(height: 10),
            if (monthlyAnalytics.isEmpty)
              pw.Text('No monthly data available.')
            else
              ...sortedMonthKeys.map((monthKey) {
                final data = monthlyAnalytics[monthKey]!;
                final monthName = DateFormat('MMMM yyyy').format(DateTime.parse('$monthKey-01'));
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(monthName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Table.fromTextArray(
                      cellAlignment: pw.Alignment.centerLeft,
                      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(2),
                      },
                      data: <List<String>>[
                        <String>['Metric', 'Value'],
                        ['Total Revenue', '₹${data.totalRevenue.toStringAsFixed(2)}'],
                        ['Total Costs', '₹${data.totalCost.toStringAsFixed(2)}'],
                        ['Net Profit/Loss', '₹${data.netProfit.toStringAsFixed(2)} (${data.netProfit >= 0 ? 'Profit' : 'Loss'})'],
                        ['Number of Entries', '${data.entryCount}'],
                      ],
                    ),
                    pw.SizedBox(height: 15),
                  ],
                );
              }),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Individual Records Section
            pw.Text('Individual Records', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(primaryColor.value))),
            pw.SizedBox(height: 10),
            if (allRecords.isEmpty)
              pw.Text('No individual records available.')
            else
              pw.Table.fromTextArray(
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: <String>['Date', 'Revenue (₹)', 'Costs (₹)', 'Net Profit/Loss (₹)'],
                data: allRecords.map((record) {
                  final timestamp = record['timestamp'] as Timestamp?;
                  final date = timestamp != null ? DateFormat('dd-MM-yyyy').format(timestamp.toDate()) : 'N/A';
                  final revenue = (record['totalRevenue'] as num).toDouble().toStringAsFixed(2);
                  final cost = (record['totalCost'] as num).toDouble().toStringAsFixed(2);
                  final profit = (record['netProfit'] as num).toDouble().toStringAsFixed(2);
                  return [date, revenue, cost, profit];
                }).toList(),
              ),

            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text('Report generated by Pashuu App.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/pashuu_profit_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf");
      await file.writeAsBytes(await pdf.save());


    } catch (e) {
      print('Error generating or sharing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }
}