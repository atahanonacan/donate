import 'package:donate/apps/auth/presentation/controller/auth_controller.dart';
import 'package:donate/apps/auth/presentation/widgets/custom_field_widget.dart';
import 'package:donate/core/ui/widgets/wide_elevated_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/toolset/ui/ui_tools.dart';
import '../../../../dependency_injection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool termsAccepted = false;
  bool signinIn = false;
  @override
  void initState() {
    if (kDebugMode) {
      emailController.text = "eraykaya3030@gmail.com";
      passwordController.text = "password";
    }
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Avoids overflow
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: AssetImage("assets/images/logo_flat.png"),
              width: 145,
            ),
            verticalSpacer(45.0),
            CustomTextField(
              controller: emailController,
              icon: Icons.email,
              hintText: "Email Address",
              keyboardType: TextInputType.emailAddress,
            ),
            verticalSpacer(16.0),
            CustomTextField(
              controller: passwordController,
              icon: Icons.lock,
              hintText: "Password",
              isPassword: true,
            ),
            verticalSpacer(16.0),
            WideElevatedButton(
              // Login Button
              onPressed: () async {
                setState(() {
                  signinIn = true;
                });
                //Login using email and password
                await sl<AuthController>()
                    .login(emailController.text, passwordController.text, (e) {
                  setState(() {
                    signinIn = false;
                  });
                  if (e.code == "invalid-credential") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Invalid Credentials"),
                    ));
                  } else if (e.code == "too-many-requests") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Too Many Requests"),
                    ));
                  }
                });
              },
              enabled: !signinIn,
              child: const Text(
                "Sign In",
                textScaleFactor: 1.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/register");
              },
              child: Text("Don't have an account?",
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(0.4))),
            ),
            WideElevatedButton(
                onPressed: () {},
                style: ElevatedButtonTheme.of(context).style?.copyWith(
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.blue),
                    ),
                child: const Text("Continue with Google")),
            verticalSpacer(4.0),
            // Terms and Conditions
          ],
        ),
      )),
    );
  }
}
