import 'package:logger/logger.dart';
import 'package:openid_client/openid_client.dart';

import '../../Data/Models/Profile/user.dart';

class Authentication{
  static  Credential? credential;
  static late final Client client;
  static late final User user;

  static void generateUser() async {
    TokenResponse responseToken = await credential!.getTokenResponse();
    user = User(idToken: credential!.idToken, jwtString: responseToken.accessToken!);
    var logger = Logger();
    logger.i('User "${user.username}" logged in.');
  }



}

