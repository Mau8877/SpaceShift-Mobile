import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/chat_message.dart';
import 'chat_providers.dart';

part 'chat_detail_controller.g.dart';

class ChatDetailState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String? error;

  ChatDetailState({this.isLoading = false, this.messages = const [], this.error});

  ChatDetailState copyWith({bool? isLoading, List<ChatMessage>? messages, String? error}) {
    return ChatDetailState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

@riverpod
class ChatDetailController extends _$ChatDetailController {
  StreamSubscription? _messageSubscription;

  @override
  FutureOr<ChatDetailState> build(String conversacionId) async {
    final repository = ref.watch(chatRepositoryProvider);
    final stompService = ref.watch(stompClientServiceProvider);

    await stompService.connect();
    
    // Iniciar suscripción STOMP exclusiva para esta conversación
    Function? unsubscribeStr = stompService.subscribeToChat(conversacionId);
    
    _messageSubscription = stompService.messageStream.listen((incomingMessage) {
       if (incomingMessage.conversacionId == conversacionId) {
         final currentState = state.value;
         if (currentState != null) {
           state = AsyncValue.data(currentState.copyWith(
             messages: [incomingMessage, ...currentState.messages]
           ));
         }
       }
    });

    ref.onDispose(() {
      _messageSubscription?.cancel();
      if (unsubscribeStr != null) {
        unsubscribeStr(unsubscribeHeaders: {});
      }
    });

    try {
      final history = await repository.getChatMessages(conversacionId, page: 0, size: 50);
      return ChatDetailState(isLoading: false, messages: history.toList()); 
    } catch (e) {
      return ChatDetailState(isLoading: false, error: e.toString());
    }
  }

  void sendMessage(String contenido) {
    if (contenido.trim().isEmpty) return;
    
    final stompService = ref.read(stompClientServiceProvider);
    stompService.sendMessage(conversacionId, contenido);
  }
}
