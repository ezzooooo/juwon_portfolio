class ResumeModel {
  ResumeModel({
    required this.name,
    required this.title,
    required this.summary,
    required this.contacts,
    required this.skills,
    required this.experiences,
    required this.education,
    required this.sideProjects,
    required this.certificates,
  });

  final String name;
  final String title;
  final String summary;
  final Contacts contacts;
  final Skills skills;
  final List<Experience> experiences;
  final List<Education> education;
  final List<SideProject> sideProjects;
  final List<Certificate> certificates;

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      contacts: Contacts.fromJson(
        json['contacts'] as Map<String, dynamic>? ?? const {},
      ),
      skills: Skills.fromJson(
        json['skills'] as Map<String, dynamic>? ?? const {},
      ),
      experiences: (json['experiences'] as List<dynamic>? ?? const [])
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>? ?? const [])
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      sideProjects: (json['sideProjects'] as List<dynamic>? ?? const [])
          .map((e) => SideProject.fromJson(e as Map<String, dynamic>))
          .toList(),
      certificates: (json['certificates'] as List<dynamic>? ?? const [])
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Contacts {
  Contacts({
    this.email = '',
    this.phone = '',
    this.github = '',
    this.linkedin = '',
    this.blog = '',
  });
  final String email;
  final String phone;
  final String github;
  final String linkedin;
  final String blog;

  factory Contacts.fromJson(Map<String, dynamic> json) => Contacts(
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    github: json['github'] as String? ?? '',
    linkedin: json['linkedin'] as String? ?? '',
    blog: json['blog'] as String? ?? '',
  );
}

class Skills {
  Skills({
    this.frontend = const [],
    this.mobile = const [],
    this.backend = const [],
    this.devops = const [],
    this.tools = const [],
  });

  final List<String> frontend;
  final List<String> mobile;
  final List<String> backend;
  final List<String> devops;
  final List<String> tools;

  factory Skills.fromJson(Map<String, dynamic> json) => Skills(
    frontend: (json['frontend'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    mobile: (json['mobile'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    backend: (json['backend'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    devops:
        ((json['devops'] as List<dynamic>?) ??
                (json['infra'] as List<dynamic>?) ??
                const [])
            .map((e) => e.toString())
            .toList(),
    tools: (json['tools'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}

class Experience {
  Experience({
    required this.company,
    required this.role,
    required this.period,
    required this.summary,
    required this.achievements,
    this.link,
  });

  final String company;
  final String role;
  final String period;
  final String summary;
  final List<String> achievements;
  final String? link;

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    company: json['company'] as String? ?? '',
    role: json['role'] as String? ?? '',
    period: json['period'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    achievements: (json['achievements'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    link: json['link'] as String?,
  );
}

class Education {
  Education({required this.school, required this.degree, required this.period});
  final String school;
  final String degree;
  final String period;

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    school: json['school'] as String? ?? '',
    degree: json['degree'] as String? ?? '',
    period: json['period'] as String? ?? '',
  );
}

class Certificate {
  Certificate({required this.name, required this.issuer, required this.date});
  final String name;
  final String issuer;
  final String date;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    name: json['name'] as String? ?? '',
    issuer: json['issuer'] as String? ?? '',
    date: json['date'] as String? ?? '',
  );
}

class SideProject {
  SideProject({
    required this.title,
    required this.description,
    required this.role,
    required this.period,
    required this.achievements,
    this.link,
  });

  final String title;
  final String description;
  final String role;
  final String period;
  final List<String> achievements;
  final String? link;

  factory SideProject.fromJson(Map<String, dynamic> json) => SideProject(
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    role: json['role'] as String? ?? '',
    period: json['period'] as String? ?? '',
    achievements: (json['achievements'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    link: json['link'] as String?,
  );
}
