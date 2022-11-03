import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:flutter_chat_app/screen/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    } else {
      return Scaffold(
          body: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'image/Messages.png',
                    height: 180,
                    width: 180,
                  ),
                  sep(15),
                  const Text(
                    "Flutter Chat App",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                  sep(35),
                  textFormEmail(const Icon(Icons.email, color: Colors.blueGrey),
                      "Email", "Please enter you email", email),
                  sep(10),
                  textFormPass(),
                  sep(30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          shadowColor: Colors.black,
                          elevation: 10,
                          padding: const EdgeInsets.all(20)),
                      child: const Text('LOGIN',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          login(email.text, password.text).then(
                            (value) {
                              if (value != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => HomeScreen())));
                              } else {}
                              setState(() {
                                _isLoading = false;
                              });
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill all the field correctly')));
                        }
                      },
                    ),
                  ),
                  sep(10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignUpScreen())),
                    child: const Text('or create an account',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )),
      ));
    }
  }

  Widget textFormEmail(
      Icon icon, String label, String empty, TextEditingController controller) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    return TextFormField(
      cursorColor: Colors.blue,
      style: const TextStyle(color: Colors.black),
      //inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none),
          prefixIcon: icon,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black54,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10))),
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return empty;
        } else if (!RegExp(pattern).hasMatch(value)) {
          return "Please enter you email correctly";
        }
        return null;
      },
    );
  }

  Widget textFormPass() {
    return TextFormField(
      cursorColor: Colors.blue,
      obscureText: !_passwordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
          labelText: "Password",
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () => setState(() {
              _passwordVisible = !_passwordVisible;
            }),
          ),
          labelStyle: const TextStyle(color: Colors.black87),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black54,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10))),
      controller: password,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget sep(double h) {
    return SizedBox(height: h);
  }
}
