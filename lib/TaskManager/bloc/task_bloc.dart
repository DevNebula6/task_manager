import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/TaskManager/bloc/task_event.dart';
import 'package:task_manager/TaskManager/bloc/task_state.dart';
import 'package:task_manager/TaskManager/models/task.dart';
import 'package:task_manager/TaskManager/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);

    on<AddTask>(_onAddTask);

    on<UpdateTask>(_onUpdateTask);

    on<DeleteTask>(_onDeleteTask);

    on<ToggleTaskCompletion>(_onToggleTaskCompletion);

    on<FilterTasksByStatus>(_onFilterTasksByStatus);

    on<FilterTasksByPriority>(_onFilterTasksByPriority);

    on<FilterTasks>(_onFilterTasks); // Filter by both 

    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      await emit.forEach<List<Task>>(
        taskRepository.getTasks(),
        onData: (tasks) {
          return TaskLoaded(tasks: tasks);
        },
        onError: (error, stackTrace) {
          return TaskError('Failed to load tasks: $error');
        },
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.createTask(event.task);
      // Tasks will be automatically updated via the stream
    } catch (e) {
      if (!isClosed) {
        emit(TaskOperationFailure('Failed to add task: $e'));
      }
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      // Tasks will be automatically updated via the stream
    } catch (e) {
      if (!isClosed) {
        emit(TaskOperationFailure('Failed to update task: $e'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      // Tasks will be automatically updated via the stream
    } catch (e) {
      if (!isClosed) {
        emit(TaskOperationFailure('Failed to delete task: $e'));
      }
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.toggleTaskCompletion(event.taskId, event.isCompleted);
      // Tasks will be automatically updated via the stream
    } catch (e) {
      if (!isClosed) {
        emit(TaskOperationFailure('Failed to update task status: $e'));
      }
    }
  }

  Future<void> _onFilterTasksByStatus(
    FilterTasksByStatus event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final stream = event.isCompleted == null
          ? taskRepository.getTasks()
          : taskRepository.getTasksByStatus(event.isCompleted!);

      await emit.forEach<List<Task>>(
        stream,
        onData: (tasks) {
          return TaskLoaded(
            tasks: tasks,
            statusFilter: event.isCompleted,
          );
        },
        onError: (error, stackTrace) {
          return TaskError('Failed to filter tasks: $error');
        },
      );
    } catch (e) {
      emit(TaskError('Failed to filter tasks: $e'));
    }
  }

  Future<void> _onFilterTasksByPriority(
    FilterTasksByPriority event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final stream = event.priority == null
          ? taskRepository.getTasks()
          : taskRepository.getTasksByPriority(event.priority!);

      await emit.forEach<List<Task>>(
        stream,
        onData: (tasks) {
          return TaskLoaded(
            tasks: tasks,
            priorityFilter: event.priority,
          );
        },
        onError: (error, stackTrace) {
          return TaskError('Failed to filter tasks: $error');
        },
      );
    } catch (e) {
      emit(TaskError('Failed to filter tasks: $e'));
    }
  }

  Future<void> _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) async {
    if (event.isCompleted != null && event.priority != null) {
      // Filter by both
      emit(const TaskLoading());
      try {
        await emit.forEach<List<Task>>(
          taskRepository.getTasksByStatusAndPriority(
            event.isCompleted!,
            event.priority!,
          ),
          onData: (tasks) {
            return TaskLoaded(
              tasks: tasks,
              statusFilter: event.isCompleted,
              priorityFilter: event.priority,
            );
          },
          onError: (error, stackTrace) {
            return TaskError('Failed to filter tasks: $error');
          },
        );
      } catch (e) {
        emit(TaskError('Failed to filter tasks: $e'));
      }
    } else if (event.isCompleted != null) {
      add(FilterTasksByStatus(event.isCompleted));
    } else if (event.priority != null) {
      add(FilterTasksByPriority(event.priority));
    } else {
      add(const ClearFilters());
    }
  }

  Future<void> _onClearFilters(ClearFilters event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      await emit.forEach<List<Task>>(
        taskRepository.getTasks(),
        onData: (tasks) {
          return TaskLoaded(tasks: tasks);
        },
        onError: (error, stackTrace) {
          return TaskError('Failed to load tasks: $error');
        },
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }
}
