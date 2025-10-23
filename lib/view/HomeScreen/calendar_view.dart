import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/Auth/auth_service.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/TaskManager/bloc/task_bloc.dart';
import 'package:task_manager/TaskManager/bloc/task_event.dart';
import 'package:task_manager/TaskManager/bloc/task_state.dart';
import 'package:task_manager/TaskManager/models/task.dart';
import 'package:task_manager/TaskManager/repositories/task_repository.dart';
import 'package:task_manager/utilities/Dialog/generic_dialog.dart';
import 'package:task_manager/view/Tasks/add_task_screen.dart';
import 'package:task_manager/view/Tasks/edit_task_screen.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return BlocProvider(
      create: (context) {
        return TaskBloc(
          taskRepository: TaskRepository(userId: user.id),
        )..add(const LoadTasks());
      },
      child: const _CalendarViewContent(),
    );
  }
}

class _CalendarViewContent extends StatefulWidget {
  const _CalendarViewContent();

  @override
  State<_CalendarViewContent> createState() => _CalendarViewContentState();
}

class _CalendarViewContentState extends State<_CalendarViewContent> {
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedMonth = DateTime.now();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              _buildAppBar(),
              
              const SizedBox(height: 16),
              
              // Month Selector
              _buildMonthSelector(),
              
              const SizedBox(height: 16),
              
              // Calendar Timeline List
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading || state is TaskInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.lightGreenAccent,
                        ),
                      );
                    } else if (state is TaskLoaded) {
                      return _buildCalendarTimeline(state);
                    } else if (state is TaskError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TaskBloc>().add(const LoadTasks());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: Text('Unknown state'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.list_rounded, false, () {
                  Navigator.of(context).pop();
                }),
                const SizedBox(width: 100), // Space for FAB
                _buildNavItem(Icons.calendar_today_rounded, true, () {}),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final taskBloc = context.read<TaskBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: taskBloc,
                child: const AddTaskScreen(),
              ),
            ),
          );
        },
        backgroundColor: Colors.indigo.shade600,
        elevation: 8,
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade400,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          // Back or menu icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Colors.lightGreenAccent, size: 24),
          ),
          const SizedBox(width: 12),
          
          // Title
          const Expanded(
            child: Text(
              'Calendar View',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreenAccent,
              ),
            ),
          ),
          
          // Logout icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () async {
                final shouldLogout = await showGenericDialog<bool>(
                  context: context,
                  title: 'Logout',
                  content: 'Are you sure you want to logout?',
                  options: () => {
                    'Cancel': false,
                    'Logout': true,
                  },
                );
                
                if (shouldLogout == true && context.mounted) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.logout, color: Colors.lightGreenAccent, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
            },
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
            },
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTimeline(TaskLoaded state) {
    // Get all days in the selected month
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    final days = <DateTime>[];
    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }

    // Group tasks by date
    final tasksByDate = <String, List<Task>>{};
    for (var task in state.tasks) {
      final dateKey = DateFormat('yyyy-MM-dd').format(task.dueDate);
      tasksByDate.putIfAbsent(dateKey, () => []).add(task);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final dateKey = DateFormat('yyyy-MM-dd').format(day);
        final tasksForDay = tasksByDate[dateKey] ?? [];
        
        return _buildDaySection(day, tasksForDay);
      },
    );
  }

  Widget _buildDaySection(DateTime date, List<Task> tasks) {
    final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isToday 
            ? Border.all(color: Colors.lightGreenAccent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday 
                  ? Colors.lightGreenAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Day and Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday 
                            ? Colors.lightGreenAccent 
                            : Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM').format(date),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isToday 
                            ? Colors.lightGreenAccent 
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Task count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tasks.isEmpty 
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.indigo.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No tasks scheduled',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...tasks.map((task) => _buildCalendarTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildCalendarTaskItem(Task task) {
    final priorityColor = task.priority == TaskPriority.high
        ? Colors.deepOrange
        : task.priority == TaskPriority.medium
            ? Colors.blue
            : Colors.greenAccent;

    return InkWell(
      onTap: () {
        final taskBloc = context.read<TaskBloc>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: taskBloc,
              child: EditTaskScreen(task: task),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  context.read<TaskBloc>().add(
                    ToggleTaskCompletion(
                      taskId: task.id,
                      isCompleted: value ?? false,
                    ),
                  );
                },
                activeColor: Colors.green,
                checkColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Priority Indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted 
                          ? Colors.grey.shade400 
                          : Colors.white,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('HH:mm').format(task.dueDate),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
