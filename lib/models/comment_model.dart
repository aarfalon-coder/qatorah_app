class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final int likes;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.replies = const [],
  });

  CommentModel copyWith({
    int? likes,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
    );
  }
}