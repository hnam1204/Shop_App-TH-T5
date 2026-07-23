class AppSettings {
  final bool isDarkMode;
  final String language;
  final bool notificationEnabled;
  final String themeMode;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'English',
    this.notificationEnabled = true,
    this.themeMode = 'system',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final language = json['language']?.toString() ?? 'English';
    return AppSettings(
      isDarkMode: json['isDarkMode'] == true,
      language: language == 'Vietnamese' ? 'Vietnamese' : 'English',
      notificationEnabled: json['notificationEnabled'] != false,
      themeMode: const {'system', 'light', 'dark'}.contains(json['themeMode'])
          ? json['themeMode'].toString()
          : (json['isDarkMode'] == true ? 'dark' : 'light'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'notificationEnabled': notificationEnabled,
      'themeMode': themeMode,
    };
  }

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationEnabled,
    String? themeMode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
