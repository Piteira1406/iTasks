import 'package:flutter/foundation.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/task_type_model.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/csv_service.dart';
import 'package:itasks/core/services/logger_service.dart';

enum ReportType {
  completedTasksByManager,
  completedTasksByDeveloper,
  ongoingTasks,
  allTasks,
  tasksByStatus,
}

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final CsvService _csvService;

  ReportProvider(this._firestoreService, this._csvService);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  List<Task> _tasks = [];
  List<Developer> _developers = [];
  List<Manager> _managers = [];
  List<TaskTypeModel> _taskTypes = [];
  
  // StoryPoints estimation
  double _averageHoursPerStoryPoint = 0.0;
  double _estimatedHoursForTodo = 0.0;

  double get averageHoursPerStoryPoint => _averageHoursPerStoryPoint;
  double get estimatedHoursForTodo => _estimatedHoursForTodo;
  
  // Filtros
  ReportType _selectedReportType = ReportType.completedTasksByManager;
  int? _selectedManagerId;
  int? _selectedDeveloperId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Task> get tasks => _tasks;
  List<Developer> get developers => _developers;
  List<Manager> get managers => _managers;
  List<TaskTypeModel> get taskTypes => _taskTypes;
  ReportType get selectedReportType => _selectedReportType;
  int? get selectedManagerId => _selectedManagerId;
  int? get selectedDeveloperId => _selectedDeveloperId;
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Estatísticas calculadas
  Map<String, dynamic> get statistics {
    if (_tasks.isEmpty) return {};

    final completed = _tasks.where((t) => t.taskStatus == 'Done').length;
    final ongoing = _tasks.where((t) => t.taskStatus == 'Doing').length;
    final todo = _tasks.where((t) => t.taskStatus == 'ToDo').length;
    
    final totalStoryPoints = _tasks.fold<int>(0, (sum, task) => sum + task.storyPoints);
    final completedStoryPoints = _tasks
        .where((t) => t.taskStatus == 'Done')
        .fold<int>(0, (sum, task) => sum + task.storyPoints);

    // Calcular tempo médio de conclusão
    final completedWithDates = _tasks.where((t) => 
      t.taskStatus == 'Done' && 
      t.realStartDate != null && 
      t.realEndDate != null
    ).toList();

    Duration? averageCompletionTime;
    if (completedWithDates.isNotEmpty) {
      final totalDuration = completedWithDates.fold<Duration>(
        Duration.zero,
        (sum, task) => sum + task.realEndDate!.difference(task.realStartDate!),
      );
      averageCompletionTime = Duration(
        minutes: (totalDuration.inMinutes / completedWithDates.length).round(),
      );
    }

    return {
      'total': _tasks.length,
      'completed': completed,
      'ongoing': ongoing,
      'todo': todo,
      'totalStoryPoints': totalStoryPoints,
      'completedStoryPoints': completedStoryPoints,
      'averageCompletionTime': averageCompletionTime,
      'completionRate': _tasks.isNotEmpty 
          ? ((completed / _tasks.length) * 100).toStringAsFixed(1) 
          : '0.0',
    };
  }

  // Métodos de filtro
  void setReportType(ReportType type) {
    _selectedReportType = type;
    notifyListeners();
  }

  void setSelectedManager(int? managerId) {
    _selectedManagerId = managerId;
    notifyListeners();
  }

  void setSelectedDeveloper(int? developerId) {
    _selectedDeveloperId = developerId;
    notifyListeners();
  }

  void setSelectedStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getAllDevelopers(),
        _firestoreService.getAllManagers(),
        _firestoreService.getTaskTypes(),
      ]);

      _developers = results[0] as List<Developer>;
      _managers = results[1] as List<Manager>;
      _taskTypes = results[2] as List<TaskTypeModel>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados: $e';
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error loading initial data', e);
    }
  }

  // Gerar relatório
  Future<void> generateReport() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      List<Task> allTasks = [];

      // Buscar tasks baseado no tipo de relatório
      switch (_selectedReportType) {
        case ReportType.completedTasksByManager:
          if (_selectedManagerId == null) {
            throw Exception('Selecione um gestor');
          }
          allTasks = await _firestoreService.getCompletedTasksForManager(_selectedManagerId!);
          break;

        case ReportType.completedTasksByDeveloper:
          if (_selectedDeveloperId == null) {
            throw Exception('Selecione um programador');
          }
          allTasks = await _firestoreService.getCompletedTasksForDeveloper(_selectedDeveloperId!);
          break;

        case ReportType.ongoingTasks:
          if (_selectedManagerId == null) {
            throw Exception('Selecione um gestor');
          }
          allTasks = await _firestoreService.getOngoingTasksForManager(_selectedManagerId!);
          break;

        case ReportType.allTasks:
          allTasks = await _firestoreService.getTasks();
          break;

        case ReportType.tasksByStatus:
          if (_selectedStatus == null) {
            throw Exception('Selecione um status');
          }
          allTasks = await _firestoreService.getTasks();
          allTasks = allTasks.where((t) => t.taskStatus == _selectedStatus).toList();
          break;
      }

      // Aplicar filtros de data
      if (_startDate != null) {
        allTasks = allTasks.where((t) => t.creationDate.isAfter(_startDate!)).toList();
      }
      if (_endDate != null) {
        allTasks = allTasks.where((t) => t.creationDate.isBefore(_endDate!)).toList();
      }

      _tasks = allTasks;
      _successMessage = 'Relatório gerado com sucesso! ${allTasks.length} tarefa(s) encontrada(s).';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error generating report', e);
    }
  }

  // Exportar para CSV
  Future<String?> exportToCSV() async {
    if (_tasks.isEmpty) {
      _errorMessage = 'Não há dados para exportar';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final developerNames = <int, String>{};
      for (var dev in _developers) {
        developerNames[dev.id] = dev.name;
      }

      final taskTypeNames = <int, String>{};
      for (var type in _taskTypes) {
        taskTypeNames[type.id] = type.name;
      }

      // Exportar
      final filePath = await _csvService.exportTasksToCSV(
        tasks: _tasks,
        developerNames: developerNames,
        taskTypeNames: taskTypeNames,
      );

      if (filePath != null) {
        _successMessage = 'Relatório exportado com sucesso!\n\nArquivo salvo em:\n$filePath';
        _isLoading = false;
        notifyListeners();
        return filePath;
      } else {
        throw Exception('Não foi possível salvar o arquivo');
      }
    } catch (e) {
      _errorMessage = 'Erro ao exportar: $e';
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error exporting CSV', e);
      return null;
    }
  }

  // Exportar estatísticas
  Future<String?> exportStatistics() async {
    if (_tasks.isEmpty) {
      _errorMessage = 'Não há dados para exportar';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final filePath = await _csvService.exportStatisticsToCSV(
        statistics: statistics,
      );

      if (filePath != null) {
        _successMessage = 'Estatísticas exportadas!\n\nArquivo salvo em:\n$filePath';
        _isLoading = false;
        notifyListeners();
        return filePath;
      } else {
        throw Exception('Não foi possível salvar o arquivo');
      }
    } catch (e) {
      _errorMessage = 'Erro ao exportar estatísticas: $e';
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error exporting statistics', e);
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearFilters() {
    _selectedManagerId = null;
    _selectedDeveloperId = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _tasks = [];
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Calculate average time per StoryPoint from completed tasks
  Future<void> calculateStoryPointsAverage() async {
    try {
      final completedTasks = await _firestoreService.getCompletedTasks();
      
      double totalHours = 0;
      int totalStoryPoints = 0;
      int validTasksCount = 0;
      
      for (var task in completedTasks) {
        // Only count tasks with real dates and storyPoints > 0
        if (task.realStartDate != null && 
            task.realEndDate != null && 
            task.storyPoints > 0) {
          
          final duration = task.realEndDate!.difference(task.realStartDate!);
          final hours = duration.inHours.toDouble();
          
          totalHours += hours;
          totalStoryPoints += task.storyPoints;
          validTasksCount++;
        }
      }
      
      // Calculate average (avoid division by zero)
      _averageHoursPerStoryPoint = totalStoryPoints > 0 
          ? totalHours / totalStoryPoints 
          : 0.0;
      
      LoggerService.info(
        'StoryPoints Average calculated: $_averageHoursPerStoryPoint hours/SP from $validTasksCount tasks'
      );
      
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error calculating StoryPoints average', e);
      _averageHoursPerStoryPoint = 0.0;
    }
  }

  /// Calculate estimated time for all ToDo tasks of a developer
  Future<void> calculateEstimatedTimeForTodo(int developerId) async {
    try {
      // First ensure we have the average
      if (_averageHoursPerStoryPoint == 0.0) {
        await calculateStoryPointsAverage();
      }
      
      // Get ToDo tasks
      final todoTasks = await _firestoreService.getTodoTasksByDeveloper(developerId);
      
      // Sum all StoryPoints from ToDo tasks
      int totalStoryPoints = todoTasks.fold(
        0, 
        (sum, task) => sum + task.storyPoints
      );
      
      // Calculate estimated time
      _estimatedHoursForTodo = _averageHoursPerStoryPoint * totalStoryPoints;
      
      LoggerService.info(
        'Estimated time for developer $developerId: $_estimatedHoursForTodo hours ($totalStoryPoints SP)'
      );
      
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error calculating estimated time for ToDo', e);
      _estimatedHoursForTodo = 0.0;
    }
  }

  /// Get formatted estimation text for UI
  String getEstimationText() {
    if (_estimatedHoursForTodo == 0.0) {
      return 'Sem estimativa disponível';
    }
    
    final days = (_estimatedHoursForTodo / 8).ceil(); // 8 hours per day
    final hours = _estimatedHoursForTodo.toInt();
    
    return '$hours horas (~$days dias úteis)';
  }

  /// Get average time per StoryPoint formatted
  String getAverageText() {
    if (_averageHoursPerStoryPoint == 0.0) {
      return 'Sem dados históricos';
    }
    
    return '${_averageHoursPerStoryPoint.toStringAsFixed(1)} horas/SP';
  }
}