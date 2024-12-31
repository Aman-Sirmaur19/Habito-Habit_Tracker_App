import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';
import '../models/habit.dart';
import '../widgets/dialogs.dart';
import '../widgets/app_name.dart';
import '../widgets/custom_heat_map.dart';
import '../widgets/custom_banner_ad.dart';
import '../widgets/custom_text_form_field.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key, required this.habit, this.isCalender = false});

  final Habit? habit;
  final bool isCalender;

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = FontAwesomeIcons.book;
  int _target = 0;
  final List<IconData> _icons = [
    FontAwesomeIcons.code,
    FontAwesomeIcons.flutter,
    FontAwesomeIcons.android,
    FontAwesomeIcons.penToSquare,
    FontAwesomeIcons.book,
    FontAwesomeIcons.noteSticky,
    FontAwesomeIcons.school,
    FontAwesomeIcons.check,
    FontAwesomeIcons.fire,
    FontAwesomeIcons.personWalking,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.personRunning,
    FontAwesomeIcons.chess,
    FontAwesomeIcons.personBiking,
    FontAwesomeIcons.football,
    FontAwesomeIcons.computer,
    FontAwesomeIcons.apple,
    FontAwesomeIcons.mobile,
    FontAwesomeIcons.pills,
    FontAwesomeIcons.heartPulse,
    FontAwesomeIcons.bed,
    FontAwesomeIcons.music,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.tv,
    FontAwesomeIcons.youtube,
    FontAwesomeIcons.instagram,
    FontAwesomeIcons.twitter,
    FontAwesomeIcons.facebook,
    FontAwesomeIcons.facebookMessenger,
    FontAwesomeIcons.whatsapp,
    FontAwesomeIcons.quora,
    FontAwesomeIcons.tiktok,
    FontAwesomeIcons.guitar,
    FontAwesomeIcons.om,
    FontAwesomeIcons.shower,
    FontAwesomeIcons.glassWaterDroplet,
    FontAwesomeIcons.dollarSign,
    FontAwesomeIcons.indianRupeeSign,
    FontAwesomeIcons.chartLine,
    FontAwesomeIcons.mugSaucer,
    FontAwesomeIcons.pizzaSlice,
    FontAwesomeIcons.iceCream,
    FontAwesomeIcons.banSmoking,
    FontAwesomeIcons.beerMugEmpty,
    FontAwesomeIcons.champagneGlasses,
    FontAwesomeIcons.faceSmile,
    FontAwesomeIcons.faceSadTear,
    FontAwesomeIcons.palette,
    FontAwesomeIcons.clock,
    FontAwesomeIcons.star,
    FontAwesomeIcons.heart,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedColor = Colors.blue;
      });
    });
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _descriptionController.text = widget.habit!.description;
      _target = widget.habit?.dataOfDay[_today]?['target'] ?? 0;
      _selectedIcon = IconData(
        widget.habit!.iconCodePoint,
        fontFamily: widget.habit!.iconFontFamily,
        fontPackage: 'font_awesome_flutter',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedColor = widget.habit!.color;
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // if habit already exist return true, else false
  bool _isHabitAlreadyExist() {
    if (widget.habit != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating habit
  dynamic _createOrUpdateHabit() {
    if (_titleController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter your plan');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter description');
      return;
    }

    if (_target == 0) {
      Dialogs.showErrorSnackBar(context, 'Set Target');
      return;
    }

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.habit != null) {
        // Update existing habit
        final oldHabit = widget.habit!;
        final updatedDatasets = Map<DateTime, int>.from(oldHabit.datasets);
        int oldCurrent = oldHabit.dataOfDay[_today]!['current']!;
        int oldTarget = oldHabit.dataOfDay[_today]!['target']!;
        if (oldTarget != _target) {
          final updatedDataOfDay =
              Map<DateTime, Map<String, int>>.from(widget.habit!.dataOfDay);

          // Update only the current day's data
          updatedDataOfDay[_today] = {
            'current': oldCurrent >= _target ? _target : oldCurrent,
            'target': _target,
          };
          widget.habit!.dataOfDay = updatedDataOfDay;
          final percentForToday = (10 * oldCurrent ~/ _target);
          updatedDatasets[_today] = percentForToday;
        }

        // Replace the old habit with updated values
        final updatedHabit = Habit.create(
          time: oldHabit.time,
          title: title,
          description: description,
          dataOfDay: oldHabit.dataOfDay,
          datasets: updatedDatasets,
          color: _selectedColor,
          iconData: _selectedIcon,
        );

        // Save the updated habit (replacing the old one in Hive)
        oldHabit.delete(); // Remove the old habit
        BaseWidget.of(context).dataStore.addHabit(habit: updatedHabit);

        Dialogs.showSnackBar(context, 'Habit updated successfully!');
      } else {
        // Create new habit
        final newHabit = Habit.create(
          time: DateTime.now(),
          title: title,
          description: description,
          dataOfDay: {
            _today: {'current': 0, 'target': _target}
          },
          datasets: {_today: 0},
          color: _selectedColor,
          iconData: _selectedIcon,
        );

        // Add new habit to Hive DB
        BaseWidget.of(context).dataStore.addHabit(habit: newHabit);

        Dialogs.showSnackBar(context, 'Habit created successfully!');
      }

      Navigator.pop(context);
    } catch (error, stackTrace) {
      log('Error in _createOrUpdateHabit: $error\n$stackTrace');
      Dialogs.showErrorSnackBar(
          context, 'An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const AppName(),
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: widget.isCalender
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Tap on dates to add / remove completions',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 0.75,
                          color: widget.habit!.color,
                        ),
                        color: widget.habit!.color.withOpacity(.03),
                      ),
                      child: CustomHeatMap(
                        habit: widget.habit!,
                        onClick: (date) {
                          setState(() {
                            int current =
                                widget.habit!.dataOfDay[date]?['current'] ?? 0;
                            int target = widget.habit!.dataOfDay[date]
                                    ?['target'] ??
                                widget.habit!.dataOfDay[_today]!['target']!;
                            if (current >= target) {
                              current = 0;
                              final percentForEachDay = <DateTime, int>{
                                date: 10 * current ~/ target,
                              };
                              widget.habit?.datasets
                                  .addEntries(percentForEachDay.entries);
                            } else {
                              current++;
                              final percentForEachDay = <DateTime, int>{
                                date: 10 * current ~/ target,
                              };
                              widget.habit?.datasets
                                  .addEntries(percentForEachDay.entries);
                            }
                            final updatedDataOfDay =
                                Map<DateTime, Map<String, int>>.from(
                                    widget.habit!.dataOfDay);
                            updatedDataOfDay[date] = {
                              'current': current,
                              'target': target,
                            };
                            widget.habit!.dataOfDay = updatedDataOfDay;
                            widget.habit?.save();
                          });
                        },
                        showText: true,
                        size: 25,
                        fontSize: 15,
                        borderRadius: 5,
                        margin: 5,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'More features coming soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : ListView(
                  children: [
                    const Text(
                      'What\'s your plan?',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _titleController,
                      hintText: 'Plan',
                      onFieldSubmitted: (value) {
                        _titleController.text = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Provide a brief description',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _descriptionController,
                      hintText: 'Add note',
                      isForDescription: true,
                      onFieldSubmitted: (value) {
                        _descriptionController.text = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Set target for each day',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _customTargetContainer(),
                    const SizedBox(height: 20),
                    const Text(
                      'Select color',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ColorPicker(
                        onColorChanged: (Color color) =>
                            setState(() => _selectedColor = color),
                        width: 30,
                        height: 30,
                        color: _selectedColor,
                        padding: const EdgeInsets.all(0),
                        enableShadesSelection: false,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select icon',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        // physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 rows
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: _icons.length,
                        itemBuilder: (context, index) {
                          final icon = _icons[index];
                          final bool isSelected =
                              _selectedIcon.toString() == icon.toString();

                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: Icon(
                              icon,
                              size: isSelected
                                  ? 23
                                  : 20, // Increase size if selected
                              color: isSelected
                                  ? _selectedColor
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              _titleController.clear();
                              _descriptionController.clear();
                              Navigator.of(context).pop();
                            },
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.red),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white)),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Cancel')),
                        ElevatedButton.icon(
                            onPressed: () => _createOrUpdateHabit(),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue),
                            icon: Icon(_isHabitAlreadyExist()
                                ? CupertinoIcons.refresh_thick
                                : CupertinoIcons.list_bullet_indent),
                            label: Text(
                                _isHabitAlreadyExist() ? 'Update' : 'Add')),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget _customTargetContainer() {
    return Container(
      // width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.bullseye, color: Colors.grey, size: 20),
                SizedBox(width: 12),
                Text('Target',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_target != 0) _target--;
                  });
                },
                tooltip: 'Remove',
                icon: const Icon(Icons.remove_rounded),
              ),
              Container(
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$_target',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _target++;
                  });
                },
                tooltip: 'Add',
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
