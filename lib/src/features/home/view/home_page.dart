import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _HeroSection(),
          const SizedBox(height: 24),
          _HighlightsSection(),
        ],
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
                  '주원 – Flutter/Dart 엔지니어',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '웹·모바일 전반의 UI/상태/아키텍처를 설계하고, 퍼포먼스와 접근성을 균형 있게 추구합니다.',
                  style: Theme.of(context).textTheme.bodyLarge,
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

class _HighlightsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    int columns = 1;
    if (width >= 1440) {
      columns = 4;
    } else if (width >= 1024) {
      columns = 3;
    } else if (width >= 600) {
      columns = 2;
    }

    final List<_HighlightCardData> items = const [
      _HighlightCardData(
        title: 'Flutter Web 최적화',
        description: '라우트 레이지, 이미지 최적화, 빌드 타임 단축',
      ),
      _HighlightCardData(title: '클린 아키텍처', description: '기능 단위 구조 및 테스트'),
      _HighlightCardData(title: '반응형 디자인', description: '브레이크포인트 기반의 적응형 UI'),
      _HighlightCardData(title: '접근성/SEO', description: '키보드 내비/메타/JSON-LD 적용'),
    ];

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
      itemBuilder: (context, index) => _HighlightCard(data: items[index]),
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
