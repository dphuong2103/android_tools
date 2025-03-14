import 'package:android_tools/core/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginView());
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController userNameController;
  late final TextEditingController passwordController;
  bool showPassword = true;

  @override
  void initState() {
    userNameController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
            ),
            Gap(20),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            Gap(10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: !showPassword,
            ),
            Gap(10),
            Row(
              children: [
                Checkbox(
                  value: showPassword,
                  onChanged: (value) {
                    setState(() {
                      showPassword = value ?? false;
                    });
                  },
                ),
                Text("show password"),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (userNameController.text == "admin" &&
                    passwordController.text == "654321") {
                  context.push(RouteName.HOME);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid password!")),
                  );
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
