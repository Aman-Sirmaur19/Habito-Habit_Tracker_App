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
  int _expandedIndex = -1;

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
                          return const NewHabit(habit: null);
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
                      final isExpanded = _expandedIndex == index;
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
                          // color: Colors.purple.shade50,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded
                                        ? -1
                                        : index; // Toggle expanded state
                                  });
                                },
                                title: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          habits[index].title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        if (habits[index]
                                            .description
                                            .isNotEmpty)
                                          Text(habits[index].description,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                      ],
                                    ),
                                    InkWell(
                                        borderRadius: BorderRadius.circular(30),
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
                                  defaultColor: Colors.blueGrey.shade100,
                                  onClick: (value) {
                                    setState(() {
                                      _expandedIndex = isExpanded
                                          ? -1
                                          : index; // Toggle expanded state
                                    });
                                  },
                                  colorsets: const {
                                    1: Color.fromARGB(40, 33, 150, 243),
                                    2: Color.fromARGB(60, 33, 150, 243),
                                    3: Color.fromARGB(80, 33, 150, 243),
                                    4: Color.fromARGB(100, 33, 150, 243),
                                    5: Color.fromARGB(125, 33, 150, 243),
                                    6: Color.fromARGB(150, 33, 150, 243),
                                    7: Color.fromARGB(180, 33, 150, 243),
                                    8: Color.fromARGB(210, 33, 150, 243),
                                    9: Color.fromARGB(230, 33, 150, 243),
                                    10: Color.fromARGB(255, 2, 179, 8),
                                  },
                                ),
                              ),
                              if (isExpanded)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return NewHabit(
                                                    habit: habits[index]);
                                              });
                                        },
                                        tooltip: 'Edit',
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () => showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Are you sure?'),
                                                content: const Text(
                                                    'Do you want to delete this?'),
                                                actions: <Widget>[
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        TextButton(
                                                            child: const Text(
                                                                'Yes'),
                                                            onPressed: () {
                                                              base.dataStore
                                                                  .deleteHabit(
                                                                      habit: habits[
                                                                          index]);
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                              Dialogs.showSnackBar(
                                                                  context,
                                                                  'Habit deleted successfully!');
                                                            }),
                                                        TextButton(
                                                            child: const Text(
                                                                'No'),
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            }),
                                                      ])
                                                ],
                                              ),
                                            ),
                                        tooltip: 'Delete',
                                        icon: Icon(Icons.delete,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error)),
                                  ],
                                )
                            ],
                          ));
                    }),
          );
        });
  }
}
