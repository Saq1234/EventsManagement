class Event {
  final String title;
  final DateTime startAt;
  final String status;

  Event({required this.title, required this.startAt, required this.status});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      startAt: DateTime.parse(json['startAt']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startAt': startAt.toIso8601String(),
      'status': status,
    };
  }
}
