import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/task_details_provider.dart'; // O provider principal
import 'package:itasks/core/providers/auth_provider.dart'; // Para autenticação e IDs do Manager
import 'package:itasks/core/widgets/glass_card.dart'; // O teu widget de vidro
import 'package:itasks/core/widgets/custom_snackbar.dart';
// Assumindo que AppUser e TaskType Models estão disponíveis para o Dropdown
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/task_type_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task? task; // Se null = Criar Nova
  final bool isReadOnly;

  const TaskDetailsScreen({super.key, this.task, required this.isReadOnly});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores inicializados com valores vazios
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  bool get _isCreating => widget.task == null;

  @override
  void initState() {
    super.initState();

    // Utilizamos addPostFrameCallback para garantir que o contexto está disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TaskDetailsProvider>(context, listen: false);

      // 1. Carregar listas (devs e tipos)
      provider.loadDropdownData();

      // 2. Definir dados da Task (se edição) ou limpar (se criação)
      if (widget.task != null) {
        provider.setTaskData(widget.task!);
      } else {
        provider.clearForm(); // Limpar se for nova
      }

      // 3. Atualizar Controllers com os dados carregados
      _descController.text = provider.description;
      _pointsController.text = provider.storyPoints > 0 ? provider.storyPoints.toString() : '';

      // Adicionar Listeners para atualizar o Provider em tempo real
      _descController.addListener(
        () => provider.setDescription(_descController.text),
      );
      _pointsController.addListener(() {
        final points = int.tryParse(_pointsController.text) ?? 0;
        provider.setStoryPoints(points);
      });
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _pointsController.dispose();
    // Não é necessário dar dispose a _orderController se não foi inicializado/usado
    super.dispose();
  }

  // Função centralizada para guardar a tarefa
  void _saveForm() async {
    // Se for modo read-only, o botão de salvar não deve sequer aparecer, mas é uma segurança.
    if (widget.isReadOnly) return;

    if (_formKey.currentState!.validate()) {
      final taskProvider = context.read<TaskDetailsProvider>();
      final authProvider = context.read<AuthProvider>();

      // Usamos o ID do AppUser logado (esperando que seja o Manager)
      final managerId = authProvider.appUser?.id;
      final existingTaskId = widget.task?.id; // ID existe se for edição

      if (managerId == null) {
        if (mounted) {
          CustomSnackBar.showError(
            context,
            'Erro: Gestor não identificado. Faça login novamente.',
          );
        }
        return;
      }

      // Inicia o processo de gravação no Provider
      final managerIdStr = managerId.toString(); // saveTask expects a String id
      bool success = false;
      try {
        success = await taskProvider.saveTask(
          managerIdStr, // ID do Gestor responsável (string)
          existingTaskId: existingTaskId,
        );
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Erro ao salvar: ${e.toString()}');
        }
        return;
      }

      if (success && mounted) {
        final actionText = _isCreating ? 'criada' : 'atualizada';
        CustomSnackBar.showSuccess(context, 'Tarefa $actionText com sucesso!');
        Navigator.of(context).pop();
      }
    }
  }

  // Função para apagar a tarefa
  void _deleteTask() async {
    // Só pode apagar se estiver a editar (não criar)
    if (_isCreating || widget.task == null) return;

    // Confirmar antes de apagar
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminação'),
        content: Text(
          'Tem a certeza que deseja eliminar a tarefa "${widget.task!.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final taskProvider = context.read<TaskDetailsProvider>();
      final success = await taskProvider.deleteTask(widget.task!.id);

      if (mounted) {
        if (success) {
          CustomSnackBar.showSuccess(context, 'Tarefa eliminada com sucesso!');
          Navigator.of(context).pop(true); // Voltar e refrescar
        } else {
          CustomSnackBar.showError(context, 'Erro ao eliminar tarefa');
        }
      }
    }
  }

  // Função para mostrar o DatePicker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    if (widget.isReadOnly) return;

    final provider = context.read<TaskDetailsProvider>();
    final initialDate = isStartDate
        ? provider.plannedStartDate
        : provider.plannedEndDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      if (isStartDate) {
        provider.setPlannedStartDate(picked);
      } else {
        provider.setPlannedEndDate(picked);
      }

      // Validação de datas como no código original (adaptado para usar o Provider)
      _validateDates(provider);
    }
  }

  // Método para validar datas (adaptado para usar o Provider)
  void _validateDates(TaskDetailsProvider provider) {
    if (provider.plannedEndDate.isBefore(provider.plannedStartDate)) {
      CustomSnackBar.showInfo(
        context,
        'Data de fim deve ser posterior à data de início. Ajustada.',
      );
      // Ajusta a data de fim para ser igual à data de início
      provider.setPlannedEndDate(provider.plannedStartDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ouve o Provider para reagir a alterações de estado
    final provider = context.watch<TaskDetailsProvider>();
    final authProvider = context.read<AuthProvider>();

    final isEditing = widget.task != null;
    final isManager = authProvider.appUser?.type == 'Manager';
    final isEditable = !widget.isReadOnly && isManager;

    // Se o Provider ainda não carregou os dados iniciais
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botão Apagar visível apenas se for edição
          if (isEditing && isEditable)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: provider.isLoading ? null : _deleteTask,
              tooltip: 'Eliminar tarefa',
            ),
          // Botão Guardar visível apenas se for editável
          if (isEditable)
            IconButton(
              icon: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
              onPressed: provider.isLoading ? null : _saveForm,
              tooltip: 'Guardar tarefa',
            ),
        ],
      ),
      body: Container(
        // Fundo gradiente
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Título ---
                      Text(
                        isEditing ? "Detalhes da Tarefa" : "Criar Nova Tarefa",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 20),

                      // --- Descrição ---
                      _buildTextField(
                        controller: _descController,
                        label: 'Descrição',
                        maxLines: 3,
                        isEnabled: isEditable,
                        validator: (val) => val!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 20),

                      // --- Story Points ---
                      _buildTextField(
                        controller: _pointsController,
                        label: 'Story Points',
                        keyboardType: TextInputType.number,
                        isEnabled: isEditable,
                        validator: (val) {
                          if (val!.isEmpty) return 'Obrigatório';
                          if (int.tryParse(val) == null || int.parse(val) < 0) {
                            return 'Deve ser um número inteiro não negativo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Dropdown: Tipo de Tarefa ---
                      _buildTaskTypeDropdown(
                        provider.taskTypesList,
                        provider.selectedTaskTypeId,
                        isEditable,
                        (val) => provider.setTaskTypeId(val),
                      ),
                      const SizedBox(height: 20),

                      // --- Dropdown: Programador ---
                      _buildDeveloperDropdown(
                        provider.developersList,
                        provider.selectedDeveloperId,
                        isEditable,
                        (val) => provider.setDeveloperId(val),
                      ),
                      const SizedBox(height: 20),

                      // --- Datas Planeadas ---
                      Text(
                        'Datas Planeadas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      _buildDatePicker(
                        'Início Planeado',
                        provider.plannedStartDate,
                        (context) =>
                            _selectDate(context, true), // isStartDate = true
                        isEditable,
                      ),
                      _buildDatePicker(
                        'Fim Planeado',
                        provider.plannedEndDate,
                        (context) =>
                            _selectDate(context, false), // isStartDate = false
                        isEditable,
                      ),
                      const SizedBox(height: 20),

                      // --- Datas Reais (Apenas em edição/leitura) ---
                      if (isEditing) ...[
                        Text(
                          'Datas e Estado Reais',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildReadOnlyField(
                          'Status Atual',
                          widget.task!.toString(),
                        ),
                        // Mostra as datas reais se existirem
                        if (widget.task!.realStartDate != null)
                          _buildReadOnlyField(
                            'Início Real',
                            '${widget.task!.realStartDate!.day}/${widget.task!.realStartDate!.month}/${widget.task!.realStartDate!.year}',
                          ),
                        if (widget.task!.realEndDate != null)
                          _buildReadOnlyField(
                            'Fim Real',
                            '${widget.task!.realEndDate!.day}/${widget.task!.realEndDate!.month}/${widget.task!.realEndDate!.year}',
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  // Helper para campos de texto genéricos
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required bool isEnabled,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white10,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: isEnabled,
      readOnly: !isEnabled,
      validator: validator,
    );
  }

  // Helper para criar dropdown de Tipo de Tarefa
  Widget _buildTaskTypeDropdown(
    List<dynamic> taskTypes,
    int? currentValue,
    bool isEditable,
    Function(int?) onChanged,
  ) {
    // Filtrar apenas task types com IDs válidos e únicos
    final validTypes = <int, dynamic>{};
    for (var type in taskTypes) {
      final id = (type as dynamic).id as int?;
      if (id != null && id > 0 && !validTypes.containsKey(id)) {
        validTypes[id] = type;
      }
    }
    
    // Se o currentValue não existe na lista, limpar
    final safeValue = validTypes.containsKey(currentValue) ? currentValue : null;
    
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Tipo de Tarefa',
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(),
      ),
      value: safeValue,
      items: validTypes.entries.map((entry) {
        final type = entry.value;
        final name =
            (type as dynamic).name ??
            (type as dynamic).title ??
            type.toString();
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(name.toString()),
        );
      }).toList(),
      onChanged: isEditable ? onChanged : null,
      validator: (val) => val == null ? 'Selecione um tipo' : null,
      isExpanded: true,
    );
  }

  // Helper para criar dropdown de Programador
  Widget _buildDeveloperDropdown(
    List<AppUser> developers,
    int? currentValue,
    bool isEditable,
    Function(int?) onChanged,
  ) {
    // Filtrar apenas developers com IDs válidos e únicos
    final validDevs = <int, AppUser>{};
    for (var dev in developers) {
      if (dev.id > 0) {
        validDevs[dev.id] = dev;
      }
    }
    
    // Se o currentValue não existe na lista, limpar
    final safeValue = validDevs.containsKey(currentValue) ? currentValue : null;
    
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Atribuir a Programador',
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(),
      ),
      value: safeValue,
      items: validDevs.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(entry.value.name),
        );
      }).toList(),
      onChanged: isEditable ? onChanged : null,
      validator: (val) => val == null ? 'Selecione um programador' : null,
      isExpanded: true,
    );
  }

  // Helper para campos de Data (Planeada)
  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Future<void> Function(BuildContext) onTap,
    bool isEditable,
  ) {
    return GlassCard(
      // Um pouco mais subtil
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(label),
        subtitle: Text(
          date == null
              ? 'Não definida'
              : '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: isEditable ? const Icon(Icons.edit) : null,
        onTap: isEditable ? () => onTap(context) : null,
      ),
    );
  }

  // Helper para campos de Dados Reais (read-only)
  Widget _buildReadOnlyField(String label, String value) {
    return GlassCard(
      child: ListTile(
        dense: true,
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.info_outline, size: 18),
      ),
    );
  }
}
