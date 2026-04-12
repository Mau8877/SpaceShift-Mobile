import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/main_layout_screen.dart';
import '../../features/properties/domain/publicacion.dart';
import '../../features/properties/presentation/screens/create_publication_screen.dart';
import '../../features/properties/presentation/screens/property_detail_screen.dart';
import '../../features/properties/presentation/screens/property_list_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainLayoutScreen(), // Ahora apuntamos al Layout
      ),
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/create_publication',
        builder: (context, state) => const CreatePublicationScreen(),
      ),
      GoRoute(
        path: '/property_detail',
        builder: (context, state) {
          // Extraemos el objeto publicacion que llega como extra al hacer "push"
          final pub = state.extra as Publicacion;
          return PropertyDetailScreen(publicacion: pub);
        },
      ),
      GoRoute(
        path: '/chat_detail/:id',
        builder: (context, state) {
          final conversacionId = state.pathParameters['id']!;
          final nombreOtroUsuario = state.extra as String? ?? 'Chat';
          return ChatDetailScreen(
            conversacionId: conversacionId,
            nombreOtroUsuario: nombreOtroUsuario,
          );
        },
      ),
    ],
  );
}
