import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/models/chat_message.dart';

class StompClientService {
  final TokenStorage tokenStorage;
  StompClient? _stompClient;
  Completer<void>? _connectionCompleter;
  
  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  StompClientService({required this.tokenStorage});

  Future<void> connect() async {
    if (_stompClient != null) {
      // Si ya está verdaderamente conectado, retornamos
      if (_stompClient!.connected) return;
      // Si está en proceso, esperamos
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
         await _connectionCompleter!.future;
         return;
      }
      // En otro caso (ej. re-conectando tras un error inicial), creamos nuevo completer
      _connectionCompleter = Completer<void>();
    } else {
      _connectionCompleter = Completer<void>();
    }

    final token = await tokenStorage.getToken() ?? '';
    final url = dotenv.env['WS_URL'] ?? 'ws://10.0.2.2:8081/ws-chat';

    _stompClient ??= StompClient(
      config: StompConfig(
        url: url,
        onConnect: (frame) {
          print('Conectado a STOMP!');
          if (!(_connectionCompleter?.isCompleted ?? true)) {
             _connectionCompleter?.complete();
          }
        },
        beforeConnect: () async {
          print('Iniciando handshake STOMP a $url');
        },
        onWebSocketError: (dynamic error) {
          print('Error de conexión WS: $error');
          if (!(_connectionCompleter?.isCompleted ?? true)) {
             _connectionCompleter?.completeError(error);
          }
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    
    if (!_stompClient!.isActive) {
      _stompClient!.activate();
    }
    
    return _connectionCompleter!.future;
  }

  // Permite suscribirse a un tópico bajo demanda y retorna la función para desuscribirse
  Function({Map<String, String>? unsubscribeHeaders})? subscribeToChat(String conversacionId) {
    if (_stompClient == null || !_stompClient!.connected) {
      print('Intento suscribirse, pero STOMP no está completamente conectado.');
      return null;
    }
    
    return _stompClient!.subscribe(
      destination: '/topic/chat.$conversacionId',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final jsonMap = json.decode(frame.body!);
            final message = ChatMessage.fromJson(jsonMap);
            _messageController.add(message);
          } catch (e) {
            print('Error parseando JSON STOMP en recepción: $e');
          }
        }
      },
    );
  }

  void sendMessage(String conversacionId, String contenido) {
    if (_stompClient == null || !_stompClient!.connected) {
      print('Intento enviar mensaje, pero STOMP no está conectado.');
      return;
    }
    
    final payload = {
      'conversacionId': conversacionId,
      'contenido': contenido,
    };
    
    _stompClient!.send(
      destination: '/app/chat.send',
      body: json.encode(payload),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    print('STOMP_DESCONECTADO');
  }
}
