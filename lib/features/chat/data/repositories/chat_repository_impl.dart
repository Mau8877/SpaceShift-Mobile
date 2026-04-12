import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatSummary>> getChats() async {
    return await remoteDataSource.getChats();
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String conversacionId, {int page = 0, int size = 20}) async {
    return await remoteDataSource.getChatMessages(conversacionId, page: page, size: size);
  }
}
