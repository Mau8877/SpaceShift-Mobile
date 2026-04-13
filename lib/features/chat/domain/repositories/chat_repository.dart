import '../models/chat_message.dart';
import '../models/chat_summary.dart';

abstract class ChatRepository {
  Future<List<ChatSummary>> getChats();
  Future<List<ChatMessage>> getChatMessages(String conversacionId, {int page = 0, int size = 20});
}
