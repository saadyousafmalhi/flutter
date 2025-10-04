// lib/models/sync_event.dart

import '../models/task.dart';

/// Base type for all events emitted by SyncManager.
abstract class SyncEvent {
  const SyncEvent();
}

class CreateCommitted extends SyncEvent {
  final int tempId; // your local temp/negative id
  final Task real; // server-returned row with real id
  const CreateCommitted(this.tempId, this.real);
}

class UpdateCommitted extends SyncEvent {
  final Task real;
  const UpdateCommitted(this.real);
}

class DeleteCommitted extends SyncEvent {
  final int id;
  const DeleteCommitted(this.id);
}
