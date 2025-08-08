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
        title: const SizedBox.shrink(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go('/resume'),
                  child: const Text('이력서'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go('/projects'),
                  child: const Text('프로젝트'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go('/gallery'),
                  child: const Text('위젯 모음'),
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
