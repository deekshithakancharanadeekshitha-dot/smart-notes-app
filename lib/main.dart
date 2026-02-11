import 'package:flutter/material.dart';

void main() {
  runApp(SmartNotesApp());
}

class SmartNotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          background: Colors.black,
          primary: Colors.tealAccent,
          secondary: Colors.teal,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: NotesHome(),
    );
  }
}

class Note {
  final String id;
  String title;
  String body;
  DateTime date;
  int colorIndex;
  bool isLocked;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.colorIndex,
    this.isLocked = false,
  });
}

class NotesHome extends StatefulWidget {
  @override
  _NotesHomeState createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final List<Note> _notes = [];
  final List<Note> _deletedNotes = [];
  final List<Color> cardColors = [
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.pink.shade100,
  ];

  String _searchQuery = "";
  bool _isGridView = false;
  bool _isEditMode = false;

  void _addNote(String title, String body, bool isLocked) {
    setState(() {
      _notes.add(
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: body,
          date: DateTime.now(),
          colorIndex: _notes.length % cardColors.length,
          isLocked: isLocked,
        ),
      );
    });
  }

  void _editNote(Note note, String newTitle, String newBody) {
    setState(() {
      note.title = newTitle;
      note.body = newBody;
      note.date = DateTime.now();
    });
  }

  void _deleteNote(Note note) {
    setState(() {
      _notes.remove(note);
      _deletedNotes.add(note);
    });
  }

  void _restoreNote(Note note) {
    setState(() {
      _deletedNotes.remove(note);
      _notes.add(note);
    });
  }

  void _openAddNoteScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddNoteScreen(
          onSave: (title, body, isLocked) {
            _addNote(title, body, isLocked);
          },
        ),
      ),
    );
  }

  void _openEditNoteScreen(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditNoteScreen(
          note: note,
          onSave: (title, body) {
            _editNote(note, title, body);
          },
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, {bool locked = false, bool deleted = false}) {
    final filtered = notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.body.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("No notes found!", style: TextStyle(color: Colors.white70)),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final note = filtered[index];
          return _buildNoteCard(note, locked, deleted);
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final note = filtered[index];
          return _buildNoteCard(note, locked, deleted);
        },
      );
    }
  }

  Widget _buildNoteCard(Note note, bool locked, bool deleted) {
    return Card(
      color: cardColors[note.colorIndex % cardColors.length],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        title: Text(
          note.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locked ? "🔒 Locked" : note.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 6),
            Text(
              "${note.date.toLocal()}".split('.')[0],
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: deleted
            ? IconButton(
                icon: Icon(Icons.restore, color: Colors.black),
                onPressed: () => _restoreNote(note),
              )
            : IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () => _deleteNote(note),
              ),
        onTap: _isEditMode && !deleted ? () => _openEditNoteScreen(note) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Smart Notes", style: TextStyle(color: Colors.tealAccent)),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  if (value == 'Grid View') _isGridView = true;
                  if (value == 'List View') _isGridView = false;
                  if (value == 'Edit Mode') _isEditMode = !_isEditMode;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'Grid View', child: Text('Grid View')),
                PopupMenuItem(value: 'List View', child: Text('List View')),
                PopupMenuItem(value: 'Edit Mode', child: Text(_isEditMode ? 'Disable Edit' : 'Enable Edit')),
              ],
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.tealAccent,
            tabs: [
              Tab(text: "All Notes"),
              Tab(text: "Locked"),
              Tab(text: "Deleted"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildNotesList(_notes),
                  _buildNotesList(_notes.where((n) => n.isLocked).toList(), locked: true),
                  _buildNotesList(_deletedNotes, deleted: true),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddNoteScreen,
          backgroundColor: Colors.teal,
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  final Function(String, String, bool) onSave;

  AddNoteScreen({required this.onSave});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLocked = false;

  void _saveNote() {
    if (_titleController.text.isNotEmpty || _bodyController.text.isNotEmpty) {
      widget.onSave(_titleController.text, _bodyController.text, _isLocked);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: Text("Save", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Body",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isLocked,
                  onChanged: (value) {
                    setState(() {
                      _isLocked = value ?? false;
                    });
                  },
                ),
                Text("Lock this note", style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  final Note note;
  final Function(String, String) onSave;

  EditNoteScreen({required this.note, required this.onSave});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _bodyController = TextEditingController(text: widget.note.body);
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty || _bodyController.text.isNotEmpty) {
      widget.onSave(_titleController.text, _bodyController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Note"),
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: Text("Save", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Body",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
