class SnackUser {
  final String? fcm;
  final String? preference;

  SnackUser({
    required this.fcm,
    required this.preference,
  });

  SnackUser.fromJson(Map<String, Object?> json)
      : this(
          fcm: json['fcm'] as String?,
          preference: json['preference'] as String?,
        );

  Map<String, Object?> toJson() {
    return {
      'fcm': fcm,
      'preference': preference,
    };
  }
}
