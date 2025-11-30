class Flower {
  final String id;
  final String imageUrl;
  final String gender; // male, female
  final double readinessScore;

  Flower({
    required this.id,
    required this.imageUrl,
    required this.gender,
    required this.readinessScore,
    required String imageBase64,
  });

  get name => null;

  get species => null;
}
