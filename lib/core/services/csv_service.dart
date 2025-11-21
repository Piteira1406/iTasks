import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/services/logger_service.dart';

// Conditional imports para Web e Mobile
import 'csv_service_stub.dart'
    if (dart.library.html) 'csv_service_web.dart'
    if (dart.library.io) 'csv_service_mobile.dart' as platform;

class CsvService {
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Exporta tarefas para CSV com download automático
  Future<String?> exportTasksToCSV({
    required List<Task> tasks,
    required Map<int, String> developerNames,
    required Map<int, String> taskTypeNames,
    String? customFileName,
  }) async {
    try {
      // 1. Criar cabeçalhos do CSV
      List<List<dynamic>> rows = [
        [
          'Programador',
          'Descricao',
          'DataPrevInicio',
          'DataPrevFim',
          'DataRealInicio',
          'DataRealFim',
        ],
      ];

      // 2. Adicionar dados das tarefas
      for (var task in tasks) {
        final developerName = developerNames[task.idDeveloper] ?? 'Desconhecido (ID: ${task.idDeveloper})';
        
        final hasRealDates = task.realStartDate != null && task.realEndDate != null;
        
        rows.add([
          developerName,
          task.description,
          _dateFormat.format(task.previsionStartDate),
          _dateFormat.format(task.previsionEndDate),
          hasRealDates ? _dateFormat.format(task.realStartDate!) : 'N/A',
          hasRealDates ? _dateFormat.format(task.realEndDate!) : 'N/A',
        ]);
      }

      // 3. Converter para CSV
      String csv = const ListToCsvConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(rows);

      // 4. Gerar nome do arquivo
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = customFileName ?? 'iTasks_Relatorio_$timestamp.csv';

      // 5. Download usando implementação da plataforma (Web ou Mobile)
      await platform.downloadFile(csv, filename);
      LoggerService.info('Arquivo CSV exportado: $filename');
      return filename;
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

      await platform.downloadFile(csv, filename);
      LoggerService.info('Arquivo CSV de estatísticas exportado: $filename');
      return filename;
    } catch (e) {
      LoggerService.error('Erro ao exportar estatísticas', e);
      rethrow;
    }
  }

  /// Formata Duration para string legível
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}