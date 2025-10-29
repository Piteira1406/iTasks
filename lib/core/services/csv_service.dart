import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CsvService {
  /// Gera e partilha um ficheiro CSV
  /// [rows] é uma lista de listas. A primeira lista interna deve ser os cabeçalhos.
  /// Ex: [ ['Nome', 'Email'], ['Ana', 'ana@email.com'], ['Carlos', 'carlos@email.com'] ]
  Future<bool> generateAndShareCsv(
    List<List<dynamic>> rows,
    String fileName,
  ) async {
    try {
      // 1. Pedir permissão de armazenamento
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        if (await Permission.storage.isDenied) {
          print("Permissão de armazenamento negada.");
          return false;
        }
      }

      // 2. Converter os dados para uma string CSV
      String csvData = const ListToCsvConverter().convert(rows);

      // 3. Obter o diretório temporário
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';

      // 4. Criar e escrever o ficheiro
      final File file = File(filePath);
      await file.writeAsString(csvData);

      // 5. Partilhar o ficheiro
      final result = await Share.shareXFiles([
        XFile(filePath),
      ], subject: 'Relatório iTasks: $fileName');

      // Verificar se a partilha foi bem-sucedida
      return result.status == ShareResultStatus.success;
    } catch (e) {
      print("Erro ao gerar ou partilhar CSV: $e");
      return false;
    }
  }
}
