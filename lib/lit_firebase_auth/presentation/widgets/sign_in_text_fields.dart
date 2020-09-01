import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snack_dating/screens/login.dart';

final border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(7),
);

class PasswordTextFormField extends StatelessWidget {
  const PasswordTextFormField({
    Key key,
    this.decoration,
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration ??
          InputDecoration(
            prefixIcon: const Icon(Icons.vpn_key),
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
      autocorrect: false,
      obscureText: true,
      onChanged: (value) => context.read<SignInUtil>().password = value,
      validator: context.read<SignInUtil>().passwordValidator,

    );
  }
}

class EmailTextFormField extends StatelessWidget {
  const EmailTextFormField({
    Key key,
    this.decoration,
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: decoration ??
          InputDecoration(
            prefixIcon: const Icon(Icons.email),
            border: border,
            labelText: 'Email',
          ),
      autocorrect: false,
      onChanged: (value) => context.read<SignInUtil>().email = value,
      validator: context.read<SignInUtil>().emailValidator,
    );
  }
}
