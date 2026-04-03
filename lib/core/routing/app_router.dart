import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:space_shift/features/home/presentation/main_layout_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/properties/presentation/screens/property_list_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainLayoutScreen(), // Ahora apuntamos al Layout
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
}
