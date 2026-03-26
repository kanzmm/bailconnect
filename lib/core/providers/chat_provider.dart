import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/message_model.dart';
import '../config/supabase_config.dart';

class ChatService {
  // Récupérer les conversations de l'utilisateur
  Future<List<Conversation>> getConversations() async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await SupabaseConfig.client.conversations
          .select()
          .or('user_id_1.eq.$userId,user_id_2.eq.$userId')
          .order('updated_at', ascending: false);

      return (response as List)
          .map(
            (json) => Conversation(
              id: json['id'] as String,
              participantIds: [
                json['user_id_1'] as String,
                json['user_id_2'] as String,
              ],
              participantNames: ['User 1', 'User 2'],
              lastMessageAt: DateTime.parse(json['updated_at'] as String),
              lastMessage: json['last_message'] as String?,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur getConversations: $e');
      return [];
    }
  }

  // Récupérer les messages d'une conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await SupabaseConfig.client.messages
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map(
            (json) => Message(
              id: json['id'] as String,
              conversationId: json['conversation_id'] as String,
              senderId: json['sender_id'] as String,
              senderName: json['sender_name'] as String,
              senderImage: json['sender_image'] as String?,
              content: json['content'] as String,
              timestamp: DateTime.parse(json['created_at'] as String),
              isRead: json['is_read'] as bool? ?? false,
              imageUrl: json['image_url'] as String?,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur getMessages: $e');
      return [];
    }
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      final userName = SupabaseConfig.auth.currentUser?.email ?? 'User';

      if (userId == null) throw Exception('Utilisateur non authentifié');

      await SupabaseConfig.client.messages.insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'sender_name': userName,
        'content': content,
        'is_read': false,
      });

      // Mettre à jour le dernier message de la conversation
      await SupabaseConfig.client.conversations
          .update({
            'last_message': content,
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Erreur envoi message: $e');
    }
  }

  // Commencer une nouvelle conversation
  Future<Conversation> startConversation({
    required String userId,
    required String participantId,
  }) async {
    try {
      // Vérifier si la conversation existe déjà
      final existing = await SupabaseConfig.client.conversations
          .select()
          .or('user_id_1.eq.$userId,user_id_2.eq.$participantId')
          .or('user_id_1.eq.$participantId,user_id_2.eq.$userId')
          .limit(1);

      if ((existing as List).isNotEmpty) {
        final conv = existing.first;
        return Conversation(
          id: conv['id'] as String,
          participantIds: [
            conv['user_id_1'] as String,
            conv['user_id_2'] as String,
          ],
          participantNames: ['User 1', 'User 2'],
          lastMessageAt: DateTime.parse(conv['updated_at'] as String),
          lastMessage: conv['last_message'] as String?,
        );
      }

      // Créer une nouvelle conversation
      final response = await SupabaseConfig.client.conversations
          .insert({
            'user_id_1': userId,
            'user_id_2': participantId,
            'last_message': null,
            'last_message_time': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Conversation(
        id: response['id'] as String,
        participantIds: [userId, participantId],
        participantNames: ['User 1', 'User 2'],
        lastMessageAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erreur création conversation: $e');
    }
  }

  // Marquer les messages comme lus
  Future<void> markAsRead(String conversationId) async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;

      await SupabaseConfig.client.messages
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);
    } catch (e) {
      print('Erreur markAsRead: $e');
    }
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final conversationsProvider = FutureProvider((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getConversations();
});

final messagesProvider = FutureProvider.family((
  ref,
  String conversationId,
) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(conversationId);
});
