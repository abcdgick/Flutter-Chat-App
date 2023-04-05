import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:flutter_chat_app/screen/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
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
                  Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-jokris.appspot.com/o/Logo.png?alt=media&token=98cb4fc1-d47b-423f-b767-cc1f2589442e',
                    height: 180,
                    width: 180,
                  ),
                  sep(15),
                  const Text(
                    "JOHUFA Chat App",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                  sep(35),
                  textFormBiasa(
                      const Icon(Icons.text_format, color: Colors.blueGrey),
                      "Name",
                      "Please enter you name",
                      name),
                  sep(10),
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
                      child: const Text('SIGNUP',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          createAccount(
                                  name.text, email.text, password.text, context)
                              .then((value) {
                            if (value != null) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => HomeScreen())));
                            } else {}
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        }
                      },
                    ),
                  ),
                  sep(10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen())),
                    child: const Text('or login instead',
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

  Widget textFormBiasa(
      Icon icon, String label, String empty, TextEditingController controller) {
    return TextFormField(
      cursorColor: Colors.blue,
      onChanged: (value) => setState(() {}),
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.name,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]+"))
      ],
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
        }
        return null;
      },
    );
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
      keyboardType: TextInputType.emailAddress,
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
      keyboardType: TextInputType.visiblePassword,
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

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
          child: SpinKitCircle(
        size: 100,
        itemBuilder: ((context, index) {
          final colors = [Colors.blue, Colors.white];
          final color = colors[index % colors.length];

          return DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle));
        }),
      )),
    );
  }
}
