// Implementação Web do CSV Service
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Download de arquivo na Web usando dart:html
Future<void> downloadFile(String content, String filename) async {
  // Criar blob com o conteúdo CSV
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Criar elemento <a> para download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  
  // Limpar URL
  html.Url.revokeObjectUrl(url);
}
