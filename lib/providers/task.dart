import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  DateTime date;
  int notificationId;
  bool notify;
  bool done;
  DateTime dueDate;

  Task({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.date,
    @required this.dueDate,
    @required this.notificationId,
    @required this.notify,
    this.done = false,
  });
}
