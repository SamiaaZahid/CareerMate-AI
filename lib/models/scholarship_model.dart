class Scholarship {
  final String id;
  final String title;
  final String provider;
  final String amount;
  final String deadline;
  final String shortDescription;
  final String fullDescription;
  final String eligibility;
  final String icon;

  const Scholarship({
    required this.id,
    required this.title,
    required this.provider,
    required this.amount,
    required this.deadline,
    required this.shortDescription,
    required this.fullDescription,
    required this.eligibility,
    required this.icon,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      fullDescription: json['fullDescription'] as String? ?? '',
      eligibility: json['eligibility'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'amount': amount,
      'deadline': deadline,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'eligibility': eligibility,
      'icon': icon,
    };
  }
}
