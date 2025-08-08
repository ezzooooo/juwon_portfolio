import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_mode_provider.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juwon Portfolio'),
        actions: [
          TextButton(onPressed: () => context.go('/'), child: const Text('홈')),
          TextButton(
            onPressed: () => context.go('/resume'),
            child: const Text('이력서'),
          ),
          TextButton(
            onPressed: () => context.go('/projects'),
            child: const Text('프로젝트'),
          ),
          TextButton(
            onPressed: () => context.go('/gallery'),
            child: const Text('위젯 모음'),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Juwon Portfolio')),
            ListTile(title: const Text('홈'), onTap: () => context.go('/')),
            ListTile(
              title: const Text('이력서'),
              onTap: () => context.go('/resume'),
            ),
            ListTile(
              title: const Text('프로젝트'),
              onTap: () => context.go('/projects'),
            ),
            ListTile(
              title: const Text('위젯 모음'),
              onTap: () => context.go('/gallery'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: child,
        ),
      ),
    );
  }
}
