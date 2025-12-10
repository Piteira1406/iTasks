import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:itasks/core/services/logger_service.dart';

Future<void> downloadFile(String content, String filename) async {
  try {
    if (Platform.isAndroid) {
      final granted = await _requestPermissions();
      if (!granted) {
        throw Exception('Permissões de armazenamento negadas');
      }
    }

    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
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

Future<bool> _requestPermissions() async {
  try {
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
