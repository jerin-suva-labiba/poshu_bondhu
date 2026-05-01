class Pet {
  int? id;
  String name;
  String petType;
  String birthday;
  String? imagePath;
  String? breed;
  String? gender;

  Pet({this.id, required this.name, required this.petType, required this.birthday, this.imagePath, this.breed, this.gender});

  String get age {
    final birth = DateTime.parse(birthday);
    final now = DateTime.now();
    final years = now.year - birth.year;
    final months = now.month - birth.month;
    if (years == 0) {
      int m = months < 0 ? months + 12 : months;
      return '$m months';
    }
    return '$years years';
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'petType': petType, 'birthday': birthday,
    'imagePath': imagePath, 'breed': breed, 'gender': gender,
  };

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
    id: map['id'], name: map['name'], petType: map['petType'], birthday: map['birthday'],
    imagePath: map['imagePath'], breed: map['breed'], gender: map['gender'],
  );
}