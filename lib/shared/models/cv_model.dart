class PersonalInfo {
  String firstName;
  String lastName;
  String title;
  String email;
  String phone;
  String address;
  String city;
  String country;
  String summary;
  String? photoPath;
  String? linkedIn;
  String? website;

  PersonalInfo({
    this.firstName = '',
    this.lastName = '',
    this.title = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.summary = '',
    this.photoPath,
    this.linkedIn,
    this.website,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'title': title,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'country': country,
    'summary': summary,
    'photoPath': photoPath,
    'linkedIn': linkedIn,
    'website': website,
  };

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? title,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? summary,
    String? photoPath,
    String? linkedIn,
    String? website,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      summary: summary ?? this.summary,
      photoPath: photoPath ?? this.photoPath,
      linkedIn: linkedIn ?? this.linkedIn,
      website: website ?? this.website,
    );
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    title: json['title'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    country: json['country'] ?? '',
    summary: json['summary'] ?? '',
    photoPath: json['photoPath'],
    linkedIn: json['linkedIn'],
    website: json['website'],
  );
}

class WorkExperience {
  String id;
  String company;
  String position;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;
  String location;

  WorkExperience({
    required this.id,
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'position': position,
    'startDate': startDate,
    'endDate': endDate,
    'isCurrent': isCurrent,
    'description': description,
    'location': location,
  };

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
    id: json['id'] ?? '',
    company: json['company'] ?? '',
    position: json['position'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    isCurrent: json['isCurrent'] ?? false,
    description: json['description'] ?? '',
    location: json['location'] ?? '',
  );
}

class Education {
  String id;
  String institution;
  String degree;
  String field;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;
  String gpa;

  Education({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.field = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
    this.gpa = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution': institution,
    'degree': degree,
    'field': field,
    'startDate': startDate,
    'endDate': endDate,
    'isCurrent': isCurrent,
    'description': description,
    'gpa': gpa,
  };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    id: json['id'] ?? '',
    institution: json['institution'] ?? '',
    degree: json['degree'] ?? '',
    field: json['field'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    isCurrent: json['isCurrent'] ?? false,
    description: json['description'] ?? '',
    gpa: json['gpa'] ?? '',
  );
}

class Skill {
  String id;
  String name;
  int level; // 1-5

  Skill({required this.id, this.name = '', this.level = 3});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'level': level};

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    level: json['level'] ?? 3,
  );
}

class Language {
  String id;
  String name;
  String level; // Beginner, Intermediate, Advanced, Native

  Language({required this.id, this.name = '', this.level = 'Intermediate'});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'level': level};

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    level: json['level'] ?? 'Intermediate',
  );
}

class Certification {
  String id;
  String name;
  String issuer;
  String date;
  String url;

  Certification({
    required this.id,
    this.name = '',
    this.issuer = '',
    this.date = '',
    this.url = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'issuer': issuer,
    'date': date,
    'url': url,
  };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    issuer: json['issuer'] ?? '',
    date: json['date'] ?? '',
    url: json['url'] ?? '',
  );
}

class CVModel {
  String id;
  String title;
  String templateId;
  PersonalInfo personalInfo;
  List<WorkExperience> experiences;
  List<Education> education;
  List<Skill> skills;
  List<Language> languages;
  List<Certification> certifications;
  DateTime createdAt;
  DateTime updatedAt;

  CVModel({
    required this.id,
    this.title = 'Mon CV',
    this.templateId = 'modern',
    PersonalInfo? personalInfo,
    List<WorkExperience>? experiences,
    List<Education>? education,
    List<Skill>? skills,
    List<Language>? languages,
    List<Certification>? certifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : personalInfo = personalInfo ?? PersonalInfo(),
       experiences = experiences ?? [],
       education = education ?? [],
       skills = skills ?? [],
       languages = languages ?? [],
       certifications = certifications ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'templateId': templateId,
    'personalInfo': personalInfo.toJson(),
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'education': education.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'languages': languages.map((e) => e.toJson()).toList(),
    'certifications': certifications.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CVModel.fromJson(Map<String, dynamic> json) => CVModel(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Mon CV',
    templateId: json['templateId'] ?? 'modern',
    personalInfo:
        json['personalInfo'] != null
            ? PersonalInfo.fromJson(json['personalInfo'])
            : PersonalInfo(),
    experiences:
        (json['experiences'] as List?)
            ?.map((e) => WorkExperience.fromJson(e))
            .toList() ??
        [],
    education:
        (json['education'] as List?)
            ?.map((e) => Education.fromJson(e))
            .toList() ??
        [],
    skills:
        (json['skills'] as List?)?.map((e) => Skill.fromJson(e)).toList() ?? [],
    languages:
        (json['languages'] as List?)
            ?.map((e) => Language.fromJson(e))
            .toList() ??
        [],
    certifications:
        (json['certifications'] as List?)
            ?.map((e) => Certification.fromJson(e))
            .toList() ??
        [],
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
  );

  CVModel copyWith({
    String? id,
    String? title,
    String? templateId,
    PersonalInfo? personalInfo,
    List<WorkExperience>? experiences,
    List<Education>? education,
    List<Skill>? skills,
    List<Language>? languages,
    List<Certification>? certifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CVModel(
      id: id ?? this.id,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      personalInfo: personalInfo ?? this.personalInfo,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
