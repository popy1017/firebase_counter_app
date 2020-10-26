import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Center(
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
                  onPressed: () {
                    print('click');
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
      ),
    );
  }
}
