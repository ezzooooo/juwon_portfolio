import 'dart:convert';
import 'package:flutter/material.dart';
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
            period: m['period'] as String? ?? '',
            isOpen: m['open'] as bool? ?? false,
            techParticipants:
                ((m['techParticipants'] as Map<String, dynamic>?) ?? const {})
                    .map((key, value) => MapEntry(key, value.toString())),
            thumbnail: m['thumbnail'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    // 요청: 한 줄에 3개(모바일은 1개)
    final int columns = width >= 600 ? 3 : 1;

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
                    // 고정 높이로 그리드 셀의 세로 공간을 충분히 확보하여 오버플로우 방지
                    mainAxisExtent: 600,
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
    this.period = '',
    this.isOpen = false,
    this.techParticipants = const {},
    this.thumbnail = '',
  });
  final String title;
  final String description;
  final List<String> tech;
  final String repoUrl;
  final String demoUrl;
  final String period;
  final bool isOpen;
  final Map<String, String> techParticipants;
  final String thumbnail;
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.data, required this.index});
  final _ProjectCardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoRouter.of(context).go('/projects/$index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProjectThumbnail(thumbnail: data.thumbnail, title: data.title),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (data.period.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              data.period,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      data.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (data.tech.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.tech
                            .take(6)
                            .map((t) => Chip(label: Text(t)))
                            .toList(),
                      ),
                    Spacer(),
                    if (data.techParticipants.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _TechParticipantsWrap(
                        entries: data.techParticipants.entries
                            .map((e) => MapEntry(e.key, e.value))
                            .take(6)
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectThumbnail extends StatelessWidget {
  const _ProjectThumbnail({required this.thumbnail, required this.title});
  final String thumbnail;
  final String title;

  @override
  Widget build(BuildContext context) {
    const double height = 200;
    if (thumbnail.isEmpty) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.secondaryContainer],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image, size: 22, color: scheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (thumbnail.startsWith('http')) {
      return Image.network(
        thumbnail,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        ),
      );
    }
    return Image.asset(
      thumbnail,
      height: height,
      width: double.infinity,
      fit: BoxFit.fitHeight,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image, size: 40)),
      ),
    );
  }
}

class _TechParticipantsWrap extends StatelessWidget {
  const _TechParticipantsWrap({required this.entries});
  final List<MapEntry<String, String>> entries;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group, size: 14, color: scheme.onSecondaryContainer),
              const SizedBox(width: 6),
              Text(
                e.key,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                e.value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
