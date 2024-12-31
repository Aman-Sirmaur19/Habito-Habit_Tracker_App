import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../models/habit.dart';

class CustomHeatMap extends StatelessWidget {
  final Habit habit;
  final dynamic Function(DateTime)? onClick;
  final bool showText;
  final double size;
  final double fontSize;
  final double borderRadius;
  final double margin;

  const CustomHeatMap({
    super.key,
    required this.habit,
    required this.onClick,
    this.showText = false,
    this.size = 10,
    this.fontSize = 0,
    this.borderRadius = 3.5,
    this.margin = 1,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      datasets: habit.datasets,
      endDate: DateTime.now(),
      scrollable: true,
      showText: showText,
      showColorTip: false,
      colorMode: ColorMode.color,
      size: size,
      fontSize: fontSize,
      textColor: Colors.black,
      borderRadius: borderRadius,
      margin: EdgeInsets.all(margin),
      defaultColor: habit.color.withOpacity(.075),
      onClick: onClick,
      colorsets: {
        1: habit.color.withOpacity(0.1),
        2: habit.color.withOpacity(0.2),
        3: habit.color.withOpacity(0.3),
        4: habit.color.withOpacity(0.4),
        5: habit.color.withOpacity(0.5),
        6: habit.color.withOpacity(0.6),
        7: habit.color.withOpacity(0.7),
        8: habit.color.withOpacity(0.8),
        9: habit.color.withOpacity(0.9),
        10: habit.color,
      },
    );
  }
}
