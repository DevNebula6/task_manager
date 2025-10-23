import 'package:equatable/equatable.dart';
import 'package:task_manager/TaskManager/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

// Loaded state with tasks
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final bool? statusFilter;
  final TaskPriority? priorityFilter;

  const TaskLoaded({
    required this.tasks,
    this.statusFilter,
    this.priorityFilter,
  });

  // Get tasks grouped by time period
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((task) {
      return task.dueDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(tomorrow);
    }).toList();
  }

  List<Task> get tomorrowTasks {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final dayAfterTomorrow = tomorrow.add(const Duration(days: 1));

    return tasks.where((task) {
      return task.dueDate.isAfter(tomorrow.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(dayAfterTomorrow);
    }).toList();
  }

  List<Task> get thisWeekTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayAfterTomorrow = today.add(const Duration(days: 2));
    final endOfWeek = today.add(const Duration(days: 7));

    return tasks.where((task) {
      return task.dueDate.isAfter(dayAfterTomorrow.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(endOfWeek);
    }).toList();
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return tasks.where((task) {
      return task.dueDate.isBefore(now) && !task.isCompleted;
    }).toList();
  }

  List<Task> get completedTasks {
    return tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> get incompleteTasks {
    return tasks.where((task) => !task.isCompleted).toList();
  }

  @override
  List<Object?> get props => [tasks, statusFilter, priorityFilter];

  TaskLoaded copyWith({
    List<Task>? tasks,
    bool? statusFilter,
    TaskPriority? priorityFilter,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      priorityFilter: clearPriorityFilter ? null : (priorityFilter ?? this.priorityFilter),
    );
  }
}

// Error state
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation success state
class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation failure state
class TaskOperationFailure extends TaskState {
  final String message;

  const TaskOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
