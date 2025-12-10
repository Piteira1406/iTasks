import 'dart:html' as html;
import 'dart:convert';

/// Download de arquivo na Web usando dart:html
Future<void> downloadFile(String content, String filename) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  
  // Limpar URL
  html.Url.revokeObjectUrl(url);
}
