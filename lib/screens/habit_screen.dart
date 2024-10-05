import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/habit.dart';
import '../widgets/dialogs.dart';
import '../widgets/app_name.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key, required this.habit});

  final Habit? habit;

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _target = 0;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _descriptionController.text = widget.habit!.description;
      _target = widget.habit!.target;
    }
  }

  // if habit already exist return true, else false
  bool isHabitAlreadyExist() {
    if (widget.habit != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating habit
  dynamic _createOrUpdateHabit() {
    if (_titleController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter Habit name');
    } else if (_descriptionController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter description');
    } else if (_target == 0) {
      Dialogs.showErrorSnackBar(context, 'Set Target');
    } else {
      if (widget.habit != null) {
        try {
          widget.habit?.title = _titleController.text.trim();
          widget.habit?.description = _descriptionController.text.trim();
          if (widget.habit?.target != _target) {
            widget.habit?.target = _target;
            if (widget.habit!.current >= _target) {
              widget.habit?.current = _target;
              if (!widget.habit!.isTodayTaskDone) {
                widget.habit?.streak++;
              }
              widget.habit?.isTodayTaskDone = true;
            } else {
              if (widget.habit!.isTodayTaskDone) {
                widget.habit?.streak--;
              }
              widget.habit?.isTodayTaskDone = false;
            }
            final percentForEachDay = <DateTime, int>{
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ): 10 * widget.habit!.current ~/ widget.habit!.target,
            };
            widget.habit?.datasets.addEntries(percentForEachDay.entries);
          }
          widget.habit?.save(); // OR
          // var habit0 = widget.habit;
          // BaseWidget.of(context).dataStore.updateHabit(habit: habit0!);

          Dialogs.showSnackBar(context, 'Habit updated successfully!');
        } catch (error) {
          log(error.toString());
        }
      } else {
        var habit = Habit.create(
          time: DateTime.now(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          current: 0,
          target: _target,
          datasets: {
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ): (10 * 0) ~/ _target
          },
          isTodayTaskDone: false,
        );
        // We are adding this new habit to Hive DB using inherited widget
        BaseWidget.of(context).dataStore.addHabit(habit: habit);
        Dialogs.showSnackBar(context, 'Habit created successfully!');
      }
      Navigator.pop(context);
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
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: ListView(
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
              const SizedBox(height: 25),
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
              const SizedBox(height: 25),
              const Text(
                'Set target for each day',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              customTargetContainer(),
              const SizedBox(height: 20),
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
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white)),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel')),
                  ElevatedButton.icon(
                      onPressed: () => _createOrUpdateHabit(),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue),
                      icon: Icon(isHabitAlreadyExist()
                          ? CupertinoIcons.refresh_thick
                          : CupertinoIcons.list_bullet_indent),
                      label: Text(isHabitAlreadyExist() ? 'Update' : 'Add')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget customTargetContainer() {
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
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Icon(CupertinoIcons.flag_fill, color: Colors.grey),
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
                icon: const Icon(Icons.remove_rounded),
              ),
              Container(
                // margin: const EdgeInsets.only(right: 10),
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
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
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onFieldSubmitted,
    this.isForDescription = false,
  });

  final TextEditingController? controller;
  final Function(String)? onFieldSubmitted;

  final String hintText;
  final bool isForDescription;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: Colors.blue,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        prefixIcon: isForDescription
            ? const Icon(Icons.bookmark_border_rounded, color: Colors.grey)
            : const Icon(Icons.sports_gymnastics_rounded, color: Colors.grey),
        hintText: hintText,
        hintStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
