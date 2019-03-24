class YoutubeApiKey {
  final String value;

  YoutubeApiKey(
    this.value,
  );

  YoutubeApiKey.fromJson(Map<String, dynamic> json)
      : value = json['youtubeApiKey'];
}
