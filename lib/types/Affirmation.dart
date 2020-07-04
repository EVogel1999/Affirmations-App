class Affirmation {
  final String affirmation;

  Affirmation({this.affirmation});

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(affirmation: json['affirmation']);
  }
}