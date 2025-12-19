import 'package:flutter/material.dart';

class FuturisticButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FuturisticButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.tealAccent,
        elevation: 10,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.pressed)) {
            return 15;
          }
          return 10;
        }),
      ),
      child: Text(label),
    );
  }
}
