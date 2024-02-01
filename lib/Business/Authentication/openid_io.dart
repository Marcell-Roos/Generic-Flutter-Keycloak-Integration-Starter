import 'dart:io';
import 'package:logger/logger.dart';
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:http/http.dart' as http;

import 'authentication.dart';

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  // create a function to open a browser with an url
  urlLauncher(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri) || Platform.isAndroid) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // create an authenticator
  var authenticator = io.Authenticator(client,
      scopes: scopes, port: 4000, urlLancher: urlLauncher);

  // starts the authentication
  var c = await authenticator.authorize();

  // close the webview when finished
  if (Platform.isAndroid || Platform.isIOS) {
    closeInAppWebView();
  }

  return c;
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  return null;
}

void logoutAPICall(String keycloakUri) async {
  var logger = Logger();
  Uri uri = Uri.parse('$keycloakUri/protocol/openid-connect/logout?id_token_hint=${Authentication.credential!.idToken.toCompactSerialization()}');

  try{
    await http.get(uri);
    logger.i('User has been logged out.');
  } catch(e){
    // No internet connection can cause an error here
    logger.e('An error occurred attempting to logout');
  }

}

