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
import 'package:task_manager/utilities/Dialog/show_message.dart';
import 'package:task_manager/view/HomeScreen/calendar_view.dart';
import 'package:task_manager/view/Tasks/add_task_screen.dart';
import 'package:task_manager/view/Tasks/edit_task_screen.dart';
import 'package:task_manager/view/Tasks/widgets/task_item_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    // Provide TaskBloc with the actual user ID
    return BlocProvider(
      create: (context) {
        return TaskBloc(
          taskRepository: TaskRepository(userId: user.id),
        )..add(const LoadTasks());
      },
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  TaskPriority? _selectedPriorityFilter;
  bool? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
              // App Bar with Grid Icon, Search, and Logout
              _buildAppBar(),
              
              const SizedBox(height: 16),
              
              // Date and My Tasks Header
              _buildHeader(),
              
              const SizedBox(height: 16),
              
              // Filters
              _buildFilters(),
              
              const SizedBox(height: 16),
              
              // Task List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      if (state is TaskLoading || state is TaskInitial) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is TaskLoaded) {
                        return _buildTaskList(state);
                      } else if (state is TaskError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(fontSize: 16),
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:Colors.indigo.shade900,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.list_rounded, true),
                const SizedBox(width: 100), // Space for FAB
                _buildNavItem(Icons.calendar_today_rounded, false),
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
        child: const Icon(Icons.add_rounded, size: 32,color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo.shade600 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isSelected ? null : () {
          if (icon == Icons.calendar_today_rounded) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CalendarView(),
              ),
            );
          }
        },
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
          // Grid icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Colors.lightGreenAccent, size: 24),
          ),
          const SizedBox(width: 12),
          
          // Search bar
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.lightGreenAccent, fontFamily: 'Poppins', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.lightGreenAccent.withOpacity(0.6),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.lightGreenAccent.withOpacity(0.7), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.lightGreenAccent.withOpacity(0.7), size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today, ${DateFormat('d MMM').format(DateTime.now())}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'My Tasks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.lightGreenAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: _selectedPriorityFilter == null && _selectedStatusFilter == null,
            onTap: () {
              setState(() {
                _selectedPriorityFilter = null;
                _selectedStatusFilter = null;
              });
              context.read<TaskBloc>().add(const ClearFilters());
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'High',
            color: Colors.deepOrange,
            isSelected: _selectedPriorityFilter == TaskPriority.high,
            onTap: () {
              setState(() {
                _selectedPriorityFilter = TaskPriority.high;
                _selectedStatusFilter = null;
              });
              context.read<TaskBloc>().add(FilterTasksByPriority(TaskPriority.high));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Medium',
            color: Colors.blue,
            isSelected: _selectedPriorityFilter == TaskPriority.medium,
            onTap: () {
              setState(() {
                _selectedPriorityFilter = TaskPriority.medium;
                _selectedStatusFilter = null;
              });
              context.read<TaskBloc>().add(FilterTasksByPriority(TaskPriority.medium));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Low',
            color: Colors.greenAccent,
            isSelected: _selectedPriorityFilter == TaskPriority.low,
            onTap: () {
              setState(() {
                _selectedPriorityFilter = TaskPriority.low;
                _selectedStatusFilter = null;
              });
              context.read<TaskBloc>().add(FilterTasksByPriority(TaskPriority.low));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Completed',
            color: Colors.green,
            isSelected: _selectedStatusFilter == true,
            onTap: () {
              setState(() {
                _selectedStatusFilter = true;
                _selectedPriorityFilter = null;
              });
              context.read<TaskBloc>().add(const FilterTasksByStatus(true));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Colors.white)
              : Colors.white.withOpacity(0.2),
          borderRadius: isSelected
              ? BorderRadius.circular(20)
              : BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isSelected
                ? (color != null ? Colors.white : Colors.indigo.shade700)
                : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskLoaded state) {
    // Filter tasks based on search query
    final filteredTasks = _searchQuery.isEmpty
        ? state.tasks
        : state.tasks.where((task) {
            return task.title.toLowerCase().contains(_searchQuery) ||
                   task.description.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No tasks yet' : 'No tasks found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Tap the + button to create your first task'
                  : 'Try searching with different keywords',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Get categorized tasks from filtered list
    final todayTasks = filteredTasks.where((task) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      return task.dueDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(tomorrow);
    }).toList();

    final tomorrowTasks = filteredTasks.where((task) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dayAfterTomorrow = tomorrow.add(const Duration(days: 1));
      return task.dueDate.isAfter(tomorrow.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(dayAfterTomorrow);
    }).toList();

    final thisWeekTasks = filteredTasks.where((task) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dayAfterTomorrow = today.add(const Duration(days: 2));
      final endOfWeek = today.add(const Duration(days: 7));
      return task.dueDate.isAfter(dayAfterTomorrow.subtract(const Duration(seconds: 1))) &&
          task.dueDate.isBefore(endOfWeek);
    }).toList();

    final overdueTasks = filteredTasks.where((task) {
      final now = DateTime.now();
      return task.dueDate.isBefore(now) && !task.isCompleted;
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        // Overdue tasks
        if (overdueTasks.isNotEmpty) ...[
          _buildSectionHeader('Overdue', overdueTasks.length, Colors.red),
          ...overdueTasks.map((task) => _buildTaskItem(task)),
          const SizedBox(height: 16),
        ],
        
        // Today tasks
        if (todayTasks.isNotEmpty) ...[
          _buildSectionHeader('Today', todayTasks.length, Colors.blue),
          ...todayTasks.map((task) => _buildTaskItem(task)),
          const SizedBox(height: 16),
        ],
        
        // Tomorrow tasks
        if (tomorrowTasks.isNotEmpty) ...[
          _buildSectionHeader('Tomorrow', tomorrowTasks.length, Colors.purple),
          ...tomorrowTasks.map((task) => _buildTaskItem(task)),
          const SizedBox(height: 16),
        ],
        
        // This week tasks
        if (thisWeekTasks.isNotEmpty) ...[
          _buildSectionHeader('This Week', thisWeekTasks.length, Colors.blue),
          ...thisWeekTasks.map((task) => _buildTaskItem(task)),
        ],
        
        // If filtered and tasks don't fit in categories above
        if (_selectedPriorityFilter != null || _selectedStatusFilter != null || _searchQuery.isNotEmpty) ...[
          if (todayTasks.isEmpty && tomorrowTasks.isEmpty && thisWeekTasks.isEmpty && overdueTasks.isEmpty) ...[
            _buildSectionHeader('Filtered Tasks', filteredTasks.length, Colors.grey),
            ...filteredTasks.map((task) => _buildTaskItem(task)),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return TaskItemWidget(
      task: task,
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
      onToggle: (value) {
        final willBeCompleted = value ?? false;
        
        context.read<TaskBloc>().add(
          ToggleTaskCompletion(
            taskId: task.id,
            isCompleted: willBeCompleted,
          ),
        );
        
        // Show helpful message if task will disappear due to "Completed" filter
        if (_selectedStatusFilter == true && !willBeCompleted) {
          showMessage(
            message: 'Task marked as incomplete! (Hidden by "Completed" filter)',
            context: context,
            backgroundColor: Colors.indigo.shade700,
            icon: Icons.info_outline,
            iconColor: Colors.lightGreenAccent,
            action: SnackBarAction(
              label: 'Show All',
              textColor: Colors.lightGreenAccent,
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = null;
                  _selectedPriorityFilter = null;
                });
                context.read<TaskBloc>().add(const ClearFilters());
              },
            ),
          );
        }
      },
      onDelete: () {
        context.read<TaskBloc>().add(DeleteTask(task.id));
        showMessage(
          message: 'Task deleted',
          context: context,
          backgroundColor: Colors.red.shade600,
          icon: Icons.delete_outline,
        );
      },
    );
  }
}

