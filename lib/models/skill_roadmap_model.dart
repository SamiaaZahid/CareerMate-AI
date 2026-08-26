class SkillRoadmapStep {
  final int stepNumber;
  final String title;
  final String description;
  final String resource;

  SkillRoadmapStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.resource,
  });

  factory SkillRoadmapStep.fromJson(Map<String, dynamic> json) {
    return SkillRoadmapStep(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      resource: (json['resource'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'resource': resource,
    };
  }
}

class SkillRoadmapModel {
  final String id;
  final String role;
  final List<String> aliases;
  final String description;
  final List<SkillRoadmapStep> steps;

  SkillRoadmapModel({
    required this.id,
    required this.role,
    required this.aliases,
    required this.description,
    required this.steps,
  });

  factory SkillRoadmapModel.fromJson(Map<String, dynamic> json) {
    return SkillRoadmapModel(
      id: (json['id'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [],
      description: (json['description'] as String?) ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => SkillRoadmapStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
