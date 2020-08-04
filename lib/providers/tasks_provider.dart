import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './task.dart';
import '../screens/tasks_screen.dart';

class TasksProvider with ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  BuildContext context;

  InitializationSettings initializationSettings;
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payLoad) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {},
          child: Text("Okay"),
        ),
      ],
    );
  }

  void initializating(BuildContext ctx) async {
    context = ctx;
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void showNotification(_editedTask) async {
    await notification(_editedTask);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) print(payLoad);

    Navigator.of(context).pushNamed(TasksScreen.routeName);
  }

  Future<void> notification(Task _editedTask) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      'channelDescription',
      priority: Priority.High,
      importance: Importance.Max,
      ticker: 'test',
    );

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);

    await flutterLocalNotificationsPlugin.schedule(
        _editedTask.notificationId,
        'Task Reminder',
        '${_editedTask.title}',
        _editedTask.dueDate,
        notificationDetails);
  }

  List<Task> tasks = [];
  int nextTaskNotificationId = 0;

  Future<void> fetchTasks(String userId) async {
    var tasksList = await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('tasks')
        .getDocuments();
    tasks.clear();
    tasksList.documents.forEach((task) {
      nextTaskNotificationId =
          max(nextTaskNotificationId, task['notificationId'] + 1);
      tasks.add(
        Task(
          id: task.documentID,
          title: task['title'],
          notify: task['notify'],
          description: task['description'],
          notificationId: task['notificationId'],
          dueDate: DateTime.fromMillisecondsSinceEpoch(
              task['dueDate'].millisecondsSinceEpoch),
          date: DateTime.fromMillisecondsSinceEpoch(
              task['date'].millisecondsSinceEpoch),
          done: task['done'],
        ),
      );
    });
    notifyListeners();
  }

  List<Task> getOneDayTasks(DateTime dateTime) {
    List<Task> loadedTasks = getTasks(dateTime);
    loadedTasks.removeWhere((task) => (task.date.day != task.dueDate.day ||
        task.date.month != task.dueDate.month ||
        task.date.year != task.dueDate.year));
    return loadedTasks;
  }

  List<Task> getLongTasks(DateTime now) {
    List<Task> loadedTasks = [];
    tasks.forEach((task) {
      DateTime datee = task.date.add(Duration(days: 1));
      if (task.dueDate.isAfter(now) &&
          task.date.isBefore(now) &&
          (datee.isBefore(task.dueDate) ||
              (datee.day == task.dueDate.day &&
                  datee.month == task.dueDate.month &&
                  task.dueDate.year == datee.year))) {
        loadedTasks.add(task);
      }
    });
    return loadedTasks;
  }

  List<Task> getTasks(DateTime dateTime) {
    List<Task> loadedTasks = [];
    tasks.forEach((task) {
      if (task.date.day == dateTime.day &&
          task.date.month == dateTime.month &&
          task.date.year == dateTime.year) {
        loadedTasks.add(task);
      }
    });

    return loadedTasks;
  }

  Task findTaskById(String id) {
    Task task;
    tasks.forEach((tsk) {
      if (tsk.id == id) {
        task = tsk;
      }
    });
    return task;
  }

  Future<void> addTask(Task task, String userId) async {
    final doc = await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('tasks')
        .add({
      'title': task.title,
      'description': task.description,
      'done': task.done,
      'date': task.date,
      'notificationId': nextTaskNotificationId,
      'dueDate': task.dueDate,
      'notify': task.notify,
    });
    task.id = doc.documentID;
    tasks.add(task);
    nextTaskNotificationId++;
    notifyListeners();
  }

  Future<void> removeTask(String taskId, String userId) async {
    Task task = findTaskById(taskId);
    if (!task.done && task.notify && task.dueDate.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.cancel(task.notificationId);
    }
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(taskId)
        .delete();
    tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  int getSize() {
    return nextTaskNotificationId;
  }

  Future<void> toggleDone(String userId, Task task) async {
    try {
      await Firestore.instance
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(task.id)
          .setData({
        'done': !task.done,
      }, merge: true);

      tasks.forEach((tsk) {
        if (tsk.id == task.id) {
          task.done = !task.done;
        }
      });
      if (task.done && task.dueDate.isAfter(DateTime.now()) && task.notify) {
        try {
          await flutterLocalNotificationsPlugin.cancel(task.notificationId);
        } catch (error) {}
      } else if (!task.done &&
          task.dueDate.isAfter(DateTime.now()) &&
          task.notify) {
        showNotification(task);
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> editTask(String userId, String newTitle, String newDesc,
      DateTime newDate, DateTime newDueDate, Task task) async {
    try {
      await Firestore.instance
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(task.id)
          .setData({
        'title': newTitle,
        'Description': newDesc,
        'dueDate': newDueDate,
        'date': newDate,
        'notify': task.notify,
      }, merge: true);
      tasks.forEach((tsk) {
        if (tsk.id == task.id) {
          tsk.title = newTitle;
          tsk.description = newDesc;
          tsk.dueDate = newDueDate;
          tsk.date = newDate;
          tsk.notify = task.notify;
        }
      });
      if ((task.dueDate.isBefore(DateTime.now())) || !task.notify) {
        try {
          await flutterLocalNotificationsPlugin.cancel(task.notificationId);
        } catch (error) {}
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
