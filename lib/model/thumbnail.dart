class Thumbnail {
  String url;
  int width;
  int height;

  Thumbnail(
    this.url,
    this.width,
    this.height,
  );

  Thumbnail.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
    };
  }
}
