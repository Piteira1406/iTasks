import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/services/logger_service.dart';

class CsvService {
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Exporta tarefas para CSV com download automático
  Future<String?> exportTasksToCSV({
    required List<Task> tasks,
    required Map<int, String> developerNames,
    required Map<int, String> taskTypeNames,
    String? customFileName,
  }) async {
    try {
      // 1. Solicitar permissões
      if (Platform.isAndroid) {
        final granted = await _requestPermissions();
        if (!granted) {
          throw Exception('Permissões de armazenamento negadas');
        }
      }

      // 2. Criar cabeçalhos do CSV
      List<List<dynamic>> rows = [
        [
          'ID',
          'Descrição',
          'Status',
          'Story Points',
          'Ordem de Execução',
          'Programador',
          'Tipo de Tarefa',
          'Data de Criação',
          'Início Previsto',
          'Fim Previsto',
          'Início Real',
          'Fim Real',
          'Tempo Previsto (dias)',
          'Tempo Real (dias)',
          'Tempo Real (horas)',
          'Diferença (dias)',
        ],
      ];

      // 3. Adicionar dados das tarefas
      for (var task in tasks) {
        // Buscar nomes
        final developerName = developerNames[task.idDeveloper] ?? 'Desconhecido (ID: ${task.idDeveloper})';
        final taskTypeName = taskTypeNames[task.idTaskType] ?? 'Desconhecido (ID: ${task.idTaskType})';

        // Calcular tempos
        final plannedDays = task.previsionEndDate.difference(task.previsionStartDate).inDays + 1;
        
        final hasRealDates = task.realStartDate != null && task.realEndDate != null;
        final realDays = hasRealDates 
            ? task.realEndDate!.difference(task.realStartDate!).inDays + 1
            : null;
        final realHours = hasRealDates 
            ? task.realEndDate!.difference(task.realStartDate!).inHours
            : null;
        final difference = hasRealDates 
            ? realDays! - plannedDays
            : null;

        rows.add([
          task.id,
          task.description,
          _translateStatus(task.taskStatus),
          task.storyPoints,
          task.order,
          developerName,
          taskTypeName,
          _dateTimeFormat.format(task.creationDate),
          _dateTimeFormat.format(task.previsionStartDate),
          _dateTimeFormat.format(task.previsionEndDate),
          hasRealDates ? _dateTimeFormat.format(task.realStartDate!) : 'N/A',
          hasRealDates ? _dateTimeFormat.format(task.realEndDate!) : 'N/A',
          plannedDays,
          realDays ?? 'N/A',
          realHours ?? 'N/A',
          difference != null 
              ? '${difference > 0 ? '+' : ''}$difference'
              : 'N/A',
        ]);
      }

      // 4. Converter para CSV
      String csv = const ListToCsvConverter().convert(rows);

      // 5. Gerar nome do arquivo
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = customFileName ?? 'iTasks_Relatorio_$timestamp.csv';

      // 6. Obter diretório e salvar
      final filePath = await _saveFile(csv, filename);
      
      if (filePath == null) {
        throw Exception('Não foi possível salvar o arquivo');
      }

      LoggerService.info('Arquivo CSV salvo em: $filePath');
      
      // 7. Compartilhar arquivo (opcional - mostra onde foi salvo)
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Relatório iTasks',
        text: 'Relatório exportado com sucesso!\n\nArquivo: $filename\nLocal: $filePath',
      );

      return filePath;
    } catch (e) {
      LoggerService.error('Erro ao exportar CSV', e);
      rethrow;
    }
  }

  /// Exporta estatísticas resumidas para CSV
  Future<String?> exportStatisticsToCSV({
    required Map<String, dynamic> statistics,
    String? customFileName,
  }) async {
    try {
      // Solicitar permissões
      if (Platform.isAndroid) {
        final granted = await _requestPermissions();
        if (!granted) {
          throw Exception('Permissões de armazenamento negadas');
        }
      }

      // Criar dados CSV
      List<List<dynamic>> rows = [
        ['Métrica', 'Valor'],
        ['Data do Relatório', _dateTimeFormat.format(DateTime.now())],
        ['', ''], // Linha vazia
        ['Total de Tarefas', statistics['total'] ?? 0],
        ['Tarefas Concluídas', statistics['completed'] ?? 0],
        ['Tarefas em Andamento', statistics['ongoing'] ?? 0],
        ['Tarefas Pendentes', statistics['todo'] ?? 0],
        ['', ''], // Linha vazia
        ['Story Points Total', statistics['totalStoryPoints'] ?? 0],
        ['Story Points Concluídos', statistics['completedStoryPoints'] ?? 0],
        ['', ''], // Linha vazia
        ['Taxa de Conclusão (%)', statistics['completionRate'] ?? '0.0'],
        ['Tempo Médio de Conclusão', 
          statistics['averageCompletionTime'] != null 
            ? _formatDuration(statistics['averageCompletionTime'] as Duration)
            : 'N/A'
        ],
      ];

      String csv = const ListToCsvConverter().convert(rows);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = customFileName ?? 'iTasks_Estatisticas_$timestamp.csv';

      final filePath = await _saveFile(csv, filename);

      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Estatísticas iTasks',
          text: 'Estatísticas exportadas!\n\nArquivo: $filename\nLocal: $filePath',
        );
      }

      return filePath;
    } catch (e) {
      LoggerService.error('Erro ao exportar estatísticas', e);
      rethrow;
    }
  }

  /// Salva arquivo no diretório apropriado
  Future<String?> _saveFile(String content, String filename) async {
    try {
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
        // Desktop/Web: Tentar Downloads, senão Documents
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Não foi possível acessar o diretório');
      }

      // Criar arquivo
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(content);

      return filePath;
    } catch (e) {
      LoggerService.error('Erro ao salvar arquivo', e);
      return null;
    }
  }

  /// Solicita permissões de armazenamento
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
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
      }
      return true; // iOS não precisa de permissão explícita
    } catch (e) {
      LoggerService.error('Erro ao solicitar permissões', e);
      return false;
    }
  }

  /// Traduz status para português
  String _translateStatus(String status) {
    switch (status) {
      case 'ToDo':
        return 'A Fazer';
      case 'Doing':
        return 'Em Progresso';
      case 'Done':
        return 'Concluído';
      default:
        return status;
    }
  }

  /// Formata Duration para string legível
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Método legado para compatibilidade (DEPRECATED)
  @Deprecated('Use exportTasksToCSV instead')
  Future<bool> generateAndShareCsv(
    List<List<dynamic>> rows,
    String fileName,
  ) async {
    try {
      String csvData = const ListToCsvConverter().convert(rows);
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsString(csvData);
      
      final result = await Share.shareXFiles([
        XFile(filePath),
      ], subject: 'Relatório iTasks: $fileName');
      
      return result.status == ShareResultStatus.success;
    } catch (e) {
      LoggerService.error("Failed to generate or share CSV", e);
      return false;
    }
  }
}