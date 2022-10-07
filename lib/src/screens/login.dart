import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late GlobalKey<FormState> _formKey;
  Map<String, String>? data;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    data = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "assets/images/fssplogo.png",
                      width: 100,
                    )),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    data!["email"] = newValue!;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    data!["password"] = newValue!;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints.tight(const Size(double.infinity, 40)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: data!["email"]!,
                              password: data!["password"]!);
                        }
                      },
                      child: const Center(
                        child: Text('Login'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
