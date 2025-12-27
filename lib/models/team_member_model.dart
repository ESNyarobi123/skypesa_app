class TeamMember {
  final int id;
  final String name;
  final String email;
  final String planName;
  final double commissionEarned;
  final DateTime joinedAt;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.planName,
    required this.commissionEarned,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      planName: json['plan_name'] ?? 'Free',
      commissionEarned: double.parse(json['commission_earned'].toString()),
      joinedAt: DateTime.parse(json['created_at']),
    );
  }
}
