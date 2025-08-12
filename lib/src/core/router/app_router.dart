import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/view/home_page.dart';
import '../../features/projects/view/projects_page.dart';
import '../../features/resume/view/resume_page.dart';
import '../../features/projects/view/project_detail_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      ),
      GoRoute(
        path: '/resume',
        name: 'resume',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ResumePage()),
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ProjectsPage()),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'projectDetail',
        pageBuilder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MaterialPage(child: ProjectDetailPage(id: id));
        },
      ),
      // gallery route removed
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
      ),
    ),
  );
});
