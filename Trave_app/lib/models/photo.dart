class Photo {
  final String id;
  final String filename;
  final String originalName;
  final String path;
  final String spotName;
  final String uploader;
  final String userRole;
  final DateTime uploadTime;
  final String status; // pending, approved, rejected
  final String title;
  final String description;
  final DateTime? reviewTime;
  final String? reviewReason;

  Photo({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.path,
    required this.spotName,
    required this.uploader,
    required this.userRole,
    required this.uploadTime,
    required this.status,
    required this.title,
    required this.description,
    this.reviewTime,
    this.reviewReason,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      spotName: json['spotName']?.toString() ?? '',
      uploader: json['uploader']?.toString() ?? '',
      userRole: json['userRole']?.toString() ?? '',
      uploadTime: json['uploadTime'] != null 
          ? DateTime.parse(json['uploadTime'].toString()) 
          : DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reviewTime: json['reviewTime'] != null 
          ? DateTime.parse(json['reviewTime'].toString()) 
          : null,
      reviewReason: json['reviewReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'originalName': originalName,
      'path': path,
      'spotName': spotName,
      'uploader': uploader,
      'userRole': userRole,
      'uploadTime': uploadTime.toIso8601String(),
      'status': status,
      'title': title,
      'description': description,
      'reviewTime': reviewTime?.toIso8601String(),
      'reviewReason': reviewReason,
    };
  }

  Photo copyWith({
    String? id,
    String? filename,
    String? originalName,
    String? path,
    String? spotName,
    String? uploader,
    String? userRole,
    DateTime? uploadTime,
    String? status,
    String? title,
    String? description,
    DateTime? reviewTime,
    String? reviewReason,
  }) {
    return Photo(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      originalName: originalName ?? this.originalName,
      path: path ?? this.path,
      spotName: spotName ?? this.spotName,
      uploader: uploader ?? this.uploader,
      userRole: userRole ?? this.userRole,
      uploadTime: uploadTime ?? this.uploadTime,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      reviewTime: reviewTime ?? this.reviewTime,
      reviewReason: reviewReason ?? this.reviewReason,
    );
  }

  // 便捷方法
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isFromGuide => userRole == 'guide';
  bool get isFromTourist => userRole == 'tourist';
} 