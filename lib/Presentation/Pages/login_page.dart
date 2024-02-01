import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import '../../Business/Authentication/authentication.dart';
import '../../constants.dart';
import '/Business/Authentication/openid_io.dart' if (dart.library.html) '/Business/Authentication/openid_browser.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserInfo? userInfo;

  @override
  void initState() {
    if (Authentication.credential != null) {
      Authentication.credential!.getUserInfo().then((userInfo) {
        Authentication.generateUser();
        setState(() {
          this.userInfo = userInfo;
        });
      });
    } else {
      _login();
    }
    super.initState();
  }
  _login() async {
    Authentication.credential = await authenticate(Authentication.client);
    userInfo = await Authentication.credential!.getUserInfo();
    Authentication.generateUser();
  }

  _logout() async{
    userInfo = null;
    logoutAPICall(kKeycloakURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (userInfo != null) ...[
              Text('Hello ${userInfo!.name}'),
              Text(userInfo!.email ?? ''),
              OutlinedButton(
                  child: const Text('Logout'),
                  onPressed: () async {
                    await _logout();
                    setState(() {
                      userInfo = null;
                    });
                  })
            ],
            userInfo == null ?
              OutlinedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    await _login();
                    setState(() {
                      userInfo = userInfo;
                    });
                  }) : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

