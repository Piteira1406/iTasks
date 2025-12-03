import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';
import 'package:itasks/core/providers/auth_provider.dart';

class StoryPointsEstimationCard extends StatefulWidget {
  const StoryPointsEstimationCard({super.key});

  @override
  State<StoryPointsEstimationCard> createState() => _StoryPointsEstimationCardState();
}

class _StoryPointsEstimationCardState extends State<StoryPointsEstimationCard> {
  @override
  void initState() {
    super.initState();
    _loadEstimation();
  }

  Future<void> _loadEstimation() async {
    final reportProvider = context.read<ReportProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Calculate for current developer (or all if manager)
    final developerId = authProvider.developerProfile?.id ?? 0;
    
    await reportProvider.calculateStoryPointsAverage();
    if (developerId > 0) {
      await reportProvider.calculateEstimatedTimeForTodo(developerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estimativa de Tempo (StoryPoints)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              'Média Histórica:',
              reportProvider.getAverageText(),
              Icons.history,
            ),
            const SizedBox(height: 8),
            
            _buildInfoRow(
              'Tempo Previsto (ToDo):',
              reportProvider.getEstimationText(),
              Icons.timer,
              isHighlight: true,
            ),
            
            const SizedBox(height: 12),
            
            TextButton.icon(
              onPressed: _loadEstimation,
              icon: const Icon(Icons.refresh),
              label: const Text('Recalcular'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
