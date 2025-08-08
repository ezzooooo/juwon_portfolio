import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_mode_provider.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.toString();
    bool isActive(String path) {
      if (path == '/') return location == '/';
      return location == path || location.startsWith(path);
    }

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavItem(
                  label: '홈',
                  active: isActive('/'),
                  onTap: () => context.go('/'),
                ),
                const SizedBox(width: 8),
                _NavItem(
                  label: '이력서',
                  active: isActive('/resume'),
                  onTap: () => context.go('/resume'),
                ),
                const SizedBox(width: 8),
                _NavItem(
                  label: '프로젝트',
                  active: isActive('/projects'),
                  onTap: () => context.go('/projects'),
                ),
                const SizedBox(width: 8),
                _NavItem(
                  label: '위젯 모음',
                  active: isActive('/gallery'),
                  onTap: () => context.go('/gallery'),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '테마 전환',
            onPressed: () {
              final current = ref.read(themeModeProvider);
              final next = current == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeModeProvider.notifier).state = next;
            },
            icon: const Icon(Icons.brightness_6),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: child,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.titleSmall;
    final TextStyle? labelStyle = base?.copyWith(
      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
    );
    final Color indicatorColor = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onTap,
          child: Text(label, style: labelStyle),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 2,
          width: active ? 24 : 0,
          decoration: BoxDecoration(
            color: active ? indicatorColor : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }
}
