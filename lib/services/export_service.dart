import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExportService {
  Future<File> exportToExcel(List<Expense> expenses) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Expenses'];

    // Headers
    final headers = [
      'Date',
      'Time',
      'Place',
      'Description',
      'Item Name',
      'Item Category',
      'Item Quantity',
      'Item Cost',
      'Item Value',
      'Total Amount',
      'Currency',
      'Payment Source',
      'Input Method',
      'AI Confidence',
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
    }

    // Data rows - one row per item
    int rowIndex = 1;
    for (var expense in expenses) {
      if (expense.items.isEmpty) {
        // If no items, create one row with transaction-level data
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(
          DateFormat('yyyy-MM-dd').format(expense.spentAt),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(
          DateFormat('HH:mm').format(expense.spentAt),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(expense.spentPlace);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(expense.desc ?? '');
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = DoubleCellValue(expense.totalValue);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = TextCellValue(expense.currency);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = TextCellValue(expense.paymentSource);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
            .value = TextCellValue(expense.inputMethod);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
            .value = TextCellValue(expense.aiConfidence);
        rowIndex++;
      } else {
        // One row per item
        for (var item in expense.items) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
              .value = TextCellValue(
            DateFormat('yyyy-MM-dd').format(expense.spentAt),
          );
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
              .value = TextCellValue(
            DateFormat('HH:mm').format(expense.spentAt),
          );
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
              .value = TextCellValue(expense.spentPlace);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
              .value = TextCellValue(expense.desc ?? '');
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
              .value = TextCellValue(item.itemName);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
              .value = TextCellValue(item.spentType);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
              .value = IntCellValue(item.quantity);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
              .value = DoubleCellValue(item.cost);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
              .value = DoubleCellValue(item.value);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
              .value = DoubleCellValue(expense.totalValue);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
              .value = TextCellValue(expense.currency);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
              .value = TextCellValue(expense.paymentSource);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
              .value = TextCellValue(expense.inputMethod);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
              .value = TextCellValue(expense.aiConfidence);
          rowIndex++;
        }
      }
    }

    // Add summary sheet
    Sheet summarySheet = excel['Summary'];
    summarySheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'Total Expenses',
    );
    summarySheet.cell(CellIndex.indexByString('B1')).value = IntCellValue(
      expenses.length,
    );

    summarySheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      'Total Amount',
    );
    summarySheet.cell(CellIndex.indexByString('B2')).value = DoubleCellValue(
      expenses.fold<double>(0, (sum, e) => sum + e.totalValue),
    );

    if (expenses.isNotEmpty) {
      summarySheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
        'Date Range',
      );
      summarySheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(
        '${DateFormat('MMM dd, yyyy').format(expenses.first.spentAt)} - ${DateFormat('MMM dd, yyyy').format(expenses.last.spentAt)}',
      );
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> exportToPdf(List<Expense> expenses) async {
    final pdf = pw.Document();

    // Summary page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final total = expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
          final avgPerDay = expenses.isNotEmpty
              ? total /
                    (expenses.last.spentAt
                        .difference(expenses.first.spentAt)
                        .inDays
                        .clamp(1, 999))
              : 0.0;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.Divider(height: 32),
              // Summary cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfSummaryCard(
                    'Total Expenses',
                    expenses.length.toString(),
                  ),
                  _buildPdfSummaryCard(
                    'Total Amount',
                    'IDR ${total.toStringAsFixed(0)}',
                  ),
                  _buildPdfSummaryCard(
                    'Avg/Day',
                    'IDR ${avgPerDay.toStringAsFixed(0)}',
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              // Category breakdown
              pw.Text(
                'By Category',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              ...(_getCategoryBreakdown(expenses).entries.map((entry) {
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(entry.key),
                      pw.Text('IDR ${entry.value.toStringAsFixed(0)}'),
                    ],
                  ),
                );
              }).toList()),
            ],
          );
        },
      ),
    );

    // Detailed expense list
    if (expenses.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Text(
                'Detailed Expenses',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Place', 'Description', 'Items', 'Amount', 'Categories'],
                data: expenses.map((expense) {
                  final desc = expense.desc ?? '';
                  final descText = desc.length > 30 ? '${desc.substring(0, 30)}...' : desc;
                  final categories = expense.getSpentTypes().join(', ');
                  return [
                    DateFormat('MMM dd').format(expense.spentAt),
                    expense.spentPlace,
                    descText,
                    '${expense.items.length}',
                    '${expense.currency} ${expense.totalValue.toStringAsFixed(0)}',
                    categories,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerLeft,
                },
              ),
            ];
          },
        ),
      );
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildPdfSummaryCard(String title, String value) {
    return pw.Container(
      width: 150,
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getCategoryBreakdown(List<Expense> expenses) {
    final breakdown = <String, double>{};
    for (var expense in expenses) {
      for (var item in expense.items) {
        breakdown[item.spentType] =
            (breakdown[item.spentType] ?? 0) + item.value;
      }
    }
    return breakdown;
  }
}
