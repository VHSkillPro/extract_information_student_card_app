class StudentInformation {
  final String fullName;
  final String studentId;
  final String dateOfBirth;
  final String className;
  final String year;

  StudentInformation({
    required this.fullName,
    required this.studentId,
    required this.dateOfBirth,
    required this.className,
    required this.year,
  });

  @override
  String toString() {
    return 'StudentInformation(fullName: $fullName, studentId: $studentId, dateOfBirth: $dateOfBirth, className: $className, year: $year)';
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'studentId': studentId,
      'dateOfBirth': dateOfBirth,
      'className': className,
      'year': year,
    };
  }

  factory StudentInformation.fromJson(Map<String, dynamic> json) {
    return StudentInformation(
      fullName: json['fullName'],
      studentId: json['studentId'],
      dateOfBirth: json['dateOfBirth'],
      className: json['className'],
      year: json['year'],
    );
  }
}
