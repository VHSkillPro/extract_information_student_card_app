class Bbox {
  final int xMin;
  final int yMin;
  final int xMax;
  final int yMax;
  late String label;

  Bbox({
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
    this.label = "",
  });

  @override
  String toString() {
    return 'Bbox(xMin: $xMin, yMin: $yMin, xMax: $xMax, yMax: $yMax, label: $label)';
  }

  Map<String, dynamic> toJson() {
    return {
      'xMin': xMin,
      'yMin': yMin,
      'xMax': xMax,
      'yMax': yMax,
      'label': label,
    };
  }

  factory Bbox.fromJson(Map<String, dynamic> json) {
    return Bbox(
      xMin: json['xMin'],
      yMin: json['yMin'],
      xMax: json['xMax'],
      yMax: json['yMax'],
      label: json['label'],
    );
  }
}
