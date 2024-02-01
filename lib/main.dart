import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import 'Business/Authentication/authentication.dart';
import '/Business/Authentication/openid_io.dart' if (dart.library.html) '/Business/Authentication/openid_browser.dart';
import 'Presentation/Pages/login_page.dart';
import 'constants.dart';


Future<Client> getClient() async {
  var uri = Uri.parse(kKeycloakURL);
  var clientId = kClientId;

  var issuer = await Issuer.discover(uri);
  return Client(issuer, clientId);
}

Future<void> main() async {
  // Initialize
  Authentication.client = await getClient();
  Authentication.credential = await getRedirectResult(Authentication.client);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Keycloak Login Demo',
      home: LoginPage(title: 'Login Page'),
    );
  }
}