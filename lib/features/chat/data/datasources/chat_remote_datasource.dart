import 'package:dio/dio.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_summary.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatSummary>> getChats();
  Future<List<ChatMessage>> getChatMessages(String conversacionId, {int page = 0, int size = 20});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChatSummary>> getChats() async {
    try {
      final response = await dio.get('/chats');
      final data = response.data as List;
      return data.map((e) => ChatSummary.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch chats: ${e.message}');
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String conversacionId, {int page = 0, int size = 20}) async {
    try {
      final response = await dio.get(
        '/chats/$conversacionId/messages',
        queryParameters: {'page': page, 'size': size},
      );
      final jsonResponse = response.data as Map<String, dynamic>;
      final content = jsonResponse['content'] as List;
      return content.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch messages: ${e.message}');
    }
  }
}
