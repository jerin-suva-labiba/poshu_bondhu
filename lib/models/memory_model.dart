class Memory {
  int? id;
  int petId;
  String imagePath;
  String timestamp;

  Memory({this.id, required this.petId, required this.imagePath, required this.timestamp});

  Map<String, dynamic> toMap() => {
    'id': id, 'petId': petId, 'imagePath': imagePath, 'timestamp': timestamp,
  };

  factory Memory.fromMap(Map<String, dynamic> map) => Memory(
    id: map['id'], petId: map['petId'], imagePath: map['imagePath'], timestamp: map['timestamp'],
  );
}

