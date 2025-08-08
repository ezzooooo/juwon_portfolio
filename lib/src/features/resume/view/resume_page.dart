import 'dart:convert';
import 'package:flutter/material.dart';
// removed unused rootBundle import
import '../../../core/widgets/app_scaffold.dart';
import '../data/resume_model.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  Future<ResumeModel> _loadResume(BuildContext context) async {
    final String raw = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/resume_ko.json');
    final Map<String, dynamic> jsonMap =
        json.decode(raw) as Map<String, dynamic>;
    return ResumeModel.fromJson(jsonMap);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: FutureBuilder<ResumeModel>(
        future: _loadResume(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('이력서 로딩 실패: ${snapshot.error}'));
          }
          final ResumeModel resume = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                resume.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                resume.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(resume.summary),
              const SizedBox(height: 24),
              Divider(),
              const SizedBox(height: 8),
              Text('기술 스택', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _SkillsSection(skills: resume.skills),
              const SizedBox(height: 24),
              Divider(),
              const SizedBox(height: 8),
              Text('경력', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _ExperienceSection(experiences: resume.experiences),
              const SizedBox(height: 24),
              Divider(),
              const SizedBox(height: 8),
              Text('학력/자격', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _EducationCertificatesSection(
                education: resume.education,
                certificates: resume.certificates,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});
  final Skills skills;
  @override
  Widget build(BuildContext context) {
    List<Widget> chips(String title, List<String> items) => [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((e) => Chip(label: Text(e))).toList(),
      ),
      const SizedBox(height: 16),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...chips('Frontend', skills.frontend),
        ...chips('Mobile', skills.mobile),
        if (skills.backend.isNotEmpty) ...chips('Backend', skills.backend),
        if (skills.devops.isNotEmpty) ...chips('DevOps', skills.devops),
        if (skills.tools.isNotEmpty) ...chips('Tools', skills.tools),
      ],
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({required this.experiences});
  final List<Experience> experiences;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experiences
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${e.company} · ${e.role}'),
                subtitle: Text('${e.period}\n${e.summary}'),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EducationCertificatesSection extends StatelessWidget {
  const _EducationCertificatesSection({
    required this.education,
    required this.certificates,
  });
  final List<Education> education;
  final List<Certificate> certificates;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...education.map(
          (e) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${e.school} · ${e.degree}'),
            subtitle: Text(e.period),
          ),
        ),
        ...certificates.map(
          (c) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(c.name),
            subtitle: Text('${c.issuer} · ${c.date}'),
          ),
        ),
      ],
    );
  }
}
