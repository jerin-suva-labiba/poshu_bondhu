class Note {
  int? id;
  int petId;
  String title;
  String content;
  String date;

  Note({this.id, required this.petId, required this.title, required this.content, required this.date});

  Map<String, dynamic> toMap() => {'id': id, 'petId': petId, 'title': title, 'content': content, 'date': date};

  factory Note.fromMap(Map<String, dynamic> map) =>
      Note(id: map['id'], petId: map['petId'], title: map['title'], content: map['content'], date: map['date']);
}