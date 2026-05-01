class WeightEntry {
  int? id;
  int petId;
  double weight;
  String date;

  WeightEntry({
    this.id,
    required this.petId,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'petId': petId,
    'weight': weight,
    'date': date,
  };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
    id: map['id'],
    petId: map['petId'],
    weight: map['weight'],
    date: map['date'],
  );
}