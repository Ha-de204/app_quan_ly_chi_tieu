import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String? message;
  final String frequency;
  final DateTime dateTime;
  final bool isEnabled;
  final String? note;

  Reminder({
    required this.id,
    required this.title,
    this.message,
    required this.frequency,
    required this.dateTime,
    this.isEnabled = true,
    this.note,
  });
}