import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chat_providers.dart';

class BandejaEntradaScreen extends ConsumerWidget {
  const BandejaEntradaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
      ),
      body: chatListAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No tienes mensajes aún.'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chat.fotoOtroUsuario.isNotEmpty
                      ? NetworkImage(chat.fotoOtroUsuario)
                      : null,
                  child: chat.fotoOtroUsuario.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(chat.nombreOtroUsuario),
                subtitle: Text(chat.tituloPropiedad),
                trailing: Text(_formatDate(chat.ultimoMensajeFecha)),
                onTap: () {
                  context.push(
                    '/chat_detail/${chat.conversacionId}',
                    extra: chat.nombreOtroUsuario,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
