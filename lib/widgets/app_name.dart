import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  const AppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Habit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(width: 2),
        Image.asset('assets/images/pie-chart.png', width: 20),
      ],
    );
  }
}
