import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../main.dart';
import '../models/habit.dart';
import '../widgets/circle_segment_widget.dart';
import '../widgets/dialogs.dart';
import '../widgets/main_drawer.dart';
import '../widgets/new_habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToHabit(),
        builder: (ctx, Box<Habit> box, Widget? child) {
          List<Habit> habits = box.values.toList();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(
                'HABITO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const NewHabit();
                        });
                  },
                  tooltip: 'Add Habit',
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            drawer: const MainDrawer(),
            body: habits.isEmpty
                ? ListView(
                    padding: EdgeInsets.only(top: mq.height * .15),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Text('No habits added yet!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30)),
                            const SizedBox(height: 15),
                            Image.asset('assets/images/waiting.png',
                                height: mq.height * .35)
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      for (var habit in habits) {
                        if (habit.time.day != DateTime.now().day) {
                          habit.time = DateTime.now();
                          habit.current = 0;
                          final percentForEachDay = <DateTime, int>{
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ): 10 * habit.current ~/ habit.target,
                          };
                          habit.datasets.addEntries(percentForEachDay.entries);
                          habit.save();
                        }
                      }
                      return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habits[index].title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    if (habits[index].description.isNotEmpty)
                                      Text(habits[index].description,
                                          style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (habits[index].current ==
                                                habits[index].target) {
                                              habits[index].current = 0;
                                              final percentForEachDay =
                                                  <DateTime, int>{
                                                DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                ): 10 *
                                                    habits[index].current ~/
                                                    habits[index].target,
                                              };
                                              habits[index].datasets.addEntries(
                                                  percentForEachDay.entries);
                                            } else {
                                              habits[index].current++;
                                              final percentForEachDay =
                                                  <DateTime, int>{
                                                DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                ): 10 *
                                                    habits[index].current ~/
                                                    habits[index].target,
                                              };
                                              habits[index].datasets.addEntries(
                                                  percentForEachDay.entries);
                                            }
                                            habits[index].save();
                                          });
                                        },
                                        child: CircleSegmentWidget(
                                          current: habits[index].current,
                                          target: habits[index].target,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          base.dataStore.deleteHabit(
                                              habit: habits[index]);
                                          Dialogs.showSnackBar(context,
                                              'Habit deleted successfully!');
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: HeatMap(
                              datasets: habits[index].datasets,
                              endDate: DateTime.now(),
                              scrollable: true,
                              showText: false,
                              showColorTip: false,
                              colorMode: ColorMode.color,
                              size: 12,
                              fontSize: 10,
                              colorsets: const {
                                1: Color.fromARGB(20, 2, 179, 8),
                                2: Color.fromARGB(40, 2, 179, 8),
                                3: Color.fromARGB(60, 2, 179, 8),
                                4: Color.fromARGB(80, 2, 179, 8),
                                5: Color.fromARGB(100, 2, 179, 8),
                                6: Color.fromARGB(120, 2, 179, 8),
                                7: Color.fromARGB(150, 2, 179, 8),
                                8: Color.fromARGB(180, 2, 179, 8),
                                9: Color.fromARGB(220, 2, 179, 8),
                                10: Color.fromARGB(255, 2, 179, 8),
                              },
                            ),
                          ));
                    }),
          );
        });
  }
}
