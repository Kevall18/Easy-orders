
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';
import '../models/master_data_model.dart';
import '../models/quality_model.dart';
import '../controllers/master_data_controller.dart';
import '../controllers/quality_controller.dart';
import 'package:get/get.dart';

class OrderItemPdfService {
  static final OrderItemPdfService _instance = OrderItemPdfService._internal();
  factory OrderItemPdfService() => _instance;
  OrderItemPdfService._internal();

  final MasterDataController _masterDataController = Get.find<MasterDataController>();
  final QualityController _qualityController = Get.find<QualityController>();

  /// ⭐ Generate PDF document for a single order item (A4 with 2 identical tables)
  Future<pw.Document> generateOrderItemPdf(
      OrderItem item,
      String userName,
      ) async {
    final pdf = pw.Document();

    // Load custom fonts
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    // ⭐ Fetch master data and quality information from Firebase
    print('=== PDF Generation Started ===');
    print('Item MasterDataId: ${item.masterDataId}');

    MasterDataModel? masterData = await _masterDataController.fetchMasterDataByIdFromFirebase(item.masterDataId);
    QualityModel? quality;

    if (masterData != null) {
      print('MasterData found: ${masterData.designNo}');
      print('QualityId from MasterData: ${masterData.qualityId}');

      // Fetch quality from Firebase
      quality = await _qualityController.fetchQualityByIdFromFirebase(masterData.qualityId);

      if (quality != null) {
        print('Quality found: ${quality.qualityName}');
        print('Quality Details:');
        print('  Col1 (Fider 1): ${quality.col1}');
        print('  Col2 (Fider 2): ${quality.col2}');
        print('  Col3 (Fider 3): ${quality.col3}');
        print('  Col4 (Fider 4): ${quality.col4}');
        print('  Pick: ${quality.pick}');
      } else {
        print('⚠️ Quality NOT found for qualityId: ${masterData.qualityId}');
      }
    } else {
      print('⚠️ MasterData NOT found for masterDataId: ${item.masterDataId}');
    }

    // Calculate pattern (total pieces / 6) with 2 decimal places
    final patternValue = item.pcs / 6;
    final pattern = patternValue.toStringAsFixed(2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Top half with 2 tables
              pw.Container(
                height: (PdfPageFormat.a4.height - 80) / 2, // Half page minus margins
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left table
                    pw.Expanded(
                      child: _buildProgramTable(
                        item: item,
                        masterData: masterData,
                        quality: quality,
                        pattern: pattern,
                        ttf: ttf,
                        ttfBold: ttfBold,
                      ),
                    ),
                    pw.SizedBox(width: 30),
                    // Right table (identical)
                    pw.Expanded(
                      child: _buildProgramTable(
                        item: item,
                        masterData: masterData,
                        quality: quality,
                        pattern: pattern,
                        ttf: ttf,
                        ttfBold: ttfBold,
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom half - reduced empty space for half-page printing
              pw.Expanded(child: pw.Container()),
            ],
          );
        },
      ),
    );

    print('=== PDF Generation Completed ===\n');
    return pdf;
  }

  /// Build a single program table
  pw.Widget _buildProgramTable({
    required OrderItem item,
    required MasterDataModel? masterData,
    required QualityModel? quality,
    required String pattern,
    required pw.Font ttf,
    required pw.Font ttfBold,
  }) {
    final primaryColor = PdfColor.fromHex('#000000');
    final borderColor = PdfColor.fromHex('#000000');

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1.5),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Jalu header row
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: borderColor, width: 1.5),
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Jalu:',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 13,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  item.jaluNo.toString(),
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 13,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Machine No row (empty field)
          _buildTableRow(
            label: 'Machine No',
            value: '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // File Name row
          _buildTableRow(
            label: 'File Name',
            value: item.fileName,
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Fider 1 row
          _buildTableRow(
            label: 'Fider 1',
            value: quality?.col1 ?? '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Fider 2 row
          _buildTableRow(
            label: 'Fider 2',
            value: quality?.col2 ?? '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Fider 3 row
          _buildTableRow(
            label: 'Fider 3',
            value: quality?.col3 ?? '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Fider 4 row
          _buildTableRow(
            label: 'Fider 4',
            value: quality?.col4 ?? '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Pick row
          _buildTableRow(
            label: 'Pick',
            value: quality?.pick?.toString() ?? '',
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
          ),

          // Pattern row (WITH border at bottom - FIXED)
          _buildTableRow(
            label: 'Patten',
            value: pattern,
            ttf: ttf,
            ttfBold: ttfBold,
            primaryColor: primaryColor,
            borderColor: borderColor,
            isLast: false, // Shows bottom border
          ),

          // Empty space at bottom (reduced for half-page printing)
          pw.Container(
            height: 40, // Reduced from 80 to 40
          ),
        ],
      ),
    );
  }

  /// Build a single table row
  pw.Widget _buildTableRow({
    required String label,
    required String value,
    required pw.Font ttf,
    required pw.Font ttfBold,
    required PdfColor primaryColor,
    required PdfColor borderColor,
    bool isLast = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: isLast
              ? pw.BorderSide.none
              : pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: pw.Row(
        children: [
          pw.Container(
            width: 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Preview PDF
  Future<void> previewPdf(OrderItem item, String userName) async {
    try {
      final pdf = await generateOrderItemPdf(item, userName);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error previewing PDF: $e');
      rethrow;
    }
  }

  /// Save PDF to local storage
  Future<String?> savePdfToLocal(OrderItem item, String userName) async {
    try {
      final pdf = await generateOrderItemPdf(item, userName);
      final bytes = await pdf.save();

      if (kIsWeb) {
        final fileName = _generateFileName(item);
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        return fileName;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = _generateFileName(item);
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
  Future<void> sharePdf(OrderItem item, String userName) async {
    try {
      final pdf = await generateOrderItemPdf(item, userName);
      final bytes = await pdf.save();

      if (kIsWeb) {
        try {
          await Printing.sharePdf(bytes: bytes, filename: _generateFileName(item));
        } catch (e) {
          await Printing.sharePdf(bytes: bytes, filename: _generateFileName(item));
        }
      } else {
        final directory = await getTemporaryDirectory();
        final fileName = _generateFileName(item);
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Order Item Program - ${item.designNo}',
          subject: 'Order Item PDF',
        );
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Generate appropriate file name
  String _generateFileName(OrderItem item) {
    final designNo = item.designNo
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final fileName = item.fileName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    return 'program_${designNo}_${fileName}.pdf';
  }

  /// Print PDF directly
  Future<void> printPdf(OrderItem item, String userName) async {
    try {
      final pdf = await generateOrderItemPdf(item, userName);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }
}