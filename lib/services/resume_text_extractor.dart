import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

/// Why extraction did or didn't produce usable text, so callers (like
/// the upload flow in profile_screen.dart) can show the right message
/// instead of just guessing from an empty string.
enum ResumeExtractionStatus {
  /// Extraction worked and produced meaningful text.
  success,

  /// The file extension isn't one we can read at all (e.g. legacy .doc,
  /// or something that isn't a resume file).
  unsupportedFormat,

  /// We opened the file and ran extraction, but got back next to
  /// nothing — most likely a scanned/image-only PDF with no real text
  /// layer, or a corrupt/empty file.
  tooShort,

  /// Something threw while parsing the file itself (corrupt archive,
  /// malformed PDF, etc).
  failed,
}

/// Result of attempting to extract text from an uploaded resume.
class ResumeExtractionResult {
  const ResumeExtractionResult({
    required this.text,
    required this.status,
  });

  /// The cleaned extracted text. Empty unless [status] is `success`.
  final String text;
  final ResumeExtractionStatus status;

  bool get isSuccess => status == ResumeExtractionStatus.success;
}

/// Extracts plain text from an uploaded resume so it can be stored and
/// later sent to Gemini for real analysis.
///
/// Supports PDF and DOCX. Legacy .doc (binary Word format) is not
/// supported — it's a proprietary binary format with no reliable pure
/// Dart reader, so callers should ask the user to upload PDF or DOCX
/// instead.
class ResumeTextExtractor {
  ResumeTextExtractor._();

  /// Below this length, extracted "text" is treated as not meaningful
  /// (e.g. a scanned PDF that yielded only a few stray characters).
  static const int _minMeaningfulLength = 50;

  /// Extracts text from raw file bytes, given the original file name
  /// (used only to determine the format from its extension). Never
  /// throws — any failure is reported via [ResumeExtractionResult.status]
  /// instead.
  static Future<ResumeExtractionResult> extract(Uint8List bytes, String fileName) async {
    final lowerName = fileName.toLowerCase();

    try {
      String raw;
      if (lowerName.endsWith('.pdf')) {
        raw = _extractPdf(bytes);
      } else if (lowerName.endsWith('.docx')) {
        raw = _extractDocx(bytes);
      } else if (lowerName.endsWith('.doc')) {
        debugPrint('[ResumeTextExtractor] Legacy .doc files are not supported for text extraction.');
        return const ResumeExtractionResult(text: '', status: ResumeExtractionStatus.unsupportedFormat);
      } else {
        debugPrint('[ResumeTextExtractor] Unrecognized file type for: $fileName');
        return const ResumeExtractionResult(text: '', status: ResumeExtractionStatus.unsupportedFormat);
      }

      final cleaned = _cleanText(raw);

      if (cleaned.length < _minMeaningfulLength) {
        debugPrint(
          '[ResumeTextExtractor] Extracted text too short (${cleaned.length} chars) for $fileName — '
          'likely a scanned/image-only PDF or empty document.',
        );
        return ResumeExtractionResult(text: cleaned, status: ResumeExtractionStatus.tooShort);
      }

      return ResumeExtractionResult(text: cleaned, status: ResumeExtractionStatus.success);
    } catch (e, st) {
      debugPrint('[ResumeTextExtractor] Extraction failed for $fileName: $e\n$st');
      return const ResumeExtractionResult(text: '', status: ResumeExtractionStatus.failed);
    }
  }

  static String _extractPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      return PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }
  }

  /// A .docx file is a zip archive containing XML. The visible document
  /// text lives in word/document.xml, inside `<w:t>` elements.
  static String _extractDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentFile = archive.files.firstWhere(
      (file) => file.name == 'word/document.xml',
      orElse: () => throw Exception('word/document.xml not found in .docx'),
    );

    final xmlContent = utf8.decode(documentFile.content as List<int>);
    final document = XmlDocument.parse(xmlContent);

    final buffer = StringBuffer();
    for (final node in document.findAllElements('w:t')) {
      buffer.write(node.innerText);
      buffer.write(' ');
    }

    return buffer.toString();
  }

  /// Cleans up common PDF/DOCX extraction artifacts:
  /// - collapses runs of spaces/tabs
  /// - collapses 3+ blank lines down to a single blank line
  /// - drops lines that are just a bare page number (e.g. "3" or "Page 3 of 5"),
  ///   since these add noise without adding resume content
  static String _cleanText(String raw) {
    final pageNumberLine = RegExp(r'^\s*(page\s+)?\d+(\s*(of|/)\s*\d+)?\s*$', caseSensitive: false);

    final lines = raw.split('\n').where((line) => !pageNumberLine.hasMatch(line)).join('\n');

    return lines.replaceAll(RegExp(r'[ \t]+'), ' ').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}