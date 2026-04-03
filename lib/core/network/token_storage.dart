import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _jwtKey = 'JWT_TOKEN';

  // Guardar el token cuando haces Login
  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  // Leer el token para inyectarlo
  Future<String?> getToken() async => await _storage.read(key: _jwtKey);

  // Borrar el token al cerrar sesión o cuando expira
  Future<void> clearToken() async {
    await _storage.delete(key: _jwtKey);
  }
}
