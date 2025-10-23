import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/TaskManager/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  TaskRepository({
    FirebaseFirestore? firestore,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get reference to user's tasks collection
  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(userId).collection('tasks');

  // Create a new task
  Future<String> createTask(Task task) async {
    try {
      final docRef = await _tasksCollection.add(task.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(
            task.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get a single task by ID
  Future<Task?> getTask(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        return Task.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Stream all tasks for the user
  Stream<List<Task>> getTasks() {
    return _tasksCollection
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Stream tasks filtered by completion status
  Stream<List<Task>> getTasksByStatus(bool isCompleted) {
    return _tasksCollection
        .where('isCompleted', isEqualTo: isCompleted)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Stream tasks filtered by priority
  Stream<List<Task>> getTasksByPriority(TaskPriority priority) {
    return _tasksCollection
        .where('priority', isEqualTo: priority.name)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Stream tasks filtered by both status and priority
  Stream<List<Task>> getTasksByStatusAndPriority(
    bool isCompleted,
    TaskPriority priority,
  ) {
    return _tasksCollection
        .where('isCompleted', isEqualTo: isCompleted)
        .where('priority', isEqualTo: priority.name)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Stream tasks due today
  Stream<List<Task>> getTasksDueToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasksCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Stream tasks due tomorrow
  Stream<List<Task>> getTasksDueTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final endOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);

    return _tasksCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Stream tasks due this week
  Stream<List<Task>> getTasksDueThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _tasksCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  // Batch delete multiple tasks
  Future<void> deleteTasks(List<String> taskIds) async {
    try {
      final batch = _firestore.batch();
      for (final taskId in taskIds) {
        batch.delete(_tasksCollection.doc(taskId));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete tasks: $e');
    }
  }
}
