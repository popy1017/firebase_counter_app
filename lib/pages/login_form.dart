import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sign_button/sign_button.dart';
import 'package:special_counter_app/main.dart';
import 'package:special_counter_app/models/auth_model.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: _buildSocialLogin(context),
    );
  }

  Center _buildSocialLogin(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100,
            horizontal: 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SignInButton(
                buttonType: ButtonType.apple,
                onPressed: () {
                  print('click');
                },
              ),
              SignInButton(
                buttonType: ButtonType.google,
                onPressed: () async {
                  print('click');
                  await _login(context);
                },
              ),
              SignInButton(
                buttonType: ButtonType.twitter,
                onPressed: () {
                  print('click');
                },
              ),
              SignInButton(
                buttonType: ButtonType.github,
                onPressed: () {
                  print('click');
                },
              ),
              SignInButton(
                buttonType: ButtonType.yahoo,
                onPressed: () {
                  print('click');
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    EasyLoading.show(status: 'loading...');
    if (await context.read<AuthModel>().login()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage(title: "カウンター")),
        (_) => false,
      );
    }
    EasyLoading.dismiss();
  }
}
