class VaccineEntry {
  int? id;
  int petId;
  String vaccineName;
  String lastDate;
  String nextDate;
  String? notes;

  VaccineEntry({this.id, required this.petId, required this.vaccineName, required this.lastDate, required this.nextDate, this.notes});

  Map<String, dynamic> toMap() => {
    'id': id, 'petId': petId, 'vaccineName': vaccineName,
    'lastDate': lastDate, 'nextDate': nextDate, 'notes': notes,
  };

  factory VaccineEntry.fromMap(Map<String, dynamic> map) => VaccineEntry(
    id: map['id'], petId: map['petId'], vaccineName: map['vaccineName'],
    lastDate: map['lastDate'], nextDate: map['nextDate'], notes: map['notes'],
  );
}