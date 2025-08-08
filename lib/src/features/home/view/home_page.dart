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
            const SizedBox(height: 32),
            Section(title: '위젯 모음 미리보기', child: _WidgetPreviewSection()),
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
        final List<String> topAchievements = <String>[];
        for (final exp in resume.experiences) {
          for (final a in exp.achievements) {
            topAchievements.add('[${exp.company}] $a');
            if (topAchievements.length >= 6) break;
          }
          if (topAchievements.length >= 6) break;
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topAchievements.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topAchievements
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(a)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
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
        final items = snapshot.data!.take(3).toList();
        final double width = MediaQuery.sizeOf(context).width;
        int columns = 1;
        if (width >= 1440) {
          columns = 3;
        } else if (width >= 1024) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _FeaturedProjectCard(data: items[index]),
        );
      },
    );
  }

  Future<List<_FeaturedProjectData>> _loadProjects(BuildContext context) async {
    final String raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/projects.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    final List<_FeaturedProjectData> all = [];
    for (int i = 0; i < jsonList.length; i++) {
      final m = jsonList[i] as Map<String, dynamic>;
      all.add(
        _FeaturedProjectData(
          index: i,
          title: m['title'] as String? ?? '',
          description: m['description'] as String? ?? '',
        ),
      );
    }
    return all;
  }
}

class _FeaturedProjectData {
  const _FeaturedProjectData({
    required this.index,
    required this.title,
    required this.description,
  });
  final int index;
  final String title;
  final String description;
}

class _FeaturedProjectCard extends StatelessWidget {
  const _FeaturedProjectCard({required this.data});
  final _FeaturedProjectData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/projects/${data.index}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(child: Text(data.description)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = const [
      _HighlightCardData(title: 'Theme Switch', description: '라이트/다크 테마 전환'),
      _HighlightCardData(
        title: 'Responsive Layout',
        description: '브레이크포인트 기반 레이아웃',
      ),
      _HighlightCardData(
        title: 'Reusable Components',
        description: '카드/버튼/섹션 헤더',
      ),
    ];

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 3,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _HighlightCard(data: items[i]),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/gallery'),
            child: const Text('위젯 모음 더 보기'),
          ),
        ),
      ],
    );
  }
}

class _HighlightCardData {
  const _HighlightCardData({required this.title, required this.description});
  final String title;
  final String description;
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.data});
  final _HighlightCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(data.description),
          ],
        ),
      ),
    );
  }
}
