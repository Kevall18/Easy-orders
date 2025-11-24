// lib/core/services/pdf_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  /// Generate PDF document from order with all items (multi-page support)
  Future<pw.Document> generateOrderPdf(
      OrderModel order,
      String userName,
      ) async {
    final pdf = pw.Document();

    // Load custom fonts
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    // Define colors
    final primaryColor = PdfColor.fromHex('#1F2937');
    final borderColor = PdfColor.fromHex('#E5E7EB');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // User Name - Alone in row, bigger and bold
              pw.Center(
                child: pw.Text(
                  userName.toUpperCase(),
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 22,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Party Name and Order Date row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Party Name only
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          order.partyName,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Order Date only
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Order Date: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 11,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

              // Table Header
              _buildTableHeader(primaryColor, borderColor, ttfBold),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Table Rows (will automatically paginate)
            ..._buildTableRows(order, borderColor, ttf, ttfBold),
          ];
        },
        footer: (pw.Context context) {
          return _buildPdfFooter(borderColor, ttf, context);
        },
      ),
    );

    return pdf;
  }

  /// Build Table Header
  pw.Widget _buildTableHeader(
      PdfColor primaryColor,
      PdfColor borderColor,
      pw.Font boldFont,
      ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor),
        color: PdfColors.grey300,
      ),
      child: pw.Row(
        children: [
          _buildTableHeaderCell('Design No', 1.5, boldFont, primaryColor),
          _buildTableHeaderCell('Quality Name', 1.5, boldFont, primaryColor), // NEW COLUMN
          _buildTableHeaderCell('PCS', 1, boldFont, primaryColor),
          _buildTableHeaderCell('Dispatched\nPCS', 1.2, boldFont, primaryColor),
          _buildTableHeaderCell('Item\nStatus', 1.2, boldFont, primaryColor),
          _buildTableHeaderCell('Delivery\nStatus', 1.5, boldFont, primaryColor),
          _buildTableHeaderCell('Dispatch\nDate', 1.2, boldFont, primaryColor),
        ],
      ),
    );
  }

  /// Build Table Header Cell
  pw.Widget _buildTableHeaderCell(
      String text,
      double flex,
      pw.Font font,
      PdfColor color,
      ) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 9,
            color: color,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Build Table Rows
  List<pw.Widget> _buildTableRows(
      OrderModel order,
      PdfColor borderColor,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return order.items.map((item) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor),
        ),
        child: pw.Row(
          children: [
            _buildTableCell(item.designNo, 1.5, regularFont),
            _buildTableCell(item.qualityName, 1.5, regularFont), // NEW COLUMN DATA
            _buildTableCell(item.pcs.toString(), 1, regularFont),
            _buildTableCell(item.dispatchedPcs.toString(), 1.2, regularFont),
            _buildTableCell(
              item.itemStatus == 'pending' ? 'Pending' : 'Finishing',
              1.2,
              regularFont,
            ),
            _buildTableCell(
              item.deliveryStatus == 'awaiting_dispatch'
                  ? 'Awaiting Dispatch'
                  : 'Dispatched',
              1.5,
              regularFont,
            ),
            _buildTableCell(
              item.dispatchDate != null
                  ? DateFormat('dd/MM/yyyy').format(item.dispatchDate!)
                  : '-',
              1.2,
              regularFont,
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Build Table Cell
  pw.Widget _buildTableCell(
      String text,
      double flex,
      pw.Font font,
      ) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Build PDF Footer with page numbers
  pw.Widget _buildPdfFooter(
      PdfColor borderColor,
      pw.Font regularFont,
      pw.Context context,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated on ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Preview PDF
  Future<void> previewPdf(OrderModel order, String userName) async {
    final pdf = await generateOrderPdf(order, userName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Save PDF to local storage
  Future<String?> savePdfToLocal(OrderModel order, String userName) async {
    try {
      final pdf = await generateOrderPdf(order, userName);
      final bytes = await pdf.save();

      if (kIsWeb) {
        // For web, download the file
        final fileName = _generateFileName(order);
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        return fileName;
      } else {
        // For mobile/desktop, save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = _generateFileName(order);
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      }
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }

  /// Share PDF via WhatsApp or other platforms
  Future<void> sharePdf(OrderModel order, String userName) async {
    try {
      final pdf = await generateOrderPdf(order, userName);
      final bytes = await pdf.save();

      if (kIsWeb) {
        // For web, try native share or fallback to download
        try {
          await Printing.sharePdf(bytes: bytes, filename: _generateFileName(order));
        } catch (e) {
          await Printing.sharePdf(bytes: bytes, filename: _generateFileName(order));
        }
      } else {
        // For mobile apps, save temporarily and use share_plus
        final directory = await getTemporaryDirectory();
        final fileName = _generateFileName(order);
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Order Details - ${order.partyName}',
          subject: 'Order PDF',
        );
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Generate appropriate file name
  String _generateFileName(OrderModel order) {
    final partyName = order.partyName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final orderId = (order.id ?? 'UNKNOWN')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    return 'order_${partyName}_$orderId.pdf';
  }

  /// Print PDF directly
  Future<void> printPdf(OrderModel order, String userName) async {
    try {
      final pdf = await generateOrderPdf(order, userName);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }
}