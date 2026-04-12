import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/chat_summary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/datasources/stomp_client_service.dart';

final stompClientServiceProvider = Provider<StompClientService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final service = StompClientService(tokenStorage: tokenStorage);
  ref.onDispose(() => service.disconnect());
  return service;
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRemoteDataSourceImpl(dio: dio);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: dataSource);
});

final chatListProvider = FutureProvider.autoDispose<List<ChatSummary>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getChats();
});
