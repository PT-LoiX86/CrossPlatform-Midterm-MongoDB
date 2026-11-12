class Lecturer {
  const Lecturer({
    required this.id,
    required this.idgv,
    required this.fullname,
    required this.sumClass,
    this.image,
  });

  final String id;
  final String idgv;
  final String fullname;
  final int sumClass;
  final String? image;

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['_id']?.toString() ?? '',
      idgv: json['IDGV']?.toString() ?? '',
      fullname: json['Fullname']?.toString() ?? '',
      sumClass: (json['SumClass'] as num?)?.toInt() ?? 0,
      image: json['Image']?.toString(),
    );
  }
}
