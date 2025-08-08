import 'dart:convert';
import 'package:flutter/material.dart';
// removed unused rootBundle import
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/layout.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<List<_ProjectCardData>> _loadProjects(BuildContext context) async {
    final String raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/projects.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    return jsonList
        .map((e) => e as Map<String, dynamic>)
        .map(
          (m) => _ProjectCardData(
            title: m['title'] as String? ?? '',
            description: m['description'] as String? ?? '',
            tech: (m['techStack'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList(),
            repoUrl:
                (m['links'] as Map<String, dynamic>?)?['repo'] as String? ?? '',
            demoUrl:
                (m['links'] as Map<String, dynamic>?)?['demo'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    int columns = 1;
    if (width >= 1440) {
      columns = 3;
    } else if (width >= 1024) {
      columns = 3;
    } else if (width >= 600) {
      columns = 2;
    }

    return AppScaffold(
      child: AppContainer(
        child: FutureBuilder<List<_ProjectCardData>>(
          future: _loadProjects(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('프로젝트 로딩 실패: ${snapshot.error}'));
            }
            final projects = snapshot.data ?? const <_ProjectCardData>[];
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                const Section(title: '프로젝트', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 4 / 3,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) =>
                      _ProjectCard(index: index, data: projects[index]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectCardData {
  const _ProjectCardData({
    required this.title,
    required this.description,
    required this.tech,
    this.repoUrl = '',
    this.demoUrl = '',
  });
  final String title;
  final String description;
  final List<String> tech;
  final String repoUrl;
  final String demoUrl;
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.data, required this.index});
  final _ProjectCardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoRouter.of(context).go('/projects/$index'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(child: Text(data.description)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.tech.map((t) => Chip(label: Text(t))).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (data.repoUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(data.repoUrl);
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
                  if (data.demoUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(data.demoUrl);
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
          ),
        ),
      ),
    );
  }
}
