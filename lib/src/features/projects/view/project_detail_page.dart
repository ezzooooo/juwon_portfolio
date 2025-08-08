import 'dart:convert';
import 'package:flutter/material.dart';
// removed unused rootBundle import
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/app_scaffold.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.id});
  final int id;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Future<Map<String, dynamic>?> _loadProject(BuildContext context) async {
    final raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/projects.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    if (widget.id < 0 || widget.id >= list.length) return null;
    return list[widget.id] as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProject(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('프로젝트를 찾을 수 없습니다.'));
          }
          final data = snapshot.data!;
          final title = (data['title'] as String?) ?? '';
          final description = (data['description'] as String?) ?? '';
          final tech = ((data['techStack'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString())
              .toList();
          final links = (data['links'] as Map<String, dynamic>?) ?? const {};
          final repo = (links['repo'] as String?) ?? '';
          final demo = (links['demo'] as String?) ?? '';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(description),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tech.map((t) => Chip(label: Text(t))).toList(),
              ),
              const SizedBox(height: 16),
              if (repo.isNotEmpty || demo.isNotEmpty)
                Row(
                  children: [
                    if (repo.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(repo);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.code),
                        label: const Text('Repo'),
                      ),
                    if (demo.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(demo);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Demo'),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
