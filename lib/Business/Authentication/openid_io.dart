import 'dart:io';

import 'package:comb_enrollment_app/Business/Authentication/authentication.dart';
import 'package:comb_enrollment_app/constants.dart';
import 'package:logger/logger.dart';
import 'package:openid_client/openid_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:http/http.dart' as http;

// Save tokens used for next login to avoid user needing to go to login screen
Future _saveToken(TokenResponse token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('refresh_token', token.refreshToken!);
  await prefs.setString('token_type', token.tokenType!);
  await prefs.setString('id_token', token.idToken.toCompactSerialization());
}

// Login with refresh and Id token
Future<Credential> _loginWithToken(Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Credential credential;
  final rt = prefs.getString('refresh_token');
  final tt = prefs.getString('token_type');
  final it = prefs.getString('id_token');

  var issuer = await Issuer.discover(Uri.parse(kKeycloakURL));
  var client = Client(issuer, kClientId);
  credential = client.createCredential(
    accessToken: null, // force use refresh to get new token
    tokenType: tt,
    refreshToken: rt,
    idToken: it,
  );

  credential.validateToken(validateClaims: true, validateExpiry: true);
  _saveToken(await credential.getTokenResponse());

  return credential;
}

// Login with browser
Future<Credential> _loginWithBrowser(Client client,
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
  // TODO
  // Create a html page letting the user know they can close the browser
  // Needs to be styled
  var authenticator = io.Authenticator(client,
      scopes: scopes,
      port: 4000,
      urlLancher: urlLauncher,
      htmlPage: '<h1>BROWSER CAN BE CLOSED</h1>');
  // starts the authentication
  var c = await authenticator.authorize();

  // close the webview when finished
  if (Platform.isAndroid || Platform.isIOS) {
    closeInAppWebView();
  }
  _saveToken(await c.getTokenResponse());
  return c;
}

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  Logger logger = Logger(printer: PrettyPrinter(printTime: true));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // First check if we have tokens saved
  if (prefs.getString('refresh_token') != null &&
      prefs.getString('id_token') != null) {
    logger.i(
        "Found refresh_token and id_token stored on device, attempting login...");
    try {
      // Login with token
      return await _loginWithToken(client);
    } catch (e) {
      // Unable to login with token
      logger.w('Login with token failed');
      logger.w(e);
      // Try login with browser
      return await _loginWithBrowser(client, scopes: scopes);
    }

    // No Token was found, likely first login
  } else {
    return await _loginWithBrowser(client, scopes: scopes);
  }
}

// Stub to make class identical to openid_browser
Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  return null;
}

// API call to perform background logout
void logoutAPICall(String keycloakUri) async {
  var logger = Logger();
  Uri uri = Uri.parse(
      '$keycloakUri/protocol/openid-connect/logout?id_token_hint=${Authentication.credential!.idToken.toCompactSerialization()}');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // remove the saved tokens
  await prefs.remove('refresh_token');
  await prefs.remove('token_type');
  await prefs.remove('id_token');
  try {
    await http.get(uri);
    logger.i('User has been logged out.');
  } catch (e) {
    // No internet connection can cause an error here
    // TODO
    // Display message to user that they could not be logged out fully
    logger.e('An error occurred attempting to logout');
  }
}
