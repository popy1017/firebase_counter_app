import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sign_button/sign_button.dart';
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
                onPressed: () => _login(context, ButtonType.apple),
              ),
              SignInButton(
                buttonType: ButtonType.google,
                onPressed: () => _login(context, ButtonType.google),
              ),
              SignInButton(
                buttonType: ButtonType.twitter,
                onPressed: () => _login(context, ButtonType.twitter),
              ),
              SignInButton(
                buttonType: ButtonType.github,
                onPressed: () => _login(context, ButtonType.github),
              ),
              SignInButton(
                buttonType: ButtonType.yahoo,
                onPressed: () => _login(context, ButtonType.yahoo),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _login(BuildContext context, ButtonType type) async {
    return await runZonedGuarded<Future<bool>>(() async {
      bool loggedIn = false;
      EasyLoading.show(status: 'loading...');
      if (await context.read<AuthModel>().login(type)) {
        loggedIn = true;
      }
      EasyLoading.dismiss();
      return loggedIn;
    }, FirebaseCrashlytics.instance.recordError);
  }
}
