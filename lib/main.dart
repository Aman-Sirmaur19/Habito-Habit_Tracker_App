import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/hive_data_store.dart';
import 'models/habit.dart';
import 'screens/home_screen.dart';

late Size mq;

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
      theme: ThemeData(
        fontFamily: 'Fredoka',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.blue))),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
