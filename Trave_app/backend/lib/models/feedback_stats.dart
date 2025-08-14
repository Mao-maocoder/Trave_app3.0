class FeedbackStats {
  final Map<int, int> ratings;
  final List<Comment> comments;

  FeedbackStats({required this.ratings, required this.comments});

  factory FeedbackStats.fromJson(Map<String, dynamic> json) {
    return FeedbackStats(
      ratings: Map<String, int>.from(json['ratings']).map((k, v) => MapEntry(int.parse(k), v)),
      comments: (json['comments'] as List).map((e) => Comment.fromJson(e)).toList(),
    );
  }
}

class Comment {
  final String user;
  final int score;
  final String content;

  Comment({required this.user, required this.score, required this.content});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'],
      score: json['score'],
      content: json['content'],
    );
  }
} 