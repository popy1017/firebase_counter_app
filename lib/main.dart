import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
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
  int _counter = 0;

  CollectionReference _counters =
      FirebaseFirestore.instance.collection('counters');

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    updateCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
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
    return FutureBuilder<bool>(
      future: fetchCounter(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Text('エラーが発生しました。');
        }

        if (snapshot.hasData) {
          return Text(
            '$_counter',
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

  // Firestoreに保存してあるカウンターを取ってくる
  // なかった場合は新たにDocumentを作る
  Future<bool> fetchCounter() async {
    try {
      final String _userId = context.select((AuthModel auth) => auth.user.uid);

      final DocumentSnapshot snapshot = await _counters.doc(_userId).get();
      Map<String, dynamic> data = snapshot.data();

      if (data == null) {
        await createCounter();
      } else {
        final int count = data['count'];
        setState(() {
          _counter = count;
        });
      }
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  Future<bool> createCounter() async {
    final String _userId = context.read<AuthModel>().user.uid;
    try {
      await _counters.doc(_userId).set({'count': 0});
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  Future<bool> updateCounter() async {
    final String _userId = context.read<AuthModel>().user.uid;
    try {
      await _counters.doc(_userId).update({'count': _counter});
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }
}
