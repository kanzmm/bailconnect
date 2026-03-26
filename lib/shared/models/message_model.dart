/// Modèle Message
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Modèle Conversation
class Conversation {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    List<String>? participantNames,
    DateTime? lastMessageAt,
    String? lastMessage,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
