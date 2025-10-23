import 'package:flutter/material.dart';

class SetEntry {
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool isCompleted = false;
  final UniqueKey id = UniqueKey(); 
}
