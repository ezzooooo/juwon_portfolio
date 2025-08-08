import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// removed unused rootBundle import
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/layout.dart';

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
      child: AppContainer(
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
            final String title = (data['title'] as String?) ?? '';
            final String description = (data['description'] as String?) ?? '';
            final List<String> tech =
                ((data['techStack'] as List<dynamic>?) ?? const [])
                    .map((e) => e.toString())
                    .toList();
            final Map<String, dynamic> links =
                (data['links'] as Map<String, dynamic>?) ?? const {};
            final String repo = (links['repo'] as String?) ?? '';
            final String demo = (links['demo'] as String?) ?? '';
            final String period = (data['period'] as String?) ?? '';
            final bool isOpen = (data['open'] as bool?) ?? false;
            final Map<String, String> techParticipants =
                ((data['techParticipants'] as Map<String, dynamic>?) ??
                        const {})
                    .map((k, v) => MapEntry(k, v.toString()));
            final String thumbnail = (data['thumbnail'] as String?) ?? '';

            final String overview = (data['overview'] as String?) ?? '';
            final List<String> achievements =
                ((data['achievements'] as List<dynamic>?) ?? const [])
                    .map((e) => e.toString())
                    .toList();
            final List<String> improvements =
                ((data['improvements'] as List<dynamic>?) ?? const [])
                    .map((e) => e.toString())
                    .toList();
            final List<String> screens =
                ((data['screens'] as List<dynamic>?) ?? const [])
                    .map((e) => e.toString())
                    .toList();
            if (screens.isEmpty) {
              // 기본 샘플 이미지 3장
              screens.addAll([
                'assets/images/7meerkat.png',
                'assets/images/my_face.jpg',
                'assets/images/7meerkat.png',
              ]);
            }

            final theme = Theme.of(context);

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                // Header thumbnail
                _HeaderThumbnail(thumbnail: thumbnail, title: title),
                const SizedBox(height: 16),

                // Title row with open icon
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: theme.textTheme.headlineMedium),
                    ),
                    Icon(isOpen ? Icons.public : Icons.lock, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                if (period.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 6),
                      Text(period, style: theme.textTheme.bodySmall),
                    ],
                  ),
                if (period.isNotEmpty) const SizedBox(height: 8),
                if (description.isNotEmpty)
                  Text(description, style: theme.textTheme.bodyLarge),

                if (tech.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tech.map((t) => Chip(label: Text(t))).toList(),
                  ),
                ],

                if (techParticipants.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _TechParticipantsWrap(
                    entries: techParticipants.entries.toList(),
                  ),
                ],

                if (repo.isNotEmpty || demo.isNotEmpty) ...[
                  const SizedBox(height: 12),
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

                const SizedBox(height: 24),

                // Structured sections
                _DetailSection(
                  title: '프로젝트 개요',
                  child: Text(
                    overview.isNotEmpty ? overview : '작성 예정',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: '주요 화면',
                  child: _ScreensGallery(images: screens.take(10).toList()),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: '주요 성과',
                  child: (achievements.isNotEmpty)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: achievements
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(a)),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const Text('작성 예정'),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: '기술 스택',
                  child: (tech.isNotEmpty)
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tech
                              .map((t) => Chip(label: Text(t)))
                              .toList(),
                        )
                      : const Text('작성 예정'),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: '보완점',
                  child: (improvements.isNotEmpty)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: improvements
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(a)),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const Text('작성 예정'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderThumbnail extends StatelessWidget {
  const _HeaderThumbnail({required this.thumbnail, required this.title});
  final String thumbnail;
  final String title;

  @override
  Widget build(BuildContext context) {
    const double height = 240;
    if (thumbnail.isEmpty) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (thumbnail.startsWith('http')) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Image.network(
              thumbnail,
              fit: BoxFit.contain,
              height: height,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Center(
          child: Image.asset(thumbnail, fit: BoxFit.contain, height: height),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            child,
          ],
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

class _ScreensGallery extends StatefulWidget {
  const _ScreensGallery({required this.images});
  final List<String> images;

  @override
  State<_ScreensGallery> createState() => _ScreensGalleryState();
}

class _ScreensGalleryState extends State<_ScreensGallery> {
  PageController? _pageController;
  double _viewportFraction = 1.0;
  int _current = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _ensureController(double fraction) {
    if ((_pageController == null) ||
        (_viewportFraction - fraction).abs() > 1e-6) {
      final initialPage = _current;
      _pageController?.dispose();
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: initialPage,
      );
      _viewportFraction = fraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double desiredItemWidth = 300;
        final int visibleCount = width.isFinite && width > 0
            ? (width / desiredItemWidth).floor().clamp(1, 5)
            : 1;
        final double fraction = 1.0 / visibleCount;
        _ensureController(fraction);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.images.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (context, index) {
                      final path = widget.images[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _ScreenImage(path: path),
                      );
                    },
                  ),
                  if (_current > 0)
                    Positioned(
                      left: 0,
                      child: _NavArrow(
                        icon: Icons.chevron_left,
                        onTap: () {
                          final target = (_current - 1).clamp(
                            0,
                            widget.images.length - 1,
                          );
                          _pageController?.animateToPage(
                            target,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  if (_current < widget.images.length - 1 &&
                      widget.images.length > 3)
                    Positioned(
                      right: 0,
                      child: _NavArrow(
                        icon: Icons.chevron_right,
                        onTap: () {
                          final target = (_current + 1).clamp(
                            0,
                            widget.images.length - 1,
                          );
                          _pageController?.animateToPage(
                            target,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScreenImage extends StatelessWidget {
  const _ScreenImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  insetPadding: const EdgeInsets.all(64),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: _buildImage(path),
                  ),
                );
              },
            );
          },
          child: _buildImage(path),
        ),
      ),
    );
  }

  Widget _buildImage(String p) {
    if (p.startsWith('http')) {
      return Center(child: Image.network(p, fit: BoxFit.contain));
    }
    return Center(child: Image.asset(p, fit: BoxFit.contain));
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}
