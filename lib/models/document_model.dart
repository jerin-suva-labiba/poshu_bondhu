class DocumentEntry {
  int? id;
  int petId;
  String fileName;
  String filePath;
  String? notes;
  String date;

  DocumentEntry({this.id, required this.petId, required this.fileName, required this.filePath, this.notes, required this.date});

  Map<String, dynamic> toMap() => {
    'id': id, 'petId': petId, 'fileName': fileName,
    'filePath': filePath, 'notes': notes, 'date': date,
  };

  factory DocumentEntry.fromMap(Map<String, dynamic> map) => DocumentEntry(
    id: map['id'], petId: map['petId'], fileName: map['fileName'],
    filePath: map['filePath'], notes: map['notes'], date: map['date'],
  );
}