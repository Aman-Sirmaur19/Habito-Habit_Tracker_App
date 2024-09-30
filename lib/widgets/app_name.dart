import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  const AppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Habit',
            style: TextStyle(
              color: Colors.blue,
              letterSpacing: 1,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(width: 2),
        Image.asset('assets/images/pie-chart.png', width: 20),
      ],
    );
  }
}
