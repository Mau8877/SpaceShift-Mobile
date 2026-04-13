import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/jwt_utils.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/chat_detail_controller.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversacionId;
  final String nombreOtroUsuario;

  const ChatDetailScreen({
    super.key,
    required this.conversacionId,
    required this.nombreOtroUsuario,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.getToken();
    if (token != null) {
      if (mounted) {
        setState(() {
          currentUserId = JwtUtils.extractUserId(token);
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      ref.read(chatDetailControllerProvider(widget.conversacionId).notifier).sendMessage(text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatStateAsync = ref.watch(chatDetailControllerProvider(widget.conversacionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreOtroUsuario),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatStateAsync.when(
              data: (state) {
                if (state.error != null) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                if (state.messages.isEmpty) {
                  return const Center(child: Text('No hay mensajes en este chat.'));
                }
                return ListView.builder(
                  reverse: true, // asumiendo que los mensajes recientes están en insertados en el índice 0
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMe = currentUserId != null && msg.remitenteId == currentUserId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.lPrimary : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.contenido,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error inesperado: $e')),
            ),
          ),
          
          // Text Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2)
                )
              ]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.lPrimary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
