import 'package:equatable/equatable.dart';
import 'package:task_manager/TaskManager/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

// Load all tasks
class LoadTasks extends TaskEvent {
  const LoadTasks();
}

// Add a new task
class AddTask extends TaskEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

// Update an existing task
class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

// Delete a task
class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Toggle task completion
class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletion({
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [taskId, isCompleted];
}

// Filter tasks by status
class FilterTasksByStatus extends TaskEvent {
  final bool? isCompleted; // null means show all

  const FilterTasksByStatus(this.isCompleted);

  @override
  List<Object?> get props => [isCompleted];
}

// Filter tasks by priority
class FilterTasksByPriority extends TaskEvent {
  final TaskPriority? priority; // null means show all

  const FilterTasksByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

// Filter tasks by both status and priority
class FilterTasks extends TaskEvent {
  final bool? isCompleted;
  final TaskPriority? priority;

  const FilterTasks({
    this.isCompleted,
    this.priority,
  });

  @override
  List<Object?> get props => [isCompleted, priority];
}

// Clear all filters
class ClearFilters extends TaskEvent {
  const ClearFilters();
}
