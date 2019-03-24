import 'package:not_too_shabby/model/thumbnail.dart';

class VideoDetail {
  String videoId;
  String publishedAt;
  String title;
  String description;
  Thumbnail defaultThumbnail;
  Thumbnail mediumThumbnail;
  Thumbnail highThumbnail;

  VideoDetail(
    this.videoId,
    this.publishedAt,
    this.title,
    this.description,
    this.defaultThumbnail,
    this.mediumThumbnail,
    this.highThumbnail,
  );

  VideoDetail.fromYoutubeJson(Map<String, dynamic> json) {
    final Map<String, dynamic> snippetJson = json['snippet'];
    final Map<String, dynamic> resourceJson = snippetJson['resourceId'];
    final Map<String, dynamic> thumbnailJson = snippetJson['thumbnails'];

    videoId = resourceJson['videoId'];
    publishedAt = snippetJson['publishedAt'];
    title = snippetJson['title'];
    description = snippetJson['description'];
    defaultThumbnail = Thumbnail.fromJson(thumbnailJson['default']);
    mediumThumbnail = Thumbnail.fromJson(thumbnailJson['medium']);
    highThumbnail = Thumbnail.fromJson(thumbnailJson['high']);
  }

  static List<VideoDetail> listFromJson(List<dynamic> dynamicVideoIds) {
    return dynamicVideoIds
        .map((dynamicVideoId) => VideoDetail.fromYoutubeJson(dynamicVideoId))
        .toList();
  }

  VideoDetail.fromLocalJson(Map<String, dynamic> json) {
    videoId = json['videoId'];
    publishedAt = json['publishedAt'];
    title = json['title'];
    description = json['description'];
    defaultThumbnail = Thumbnail.fromJson(json['defaultThumbnail']);
    mediumThumbnail = Thumbnail.fromJson(json['mediumThumbnail']);
    highThumbnail = Thumbnail.fromJson(json['highThumbnail']);
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'publishedAt': publishedAt,
      'title': title,
      'description': description,
      'defaultThumbnail': defaultThumbnail,
      'mediumThumbnail': mediumThumbnail,
      'highThumbnail': highThumbnail,
    };
  }
}
