import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/core/constants/app_colors.dart';
import '../../../core/utils/todo_list.dart';
import '../provider/todo_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fabController;
  late AnimationController _listController;
  late AnimationController _headerController;
  late AnimationController _pulseController;

  late Animation<double> _fabScaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isAddingTask = false;
  String _selectedFilter = 'All';
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _headerController.forward();
    _listController.forward();

    _focusNode.addListener(() {
      setState(() {
        _isAddingTask = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _listController.dispose();
    _headerController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredTodos(TodoProvider provider) {
    var todos = provider.todos;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      todos = todos
          .where((todo) =>
              todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'Active':
        return todos.where((todo) => !todo.isDone).toList();
      case 'Completed':
        return todos.where((todo) => todo.isDone).toList();
      default:
        return todos;
    }
  }

  void _addTask(TodoProvider provider) {
    if (_controller.text.trim().isNotEmpty) {
      provider.addTask(_controller.text.trim());
      _controller.clear();
      _focusNode.unfocus();

      // Success animation
      _fabController.forward().then((_) {
        _fabController.reverse();
      });

      // Haptic feedback
      // HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final filteredTodos = _getFilteredTodos(todoProvider);
    final completedCount =
        todoProvider.todos.where((todo) => todo.isDone).length;
    final totalCount = todoProvider.todos.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF1A1D2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Animated background particles
          ...List.generate(
              20,
              (index) => AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Positioned(
                        left:
                            (index * 47.0) % MediaQuery.of(context).size.width,
                        top:
                            (index * 83.0) % MediaQuery.of(context).size.height,
                        child: Opacity(
                          opacity: 0.1 * _pulseAnimation.value,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  )),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date and greeting
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FadeTransition(
                                  opacity: _headerController,
                                  child: Text(
                                    _getGreeting(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.3, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _headerController,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: const Text(
                                    'Thanh Bao',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action buttons
                          Row(
                            children: [
                              _buildActionButton(
                                icon: _showSearch ? Icons.close : Icons.search,
                                onTap: () {
                                  setState(() {
                                    _showSearch = !_showSearch;
                                    if (!_showSearch) {
                                      _searchQuery = '';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              _buildActionButton(
                                icon: Icons.settings,
                                onTap: () => _showSettingsBottomSheet(
                                    context, todoProvider),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Search bar
                      if (_showSearch)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.white.withOpacity(0.7)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                      // Stats card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Progress circle
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress == 1.0
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 20),

                            // Stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    totalCount == 0
                                        ? 'No tasks yet'
                                        : progress == 1.0
                                            ? 'All done! 🎉'
                                            : '$completedCount of $totalCount completed',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    totalCount == 0
                                        ? 'Add your first task to get started'
                                        : progress == 1.0
                                            ? 'Great job! Take a break.'
                                            : 'You\'re doing great! Keep going.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter tabs
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Active', 'Completed'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      final count = filter == 'All'
                          ? totalCount
                          : filter == 'Active'
                              ? totalCount - completedCount
                              : completedCount;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.purple.shade400
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Task list
                Expanded(
                  child: filteredTodos.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final task = filteredTodos[index];
                            final originalIndex =
                                todoProvider.todos.indexOf(task);

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _listController,
                                curve: Interval(
                                  index * 0.1,
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              )),
                              child: FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(
                                    index * 0.1,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                )),
                                child: ModernTodoItem(
                                  task: task,
                                  index: index,
                                  onChanged: (_) =>
                                      todoProvider.toggleDone(originalIndex),
                                  onDelete: () => _showDeleteConfirmation(
                                    context,
                                    todoProvider,
                                    originalIndex,
                                  ),
                                  onEdit: () => _showEditDialog(
                                    context,
                                    todoProvider,
                                    originalIndex,
                                    task.title,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Add task input (floating)
          if (_isAddingTask)
            Positioned(
              bottom: 140,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.6)),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addTask(todoProvider),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addTask(todoProvider),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Modern FAB
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton.extended(
            onPressed: () {
              if (_isAddingTask) {
                _addTask(todoProvider);
              } else {
                _focusNode.requestFocus();
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
            label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAddingTask ? Icons.send_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAddingTask ? 'Add Task' : 'New Task',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.purple.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyStateTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) return 'No results found';
    switch (_selectedFilter) {
      case 'Active':
        return 'No active tasks';
      case 'Completed':
        return 'No completed tasks';
      default:
        return 'Ready to focus?';
    }
  }

  String _getEmptyStateSubtitle() {
    if (_searchQuery.isNotEmpty) return 'Try adjusting your search terms';
    switch (_selectedFilter) {
      case 'Active':
        return 'All your tasks are completed!\nTime to add new ones.';
      case 'Completed':
        return 'Complete some tasks to\nsee them here.';
      default:
        return 'Add your first task and\nstart being productive!';
    }
  }

  // Settings, dialogs, etc. methods remain the same as before
  void _showSettingsBottomSheet(BuildContext context, TodoProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1D2E), Color(0xFF16213E)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsItem(
              icon: Icons.delete_sweep,
              title: 'Clear Completed',
              subtitle: 'Remove all completed tasks',
              onTap: () {
                provider.clearCompleted();
                Navigator.pop(context);
              },
            ),
            _buildSettingsItem(
              icon: Icons.delete_forever,
              title: 'Clear All Tasks',
              subtitle: 'Remove all tasks permanently',
              onTap: () {
                Navigator.pop(context);
                _showClearAllConfirmation(context, provider);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, TodoProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              provider.removeTask(index);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TodoProvider provider, int index,
      String currentTitle) {
    final editController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter task title',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                provider.editTask(index, editController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context, TodoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Tasks',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Modern Todo Item Widget
class ModernTodoItem extends StatefulWidget {
  final dynamic task;
  final int index;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ModernTodoItem({
    super.key,
    required this.task,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ModernTodoItem> createState() => _ModernTodoItemState();
}

class _ModernTodoItemState extends State<ModernTodoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.task.isDone;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => widget.onChanged(!isDone),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isDone ? Colors.green : Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  color: isDone ? Colors.green : Colors.transparent,
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onEdit,
              child: const Icon(Icons.edit, color: Colors.white70, size: 18),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onDelete,
              child:
                  const Icon(Icons.delete, color: Colors.redAccent, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
