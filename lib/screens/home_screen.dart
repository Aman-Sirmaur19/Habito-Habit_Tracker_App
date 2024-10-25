import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../main.dart';
import '../models/habit.dart';
import '../widgets/dialogs.dart';
import '../widgets/app_name.dart';
import '../widgets/main_drawer.dart';
import '../widgets/circle_segment_widget.dart';
import 'habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late BannerAd bannerAd;
  bool isBannerLoaded = false;
  int _expandedIndex = -1;

  Future<void> checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
  }

  initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/8152722767',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    initializeBannerAd();
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
                  onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const HabitScreen(habit: null))),
                  tooltip: 'Add habit',
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            bottomNavigationBar: isBannerLoaded
                ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
                : const SizedBox(),
            drawer: const MainDrawer(),
            body: habits.isEmpty
                ? Center(
                    child: SizedBox(
                      width: 170,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/calender.png'),
                            const SizedBox(height: 10),
                            const Text(
                                'A journey of a thousand miles begins with a single step!',
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
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final isExpanded = _expandedIndex == index;
                      for (var habit in habits) {
                        if (habit.time.day != DateTime.now().day) {
                          if (habit.current != habit.target) {
                            habit.streak = 0;
                          }
                          habit.time = DateTime.now();
                          habit.current = 0;
                          habit.isTodayTaskDone = false;
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
                          child: Column(
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            habits[index].title,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (habits[index]
                                              .description
                                              .isNotEmpty)
                                            Text(habits[index].description,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          setState(() {
                                            if (habits[index].current ==
                                                habits[index].target) {
                                              habits[index].isTodayTaskDone =
                                                  false;
                                              habits[index].streak--;
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
                                              if (habits[index].current ==
                                                  habits[index].target) {
                                                habits[index].streak++;
                                                habits[index].isTodayTaskDone =
                                                    true;
                                              }
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
                                  size: 10,
                                  fontSize: 0,
                                  borderRadius: 3.5,
                                  margin: const EdgeInsets.all(1),
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
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white),
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
                                          Text(habits[index].streak.toString(),
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
                                                        habit: habits[index]))),
                                            tooltip: 'Edit',
                                            icon: const Icon(
                                                CupertinoIcons.pencil_outline)),
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
                                                CupertinoIcons.delete_solid,
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
