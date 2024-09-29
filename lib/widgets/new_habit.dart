import 'dart:developer';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/habit.dart';
import 'dialogs.dart';

class NewHabit extends StatefulWidget {
  const NewHabit({super.key, required this.habit});

  final Habit? habit;

  @override
  State<NewHabit> createState() => _NewHabitState();
}

class _NewHabitState extends State<NewHabit> {
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
            if (widget.habit!.current > _target) {
              widget.habit?.current = _target;
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
    return AlertDialog(
      title: const Text('Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Habit Name',
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inversePrimary)),
              )),
          const SizedBox(height: 10),
          TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inversePrimary)),
              )),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Target', style: TextStyle(fontSize: 17)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_target != 0) _target--;
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_target'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _target++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: _createOrUpdateHabit,
            child: Text(isHabitAlreadyExist() ? 'Update' : 'Add')),
      ],
    );
  }
}
