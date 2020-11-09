import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:special_counter_app/helpers/firestore_helper.dart';
import 'package:special_counter_app/models/auth_model.dart';
import 'package:special_counter_app/pages/login_form.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseインスタンスの初期化
  await Firebase.initializeApp();

  // FLutterのエラーをFirebase Crashlyticsに送るように設定
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: _LoginCheck(),
        builder: (BuildContext context, Widget child) {
          return FlutterEasyLoading(child: child);
        },
      ),
    );
  }
}

class _LoginCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool _loggedIn = context.watch<AuthModel>().loggedIn;

    return _loggedIn
        ? MyHomePage(
            title: 'カウンター',
          )
        : LoginForm();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentCount = 0;

  FirestoreHelper _firestoreHelper = FirestoreHelper.instance;

  Future<void> _incrementCounter() async {
    _currentCount++;

    final String userId = context.read<AuthModel>().user.uid;
    await _firestoreHelper.updateCounter(userId, _currentCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _firestoreHelper.updateCounter(
              context.read<AuthModel>().user.uid,
              0,
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAccountInfo(),
            Text(
              'You have pushed the button this many times:',
            ),
            _buildCounter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountInfo() {
    final User _user = context.select((AuthModel _auth) => _auth.user);

    // ログアウト直後に _user を null にしており、_user.photoURLでエラーが出るため分岐させている
    return _user != null
        ? Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(_user.photoURL ?? ''),
              ),
              title: Text(_user.displayName),
              subtitle: Text(_user.email),
            ),
          )
        : Container();
  }

  Widget _buildCounter() {
    final String userId = context.select((AuthModel auth) => auth.user?.uid);
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreHelper.getStream(userId),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Text('エラーが発生しました。');
        }

        if (snapshot.hasData) {
          final Map<String, dynamic> data = snapshot.data.data();

          if (data != null && data['count'] != null) {
            _currentCount = data['count'];
          }

          return Text(
            '$_currentCount',
            style: Theme.of(context).textTheme.headline4,
          );
        }

        return CircularProgressIndicator();
      },
    );
  }

  Future<void> _logout() async {
    await context.read<AuthModel>().logout();
  }
}
