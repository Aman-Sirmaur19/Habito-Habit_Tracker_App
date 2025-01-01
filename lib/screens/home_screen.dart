import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';
import '../models/habit.dart';
import '../widgets/dialogs.dart';
import '../widgets/app_name.dart';
import '../widgets/main_drawer.dart';
import '../widgets/custom_heat_map.dart';
import '../widgets/custom_banner_ad.dart';
import '../widgets/circle_segment_widget.dart';
import 'habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _expandedIndex = -1;
  final _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Future<void> _checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          _update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void _update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToHabit(),
        builder: (ctx, Box<Habit> box, Widget? child) {
          List<Habit> habits = box.values.toList();
          return Scaffold(
            appBar: AppBar(
              title: const AppName(),
              actions: [
                IconButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                            title: Text(
                              'NOTE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Divider(),
                                Text(
                                  '\n\u2022 Click on the "circular counter widget" to edit current count of your habit.\n',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '\u2022 Click on the habit card for more settings.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                  tooltip: 'Info',
                  icon: const Icon(Icons.info_outline_rounded, size: 27),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const HabitScreen(habit: null))),
                  tooltip: 'Add habit',
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 27),
                ),
              ],
            ),
            bottomNavigationBar: const CustomBannerAd(),
            drawer: const MainDrawer(),
            body: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/calender.png', width: 150),
                        const SizedBox(height: 10),
                        const Text(
                            'A journey of a thousand\nmiles begins with a\nsingle step!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blue),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (_) =>
                                        const HabitScreen(habit: null))),
                            child: const Text('Get Started'))
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      Habit.setDataForNextDay(habits);
                      final isExpanded = _expandedIndex == index;
                      final streak =
                          Habit.calculateCurrentStreak(habits[index].dataOfDay);
                      return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 0.25,
                              color: habits[index].color,
                            ),
                            color: habits[index].color.withOpacity(.03),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded
                                        ? -1
                                        : index; // Toggle expanded state
                                  });
                                },
                                title: ListTile(
                                  // tileColor: Colors.blue.shade300,
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color:
                                            habits[index].color.withOpacity(.2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      IconData(
                                        habits[index].iconCodePoint,
                                        fontFamily:
                                            habits[index].iconFontFamily,
                                        fontPackage: 'font_awesome_flutter',
                                      ),
                                      size: 20, // Adjust size if needed
                                      color: habits[index]
                                          .color, // Optional: set icon color
                                    ),
                                  ),
                                  title: Text(
                                    habits[index].title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: habits[index].description.isNotEmpty
                                      ? Text(habits[index].description,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ))
                                      : null,
                                  trailing: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      onTap: () {
                                        habits[index].time = DateTime.now();
                                        int current = habits[index]
                                            .dataOfDay[_today]!['current']!;
                                        int target = habits[index]
                                            .dataOfDay[_today]!['target']!;
                                        setState(() {
                                          if (current == target) {
                                            current = 0;
                                            final percentForEachDay =
                                                <DateTime, int>{
                                              _today: 10 * current ~/ target,
                                            };
                                            habits[index].datasets.addEntries(
                                                percentForEachDay.entries);
                                          } else {
                                            current++;
                                            final percentForEachDay =
                                                <DateTime, int>{
                                              _today: 10 * current ~/ target,
                                            };
                                            habits[index].datasets.addEntries(
                                                percentForEachDay.entries);
                                          }
                                          final updatedDataOfDay = Map<DateTime,
                                                  Map<String, int>>.from(
                                              habits[index].dataOfDay);
                                          updatedDataOfDay[_today] = {
                                            'current': current,
                                            'target': target,
                                          };
                                          habits[index].dataOfDay =
                                              updatedDataOfDay;
                                          habits[index].save();
                                        });
                                      },
                                      child: CircleSegmentWidget(
                                        current: habits[index]
                                            .dataOfDay[_today]!['current']!,
                                        target: habits[index]
                                            .dataOfDay[_today]!['target']!,
                                        color: habits[index].color,
                                      )),
                                ),
                                subtitle: CustomHeatMap(
                                    habit: habits[index],
                                    onClick: (value) {
                                      setState(() {
                                        _expandedIndex = isExpanded
                                            ? -1
                                            : index; // Toggle expanded state
                                      });
                                    }),
                              ),
                              if (isExpanded)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                      child: Row(
                                        children: [
                                          const Text('Current streak:\t',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontWeight: FontWeight.bold)),
                                          const Icon(
                                            Icons.local_fire_department_rounded,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(streak.toString(),
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (_) => HabitScreen(
                                                          habit: habits[index],
                                                          isCalender: true,
                                                        ))),
                                            tooltip: 'Edit Heatmap',
                                            icon: const Icon(
                                              FontAwesomeIcons
                                                  .solidCalendarDays,
                                              color: Colors.green,
                                            )),
                                        IconButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (_) => HabitScreen(
                                                        habit: habits[index]))),
                                            tooltip: 'Edit Habit',
                                            icon: const Icon(
                                                FontAwesomeIcons.penToSquare)),
                                        IconButton(
                                            onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                        'Are you sure?'),
                                                    content: const Text(
                                                        'Do you want to delete this?'),
                                                    actions: <Widget>[
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            TextButton(
                                                                child:
                                                                    const Text(
                                                                        'Yes'),
                                                                onPressed: () {
                                                                  base.dataStore
                                                                      .deleteHabit(
                                                                          habit:
                                                                              habits[index]);
                                                                  Navigator.of(
                                                                          ctx)
                                                                      .pop();
                                                                  Dialogs.showSnackBar(
                                                                      context,
                                                                      'Habit deleted successfully!');
                                                                }),
                                                            TextButton(
                                                                child:
                                                                    const Text(
                                                                        'No'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          ctx)
                                                                      .pop();
                                                                }),
                                                          ])
                                                    ],
                                                  ),
                                                ),
                                            tooltip: 'Delete',
                                            icon: const Icon(
                                                FontAwesomeIcons.solidTrashCan,
                                                color: Colors.red)),
                                      ],
                                    ),
                                  ],
                                )
                            ],
                          ));
                    }),
          );
        });
  }
}
