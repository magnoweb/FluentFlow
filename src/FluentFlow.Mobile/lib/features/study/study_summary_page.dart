import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudySummaryPage extends StatelessWidget {
  final String sessionId;
  final int reviewed;
  final double average;

  const StudySummaryPage({
    super.key,
    required this.sessionId,
    required this.reviewed,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    final color = average >= 4.0
        ? Colors.green
        : average >= 2.5
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessão concluída'),
        backgroundColor: const Color(0xFF594AE2),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                'Sessão concluída!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ResultCard(
                    label: 'Cards revistos',
                    value: '$reviewed',
                    color: const Color(0xFF594AE2),
                  ),
                  const SizedBox(width: 16),
                  _ResultCard(
                    label: 'Score médio',
                    value: '${average.toStringAsFixed(1)}/5',
                    color: color,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Voltar ao início'),
                  onPressed: () => context.go('/'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/decks'),
                child: const Text('Ver os meus decks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
