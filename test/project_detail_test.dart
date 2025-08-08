import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:juwon_portfolio/src/features/projects/view/project_detail_page.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final String projectsJson =
      '[{"title":"Test Project","description":"Test Description","techStack":["Flutter","Dart"],"links":{"repo":"https://github.com/example","demo":"https://example.com"}}]';

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('assets/data/projects.json')) {
      final bytes = Uint8List.fromList(utf8.encode(projectsJson));
      return bytes.buffer.asByteData();
    }
    final empty = Uint8List(0);
    return empty.buffer.asByteData();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('assets/data/projects.json')) {
      return projectsJson;
    }
    return '';
  }
}

void main() {
  testWidgets('프로젝트 상세가 로드되어 제목과 설명을 표시한다', (tester) async {
    final fakeBundle = _FakeAssetBundle();

    await tester.pumpWidget(
      ProviderScope(
        child: DefaultAssetBundle(
          bundle: fakeBundle,
          child: const MaterialApp(home: ProjectDetailPage(id: 0)),
        ),
      ),
    );

    // 처음엔 로딩 스피너
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // FutureBuilder 완료
    await tester.pumpAndSettle();

    expect(find.text('Test Project'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('Repo'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
  });
}
