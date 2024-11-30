class SubjectData {
  final String career;
  final int semester;
  final List<String> subjects;

  SubjectData({
    required this.career,
    required this.semester,
    required this.subjects,
  });

  factory SubjectData.fromFirestore(Map<String, dynamic> data) {
    return SubjectData(
      career: data['career'] ?? '',
      semester: data['semester'] ?? 1,
      subjects: List<String>.from(data['subjects'] ?? []),
    );
  }
}

