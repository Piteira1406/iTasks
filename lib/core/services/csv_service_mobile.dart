// Implementação Mobile/Desktop do CSV Service
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:itasks/core/services/logger_service.dart';

/// Download de arquivo no Mobile/Desktop
Future<void> downloadFile(String content, String filename) async {
  try {
    // 1. Solicitar permissões no Android
    if (Platform.isAndroid) {
      final granted = await _requestPermissions();
      if (!granted) {
        throw Exception('Permissões de armazenamento negadas');
      }
    }

    // 2. Obter diretório apropriado
    Directory? directory;

    if (Platform.isAndroid) {
      // Android: Tentar salvar em Downloads
      directory = Directory('/storage/emulated/0/Download');
      
      if (!await directory.exists()) {
        // Fallback para external storage
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      // iOS: Salvar em Documents
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Desktop: Tentar Downloads, senão Documents
      directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Não foi possível acessar o diretório');
    }

    // 3. Criar e salvar arquivo
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsString(content);

    LoggerService.info('Arquivo salvo em: $filePath');

    // 4. Compartilhar arquivo (mostra notificação de sucesso)
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'iTasks Export',
      text: 'Arquivo exportado com sucesso!\n\nArquivo: $filename\nLocal: $filePath',
    );
  } catch (e) {
    LoggerService.error('Erro ao salvar arquivo', e);
    rethrow;
  }
}

/// Solicita permissões de armazenamento
Future<bool> _requestPermissions() async {
  try {
    // Android 13+ (API 33+) usa permissões diferentes
    if (await Permission.photos.request().isGranted ||
        await Permission.videos.request().isGranted) {
      return true;
    }

    // Tentar permissão legada
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    // Última tentativa: manage external storage
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    return false;
  } catch (e) {
    LoggerService.error('Erro ao solicitar permissões', e);
    return false;
  }
}
