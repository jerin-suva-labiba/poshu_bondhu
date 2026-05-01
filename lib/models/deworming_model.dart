class DewormingEntry {
  int? id;
  int petId;
  String medicineName;
  String lastDate;
  String nextDate;
  String? notes;

  DewormingEntry({this.id, required this.petId, required this.medicineName, required this.lastDate, required this.nextDate, this.notes});

  Map<String, dynamic> toMap() => {
    'id': id, 'petId': petId, 'medicineName': medicineName,
    'lastDate': lastDate, 'nextDate': nextDate, 'notes': notes,
  };

  factory DewormingEntry.fromMap(Map<String, dynamic> map) => DewormingEntry(
    id: map['id'], petId: map['petId'], medicineName: map['medicineName'],
    lastDate: map['lastDate'], nextDate: map['nextDate'], notes: map['notes'],
  );
}