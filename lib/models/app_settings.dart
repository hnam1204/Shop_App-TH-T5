class AppSettings {
  final bool isDarkMode;
  final String language;
  final bool notificationEnabled;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'English',
    this.notificationEnabled = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final language = json['language']?.toString() ?? 'English';
    return AppSettings(
      isDarkMode: json['isDarkMode'] == true,
      language: language == 'Vietnamese' ? 'Vietnamese' : 'English',
      notificationEnabled: json['notificationEnabled'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'notificationEnabled': notificationEnabled,
    };
  }

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}
