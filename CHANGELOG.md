# Changelog

All notable changes to this project will be documented in this file.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [v1.0.0+17] - 2025-10-04

### Added
- **SyncEvent stream** in `SyncManager` (`CreateCommitted`, `UpdateCommitted`, `DeleteCommitted`).
- `TaskProvider` subscribes to SyncEvents → instant UI updates, no manual refresh needed.
- Overlay logic during `load(force:true)` keeps optimistic items visible when refreshing.
- MultiProvider wiring improved (`AuthProvider → SyncManager → TaskProvider`).

### Fixed
- Resolved issue where optimistic tasks would disappear briefly when refreshing after going back online.

---

## [v1.0.0+15] - 2025-09-29

### Added
- Initial WAL (Write-Ahead Log) implementation for offline task creation.
- `SyncManager` with exponential backoff and retry.
- `LocalTaskStore` for persistence between sessions.

---

