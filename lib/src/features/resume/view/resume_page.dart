import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// removed unused rootBundle import
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/responsive_layout.dart';
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
      child: AppContainer(
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) {
                        final bool isWide =
                            ResponsiveLayout.isMd(context) ||
                            ResponsiveLayout.isLg(context) ||
                            ResponsiveLayout.isXl(context);
                        final Widget profileImage = ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/my_face.jpg',
                            width: isWide ? 300 : 120,
                            height: isWide ? 400 : 160,
                            fit: BoxFit.cover,
                          ),
                        );

                        final Widget infoColumn = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resume.summary,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 40),
                            if (resume.contacts.email.isNotEmpty ||
                                resume.contacts.phone.isNotEmpty ||
                                resume.contacts.github.isNotEmpty)
                              _ContactsSection(contacts: resume.contacts),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              profileImage,
                              const SizedBox(width: 24),
                              Expanded(child: infoColumn),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: profileImage),
                            const SizedBox(height: 12),
                            infoColumn,
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 경력사항
                const Section(title: '경력사항', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                _ExperienceSection(experiences: resume.experiences),

                const SizedBox(height: 24),

                // 사이드 프로젝트
                const Section(title: '사이드 프로젝트', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                _SideProjectsSection(projects: resume.sideProjects),

                const SizedBox(height: 24),

                // 기술스택
                const Section(title: '기술스택', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _SkillsSection(skills: resume.skills),
                  ),
                ),

                const SizedBox(height: 24),

                // 자격증 및 수상
                const Section(title: '자격증 및 수상', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                _CertificatesSection(certificates: resume.certificates),

                const SizedBox(height: 24),

                // 학력
                const Section(title: '학력', child: SizedBox.shrink()),
                const SizedBox(height: 8),
                _EducationSection(education: resume.education),
              ],
            );
          },
        ),
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
        if (skills.backend.isNotEmpty) ...chips('Backend', skills.backend),
        if (skills.devops.isNotEmpty) ...chips('Infra', skills.devops),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: _CompanyTitle(
                                    company: e.company,
                                    link: e.link,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            e.role,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          const Text('·'),
                          const SizedBox(width: 8),
                          Text(
                            e.period,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.summary,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (e.achievements.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: e.achievements
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CompanyTitle extends StatelessWidget {
  const _CompanyTitle({required this.company, this.link});
  final String company;
  final String? link;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleLarge;
    if (link == null || link!.isEmpty) {
      return Text(company, style: style);
    }
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(link!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            company,
            style: style?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.open_in_new,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection({required this.certificates});
  final List<Certificate> certificates;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: certificates
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text('${c.issuer} · ${c.date}'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.education});
  final List<Education> education;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: education
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  title: Text('${e.school} · ${e.degree}'),
                  subtitle: Text(e.period),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SideProjectsSection extends StatelessWidget {
  const _SideProjectsSection({required this.projects});
  final List<SideProject> projects;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: projects
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (p.link != null && p.link!.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                final uri = Uri.parse(p.link!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '사이트',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            p.role,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          const Text('·'),
                          const SizedBox(width: 8),
                          Text(
                            p.period,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (p.achievements.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: p.achievements
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  const _ContactsSection({required this.contacts});
  final Contacts contacts;

  @override
  Widget build(BuildContext context) {
    Future<void> open(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    final List<Widget> items = [];
    if (contacts.email.isNotEmpty) {
      items.add(
        _ContactRow(
          label: 'Email',
          value: contacts.email,
          onTap: () => open('mailto:${contacts.email}'),
        ),
      );
    }
    if (contacts.phone.isNotEmpty) {
      items.add(
        _ContactRow(
          label: 'Phone',
          value: contacts.phone,
          onTap: () => open('tel:${contacts.phone}'),
        ),
      );
    }
    if (contacts.github.isNotEmpty) {
      items.add(
        _ContactRow(
          label: 'GitHub',
          value: contacts.github,
          onTap: () => open(contacts.github),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge;
    final TextStyle? valueStyle = Theme.of(context).textTheme.bodyLarge;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label:', style: labelStyle),
            const SizedBox(width: 8),
            Text(value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
