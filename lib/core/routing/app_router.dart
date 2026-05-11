import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/main_layout_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/properties/domain/publicacion.dart';
import '../../features/properties/presentation/screens/create_publication_screen.dart';
import '../../features/properties/presentation/screens/property_detail_screen.dart';
import '../../features/properties/presentation/screens/property_list_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';
import '../../features/properties/presentation/screens/mis_inmuebles_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/password-recovery',
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/create_publication',
        builder: (context, state) {
           final pub = state.extra as Publicacion?;
           return CreatePublicationScreen(publicacion: pub);
        },
      ),
      GoRoute(
        path: '/mis_inmuebles',
        builder: (context, state) => const MisInmueblesScreen(),
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
