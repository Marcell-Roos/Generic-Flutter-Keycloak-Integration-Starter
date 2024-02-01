import 'package:openid_client/openid_client.dart';

class User {

  late IdToken _idToken;
  late String _jwtString;

  /* fields to extract from IdToken */
  late String _username;

  User({required IdToken idToken, required String jwtString}) {
    _idToken = idToken;
    _jwtString = jwtString;
    _constructUserFromToken(_idToken);
  }

  void _constructUserFromToken(IdToken idToken) {
    _username = idToken.claims.toJson()['preferred_username'];
  }

  String get jwtString => _jwtString;
  String get username => _username;
}
