import 'package:flutter/material.dart';

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.isHidden,
    required this.onPressed,
  });

  final bool isHidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isHidden ? 'Prikaži lozinku' : 'Sakrij lozinku',
      onPressed: onPressed,
      icon: Icon(
        isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}
