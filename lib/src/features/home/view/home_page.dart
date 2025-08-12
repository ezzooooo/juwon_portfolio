import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'package:go_router/go_router.dart';
import '../../resume/data/resume_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: AppContainer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            _HeroSection(),
            const SizedBox(height: 32),
            Section(title: '핵심 이력', child: _FeaturedResumeSection()),
            const SizedBox(height: 32),
            Section(title: '주요 프로젝트', child: _FeaturedProjectsSection()),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isSmall =
        ResponsiveLayout.isXs(context) || ResponsiveLayout.isSm(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Flex(
        direction: isSmall ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: isSmall ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주원, 니즈를 파악하고 행동하는 개발자',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          if (!isSmall)
            const SizedBox(width: 24)
          else
            const SizedBox(height: 24),
          Expanded(
            flex: isSmall ? 0 : 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(
                    onPressed: () => context.go('/resume'),
                    child: const Text('이력서 보기'),
                  ),
                  FilledButton(
                    onPressed: () => context.go('/projects'),
                    child: const Text('프로젝트 보기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _HighlightsSection는 더 이상 사용하지 않아 제거되었습니다.

class _FeaturedResumeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResumeModel>(
      future: _loadResume(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final resume = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(resume.experiences.length, (index) {
                  final e = resume.experiences[index];
                  final bool isLast = index == resume.experiences.length - 1;
                  final TextStyle? companyStyle = Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700);
                  final TextStyle? periodStyle = Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      );
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.company, style: companyStyle),
                        const SizedBox(height: 2),
                        Text(e.period, style: periodStyle),
                        const SizedBox(height: 6),
                        Text(
                          e.summary,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (!isLast) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/resume'),
                    child: const Text('이력서 전체 보기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<ResumeModel> _loadResume(BuildContext context) async {
    final raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/resume_ko.json');
    return ResumeModel.fromJson(json.decode(raw) as Map<String, dynamic>);
  }
}

class _FeaturedProjectsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_FeaturedProjectData>>(
      future: _loadProjects(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final all = snapshot.data!;
        // featured == true만 필터 후 featuredOrder(없으면 큰값) 순 정렬
        final items = all.where((e) => e.isFeatured).toList()
          ..sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));
        final double width = MediaQuery.sizeOf(context).width;
        int columns = 1;
        if (width >= 1440) {
          columns = 3;
        } else if (width >= 1024) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        }
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 600, // 프로젝트 목록 카드와 동일 높이
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _ProjectCardLike(data: items[index]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/projects'),
                child: const Text('프로젝트 전체 보기'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<_FeaturedProjectData>> _loadProjects(BuildContext context) async {
    final String raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/projects.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    final List<_FeaturedProjectData> all = [
      for (int i = 0; i < jsonList.length; i++)
        () {
          final m = jsonList[i] as Map<String, dynamic>;
          final Map<String, dynamic> links =
              (m['links'] as Map<String, dynamic>?) ?? const {};
          final Map<String, String> techParticipants =
              ((m['techParticipants'] as Map<String, dynamic>?) ?? const {})
                  .map((k, v) => MapEntry(k, v.toString()));
          return _FeaturedProjectData(
            index: i,
            title: m['title'] as String? ?? '',
            description: m['description'] as String? ?? '',
            tech: (m['techStack'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList(),
            repoUrl: links['repo'] as String? ?? '',
            demoUrl: links['demo'] as String? ?? '',
            period: m['period'] as String? ?? '',
            isOpen: m['open'] as bool? ?? false,
            techParticipants: techParticipants,
            thumbnail: m['thumbnail'] as String? ?? '',
            isFeatured: m['featured'] as bool? ?? false,
            featuredOrder: (m['featuredOrder'] is num)
                ? (m['featuredOrder'] as num).toInt()
                : 1000000,
          );
        }(),
    ];
    return all;
  }
}

class _FeaturedProjectData {
  const _FeaturedProjectData({
    required this.index,
    required this.title,
    required this.description,
    required this.tech,
    this.repoUrl = '',
    this.demoUrl = '',
    this.period = '',
    this.isOpen = false,
    this.techParticipants = const {},
    this.thumbnail = '',
    this.isFeatured = false,
    this.featuredOrder = 1000000,
  });
  final int index;
  final String title;
  final String description;
  final List<String> tech;
  final String repoUrl;
  final String demoUrl;
  final String period;
  final bool isOpen;
  final Map<String, String> techParticipants;
  final String thumbnail;
  final bool isFeatured;
  final int featuredOrder;
}

class _ProjectCardLike extends StatelessWidget {
  const _ProjectCardLike({required this.data});
  final _FeaturedProjectData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/projects/${data.index}'),
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
                    const Spacer(),
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
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Image.asset(
        thumbnail,
        height: height,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        ),
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

// 위젯 미리보기 섹션은 사용하지 않음
