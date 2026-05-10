import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
              final hasUnread = chat.mensajesSinLeer > 0;

              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: chat.fotoOtroUsuario.isNotEmpty
                          ? NetworkImage(chat.fotoOtroUsuario)
                          : null,
                      child: chat.fotoOtroUsuario.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: ShadTheme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            chat.mensajesSinLeer > 99
                                ? '99+'
                                : '${chat.mensajesSinLeer}',
                            style: TextStyle(
                              color: ShadTheme.of(context).colorScheme.primaryForeground,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  chat.nombreOtroUsuario,
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(chat.tituloPropiedad),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(chat.ultimoMensajeFecha),
                      style: TextStyle(
                        fontSize: 11,
                        color: hasUnread
                            ? ShadTheme.of(context).colorScheme.primary
                            : ShadTheme.of(context).colorScheme.mutedForeground,
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
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
