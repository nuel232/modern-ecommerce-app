import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/component/my_textfield.dart';
import 'package:morden_ecommerce_app/services/auth/auth_service.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    void resetPassword() async {
      final auth = AuthService();

      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Enter your email Please')));
        return;
      }

      try {
        await auth.sendPasswordResetEmail(emailController.text);
        emailController.clear();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text('Email sent ')),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.2),
              ),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('No worries,We will send you an email'),

                  const SizedBox(height: 20),

                  MyTextfield(
                    controller: emailController,
                    hintText: 'Type your Email...',
                    obscureText: false,
                    borderRadius: 15,
                  ),

                  const SizedBox(height: 20),
                  MyButton(
                    text: 'Continue',
                    onTap: () => resetPassword(),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    Text(
                      'Sign In',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
