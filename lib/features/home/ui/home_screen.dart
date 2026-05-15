import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lumina/core/theme/app_theme.dart';
import 'package:lumina/core/widgets/buttons.dart';
import 'package:lumina/features/home/widgets/home_drawer.dart';
import 'package:lumina/features/notes/ui/note_page.dart';
import 'package:lumina/features/notes/widgets/note_controller.dart';
import 'package:lumina/main.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

enum SortOption { newest, oldest, alphabetical }

class HomeScreen extends StatefulWidget {
  final dynamic parentKey;
  final String? folderName;

  const HomeScreen({super.key, this.parentKey, this.folderName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  SortOption _currentSort = SortOption.newest;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<dynamic> _selectedKeys = {};
  bool get _isSelectionMode => _selectedKeys.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('notes');
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedKeys.clear()),
                  )
                : null,

            title: _isSelectionMode
                ? Text("${_selectedKeys.length} selected")
                : _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search notes...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  )
                : Text(
                    widget.folderName ?? 'Lumina',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

            actions: [
              if (_isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _confirmDelete,
                )
              else ...[
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) _searchQuery = "";
                      _searchController.clear();
                    });
                  },
                ),
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (SortOption result) {
                    setState(() => _currentSort = result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        const PopupMenuItem(
                          value: SortOption.newest,
                          child: Text('Newest First'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.oldest,
                          child: Text('Oldest First'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.alphabetical,
                          child: Text('Alphabetical'),
                        ),
                      ],
                ),
              ],
            ],
          ),
          drawer: const HomeDrawer(),
          body: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) return _buildEmptyState();

              List<MapEntry<dynamic, dynamic>> items = box
                  .toMap()
                  .entries
                  .toList();
              items = items.where((entry) {
                final parentId = entry.value['parentId'];
                return parentId == widget.parentKey;
              }).toList();

              if (_searchQuery.isNotEmpty) {
                items = items.where((entry) {
                  final String name = entry.value['name']
                      .toString()
                      .toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();
              }

              items.sort((a, b) {
                switch (_currentSort) {
                  case SortOption.alphabetical:
                    return a.value['name'].toString().compareTo(
                      b.value['name'].toString(),
                    );
                  case SortOption.oldest:
                    return a.value['timestamp'].toString().compareTo(
                      b.value['timestamp'].toString(),
                    );
                  case SortOption.newest:
                    return b.value['timestamp'].toString().compareTo(
                      a.value['timestamp'].toString(),
                    );
                }
              });

              if (items.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(child: Text("No results found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final key = items[index].key;
                  final note = items[index].value;
                  return _buildNoteItem(context, key, note, value);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateMenu(context),
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    dynamic key,
    dynamic note,
    ThemeMode currentMode,
  ) {
    final bool isFolder = note['isFolder'] ?? false;
    final bool isSelected = _selectedKeys.contains(key);
    final DateTime timestamp = DateTime.parse(note['timestamp']);
    final String formattedDate = DateFormat('MMM d, h:mm a').format(timestamp);

    final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        key: ValueKey("${key}_${theme.brightness}"),
        borderRadius: BorderRadius.circular(16),

        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.15)
            : colorScheme.surface,
        elevation: isDarkMode ? 0 : 2,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () => _toggleSelection(key),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(key);
            } else if (isFolder) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(parentKey: key, folderName: note['name']),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotePage(noteKey: key)),
              );
            }
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : (isDarkMode ? Colors.white10 : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFolder ? Icons.folder_rounded : Icons.description_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              title: Text(
                note['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                isFolder ? "Folder • $formattedDate" : "Note • $formattedDate",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              trailing: _isSelectionMode
                  ? null
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 100,
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            "No notes yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.create_new_folder_rounded,
              color: AppColors.primaryPurple,
            ),
            title: const Text('Create New Folder'),
            onTap: () {
              Navigator.pop(context);
              NoteController.showNameDialog(
                context,
                isFolder: true,
                parentId: widget.parentKey,
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.note_add_rounded,
              color: AppColors.primaryPurple,
            ),
            title: const Text('Create New Note'),
            onTap: () {
              Navigator.pop(context);
              NoteController.showNameDialog(
                context,
                isFolder: false,
                parentId: widget.parentKey,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _toggleSelection(dynamic key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  Future<void> _deleteRecursive(dynamic key) async {
    final box = Hive.box('notes');
    final item = box.get(key);

    if (item != null && item['isFolder'] == true) {
      final children = box
          .toMap()
          .entries
          .where((e) => e.value['parentId'] == key)
          .toList();
      for (var child in children) {
        await _deleteRecursive(child.key);
      }
    }
    await box.delete(key);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Delete Items?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete ${_selectedKeys.length} item(s)? This action cannot be undone and will delete all nested files.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: BigButton(
                      textColor: Theme.of(context).colorScheme.onSurface,
                      label: "Cancel",
                      color: Colors.transparent,
                      hasShadow: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BigButton(
                      textColor: Colors.white,
                      label: "Delete",
                      color: isDarkMode ?Colors.red.withValues(alpha: 0.5) :Colors.red,
                      shadowColor: Colors.red,
                      onTap: () async {
                        for (var key in _selectedKeys) {
                          await _deleteRecursive(key);
                        }
                        setState(() => _selectedKeys.clear());
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
