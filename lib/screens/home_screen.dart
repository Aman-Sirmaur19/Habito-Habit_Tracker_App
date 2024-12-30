import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../main.dart';
import '../models/habit.dart';
import '../secrets.dart';
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
      adUnitId: Secrets.bannerAdId,
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
    // initializeBannerAd();
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
                  icon: const Icon(CupertinoIcons.info),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const HabitScreen(habit: null))),
                  tooltip: 'Add habit',
                  icon: const Icon(Icons.add),
                ),
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
                                contentPadding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
                                        color: habits[index].color,
                                      )),
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
                                  colorsets: {
                                    1: habits[index].color.withOpacity(0.1),
                                    2: habits[index].color.withOpacity(0.2),
                                    3: habits[index].color.withOpacity(0.3),
                                    4: habits[index].color.withOpacity(0.4),
                                    5: habits[index].color.withOpacity(0.5),
                                    6: habits[index].color.withOpacity(0.6),
                                    7: habits[index].color.withOpacity(0.7),
                                    8: habits[index].color.withOpacity(0.8),
                                    9: habits[index].color.withOpacity(0.9),
                                    10: habits[index].color,
                                  },
                                ),
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
