import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enhanced_user_profile.dart';
import '../models/quiz_room.dart';
import '../providers/quiz_room_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

/// Screen for managing quiz rooms
class RoomManagementScreen extends StatefulWidget {
  final UserProfile userProfile;

  const RoomManagementScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  void _loadRooms() {
    if (widget.userProfile.id != null) {
      context.read<QuizRoomProvider>().loadRoomsForUser(widget.userProfile.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Rooms'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.userProfile.canManageClassrooms)
            IconButton(
              onPressed: () => _showCreateRoomDialog(context),
              icon: const Icon(Icons.add),
              tooltip: 'Create Room',
            ),
        ],
      ),
      body: Consumer<QuizRoomProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRooms,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userProfile.canManageClassrooms
                        ? 'Create your first room or join using an invite code'
                        : 'Join a room using an invite code',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.userProfile.canManageClassrooms) ...[
                        ElevatedButton.icon(
                          onPressed: () => _showCreateRoomDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Room'),
                        ),
                        const SizedBox(width: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: () => _showJoinRoomDialog(context),
                        icon: const Icon(Icons.login),
                        label: const Text('Join Room'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadRooms(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.rooms.length,
              itemBuilder: (context, index) {
                final room = provider.rooms[index];
                return _RoomCard(
                  room: room,
                  userProfile: widget.userProfile,
                  onTap: () => _navigateToRoom(room),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJoinRoomDialog(context),
        tooltip: 'Join Room',
        child: const Icon(Icons.login),
      ),
    );
  }

  void _navigateToRoom(QuizRoom room) {
    // Navigate to room details or quiz list
    // TODO: Implement navigation to room details screen
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateRoomDialog(userProfile: widget.userProfile),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _JoinRoomDialog(userProfile: widget.userProfile),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final QuizRoom room;
  final UserProfile userProfile;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isManager = room.createdBy == userProfile.id || 
                     room.teacherIds.contains(userProfile.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            room.name.isNotEmpty ? room.name[0].toUpperCase() : 'R',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${room.studentIds.length} students',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (room.subject != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.book,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.subject!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isManager)
              Icon(
                Icons.admin_panel_settings,
                color: Colors.orange[700],
                size: 20,
              ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}

class _CreateRoomDialog extends StatefulWidget {
  final UserProfile userProfile;

  const _CreateRoomDialog({required this.userProfile});

  @override
  State<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _maxStudentsController = TextEditingController(text: '100');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _gradeController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: _nameController,
                hintText: 'Room Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Room name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _descriptionController,
                hintText: 'Description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _subjectController,
                hintText: 'Subject (optional)',
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _gradeController,
                hintText: 'Grade (optional)',
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _maxStudentsController,
                hintText: 'Max Students',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Max students is required';
                  }
                  final number = int.tryParse(value.trim());
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer<QuizRoomProvider>(
          builder: (context, provider, child) {
            return CustomAnimatedButton(
              onPressed: provider.isLoading ? null : _createRoom,
              text: provider.isLoading ? 'Creating...' : 'Create',
            );
          },
        ),
      ],
    );
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<QuizRoomProvider>();
    final success = await provider.createRoom(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: widget.userProfile.id!,
      institutionId: widget.userProfile.institutionId ?? '',
      subject: _subjectController.text.trim().isEmpty 
          ? null 
          : _subjectController.text.trim(),
      grade: _gradeController.text.trim().isEmpty 
          ? null 
          : _gradeController.text.trim(),
      maxStudents: int.parse(_maxStudentsController.text.trim()),
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _JoinRoomDialog extends StatefulWidget {
  final UserProfile userProfile;

  const _JoinRoomDialog({required this.userProfile});

  @override
  State<_JoinRoomDialog> createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends State<_JoinRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Room'),
      content: Form(
        key: _formKey,
        child: CustomTextFormField(
          controller: _codeController,
          hintText: 'Enter Invite Code',
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Invite code is required';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer<QuizRoomProvider>(
          builder: (context, provider, child) {
            return CustomAnimatedButton(
              onPressed: provider.isLoading ? null : _joinRoom,
              text: provider.isLoading ? 'Joining...' : 'Join',
            );
          },
        ),
      ],
    );
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<QuizRoomProvider>();
    final success = await provider.joinRoom(
      inviteCode: _codeController.text.trim(),
      userId: widget.userProfile.id!,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined room!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
