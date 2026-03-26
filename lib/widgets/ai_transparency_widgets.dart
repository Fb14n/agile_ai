import 'package:flutter/material.dart';

class AiProcessingIndicator extends StatelessWidget {
  final String process;
  final bool isProcessing;

  const AiProcessingIndicator({
    super.key,
    required this.process,
    this.isProcessing = true,
  });

  static const Map<String, AiProcessInfo> processes = {
    'sentiment': AiProcessInfo(
      title: 'Analysiere Stimmung...',
      description: 'Die KI bewertet die emotionale Tonalität deiner Nachricht',
      icon: Icons.sentiment_satisfied_alt,
      color: Colors.orange,
    ),
    'sprint_goal': AiProcessInfo(
      title: 'Generiere Sprint-Ziel...',
      description: 'Die KI formuliert ein fokussiertes Ziel aus deinen Backlog Items',
      icon: Icons.flag,
      color: Colors.green,
    ),
    'retrospective': AiProcessInfo(
      title: 'Analysiere Retrospektive...',
      description: 'Die KI identifiziert Muster und erstellt Handlungsempfehlungen',
      icon: Icons.insights,
      color: Colors.blue,
    ),
    'ceremony': AiProcessInfo(
      title: 'Moderiere Zeremonie...',
      description: 'Die KI bereitet strukturierte Fragen vor',
      icon: Icons.groups,
      color: Colors.purple,
    ),
    'chat': AiProcessInfo(
      title: 'Denke nach...',
      description: 'Die KI verarbeitet deine Anfrage',
      icon: Icons.chat_bubble_outline,
      color: Colors.grey,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final info = processes[process] ?? processes['chat']!;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: info.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(info.icon, color: info.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: info.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isProcessing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(info.color),
              ),
            ),
        ],
      ),
    );
  }
}

class AiProcessInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const AiProcessInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AiTransparencyFooter extends StatelessWidget {
  final String aiModel;
  final DateTime processedAt;
  final Duration? processingTime;

  const AiTransparencyFooter({
    super.key,
    this.aiModel = 'Gemini',
    required this.processedAt,
    this.processingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            'Von $aiModel verarbeitet',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          if (processingTime != null) ...[
            const SizedBox(width: 8),
            Text(
              '• ${processingTime!.inSeconds}s',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TrustBuildingTips extends StatelessWidget {
  const TrustBuildingTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Über deine KI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip(
            context,
            icon: Icons.data_usage,
            text: 'Alle Daten bleiben lokal auf deinem Gerät gespeichert',
          ),
          _buildTip(
            context,
            icon: Icons.auto_awesome,
            text: 'Die KI lernt NICHT aus deinen Daten - jede Anfrage ist unabhängig',
          ),
          _buildTip(
            context,
            icon: Icons.visibility_off,
            text: 'Deine Konversationen sind privat und werden nicht mit anderen geteilt',
          ),
          _buildTip(
            context,
            icon: Icons.support_agent,
            text: 'Die KI ist ein Werkzeug - finale Entscheidungen triffst immer du',
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatTheAiFoundCard extends StatelessWidget {
  final List<String> findings;
  final String? confidence;

  const WhatTheAiFoundCard({
    super.key,
    required this.findings,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, color: Colors.green[700], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Was die KI erkannt hat:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (confidence != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      confidence!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...findings.map((finding) => Padding(
                  padding: const EdgeInsets.only(left: 44, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          finding,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
