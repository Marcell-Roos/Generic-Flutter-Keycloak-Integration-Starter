import 'dart:async';

import 'package:logger/logger.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;
import 'package:http/http.dart' as http;

import 'authentication.dart';

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  authenticator.authorize();

  return Completer<Credential>().future;
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  var c = await authenticator.credential;

  return c;
}

void logoutAPICall(String keycloakUri) async {
  var logger = Logger();
  Uri uri = Uri.parse('$keycloakUri/protocol/openid-connect/logout?id_token_hint=${Authentication.credential!.idToken.toCompactSerialization()}');

  // This will cause a CORS error on web which is fine, once the request is made a logout will occur
  // In this case the error should be ignored and can assume a successfully logout.
  try{
    await http.get(uri);
  } catch(e){
    // do nothing
  }
  logger.i('User has been logged out.');

}
