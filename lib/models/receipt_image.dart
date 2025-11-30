class ReceiptImage {
  final String path; // Local file path (for newly captured/selected images)
  final String url; // Remote Firebase Storage URL

  const ReceiptImage({required this.path, required this.url});

  /// Factory constructor from Firestore map
  factory ReceiptImage.fromMap(Map<String, dynamic> map) {
    return ReceiptImage(path: map['path'] as String, url: map['url'] as String);
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {'path': path, 'url': url};
  }

  /// Create from just a URL (for backward compatibility)
  factory ReceiptImage.fromPathAndUrl(String path, String url) {
    return ReceiptImage(path: path, url: url);
  }

  /// Create copy with optional modified fields
  ReceiptImage copyWith({required String path, required String url}) {
    return ReceiptImage(path: path, url: url);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReceiptImage && other.path == path && other.url == url;
  }

  @override
  int get hashCode => path.hashCode ^ url.hashCode;

  @override
  String toString() => 'ReceiptImage(path: $path, url: $url)';
}
