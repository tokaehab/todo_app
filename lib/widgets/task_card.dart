import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_edit_screen.dart';
import '../providers/task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String userId;
  TaskCard(this.task, this.userId);
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed(TaskDetailScreen.routeName, arguments: task.id);
        },
        title: Text(
          task.title,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 16 * MediaQuery.of(context).textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${DateFormat.Hm().format(task.dueDate)}',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        leading: IconButton(
            icon: Icon(
                task.done ? Icons.check_box : Icons.check_box_outline_blank),
            color: Theme.of(context).primaryColorDark,
            onPressed: () async {
              try {
                await Provider.of<TasksProvider>(context)
                    .toggleDone(userId, task);
              } catch (error) {
                throw error;
              }
            }),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          onTap: () {
            Navigator.of(context)
                .pushNamed(TaskEditScreen.routeName, arguments: {
              'date': task.date,
              'taskId': task.id,
              'dueDate': task.dueDate,
            });
          },
          icon: Icons.edit,
          color: Theme.of(context).primaryColorDark,
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          onTap: () {
            try {
              Provider.of<TasksProvider>(context).removeTask(
                task.id,
                userId,
              );
            } catch (error) {
              throw error;
            }
          },
          icon: Icons.delete,
          color: Colors.red,
        ),
      ],
    );
  }
}
