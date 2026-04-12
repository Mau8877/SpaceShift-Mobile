import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        return null;
      }
      return payloadMap;
    } catch (e) {
      return null;
    }
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }
    return utf8.decode(base64Url.decode(output));
  }

  static String? extractUserId(String token) {
    final Map<String, dynamic>? payload = parseJwt(token);
    if (payload == null) return null;
    
    // Spring Security typical claims for user ID.
    // It might be 'usuarioId', 'id', 'sub', or 'uuid'.
    if (payload.containsKey('usuarioId')) return payload['usuarioId'].toString();
    if (payload.containsKey('id')) return payload['id'].toString();
    if (payload.containsKey('uuid')) return payload['uuid'].toString();
    
    // En caso de que se use el sub (email) en vez de ID y no venga el ID, retornar sub u otro fallback
    return payload['sub']?.toString();
  }
}
