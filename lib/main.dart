import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/habit.dart';
import 'widgets/theme.dart';
import 'screens/home_screen.dart';
import 'data/hive_data_store.dart';

late Size mq;

_initializeMobileAds() async {
  await MobileAds.instance.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Init Hive DB before runApp()
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter<Habit>(HabitAdapter());

  // Open all the boxes
  await Hive.openBox<Habit>(HiveDataStore.habitBoxName);
  _initializeMobileAds();
  runApp(BaseWidget(child: const MyApp()));
}

class BaseWidget extends InheritedWidget {
  BaseWidget({Key? key, required this.child}) : super(key: key, child: child);

  final HiveDataStore dataStore = HiveDataStore();
  final Widget child;

  static BaseWidget of(BuildContext context) {
    final BaseWidget? result =
        context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    assert(result != null, 'No BaseWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(BaseWidget old) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HabitO',
      theme: lightMode,
      darkTheme: darkMode,
      home: const HomeScreen(),
    );
  }
}
