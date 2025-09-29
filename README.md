# 📱 Iradon
![CI](https://github.com/saadyousafmalhi/flutter/actions/workflows/ci.yml/badge.svg)
[![Release](https://img.shields.io/github/v/release/saadyousafmalhi/flutter)](https://github.com/saadyousafmalhi/flutter/releases/latest)


# Iradon – Offline-First Task Manager in Flutter  

**Iradon** is a Flutter application designed as an **engineering case study in offline-first architecture**.  
It demonstrates how to combine **local persistence, write-ahead logging (WAL), and sync management** to deliver a seamless user experience in unreliable network conditions.  


👉 [Download the latest APK](https://github.com/saadyousafmalhi/flutter/releases/latest)


---


## ✨ Key Features  
- **Offline-First Design**  
  - Create, update, and delete tasks while fully offline.  
  - `LocalTaskStore` handles persistence across sessions.  

- **Write-Ahead Log (WAL)**  
  - All offline actions are recorded as `PendingOp` entries.  
  - WAL ensures durability and replay safety when connectivity is restored.  

- **SyncManager**  
  - Debounced, safe draining of WAL when going online.  
  - Handles retry logic and race conditions.  
  - Temp → Real ID replacement strategy to reconcile local vs. server IDs.  

- **Auth-Aware Sync**  
  - Integrated with `AuthProvider` for secure API calls.  
  - Only drains WAL when the user is authenticated.  

- **Resilient State Management**  
  - Provider-based architecture.  
  - UI remains consistent during offline/online transitions.  

---

## 📸 Screenshots


<p align="center">
  <img src="docs/assets/login.png" alt="Login" width="220"/>
  <img src="docs/assets/tasks.png" alt="Task List" width="220"/>
  <img src="docs/assets/darkmode.png" alt="Dark Mode" width="220"/>
</p>

---

## 🏗️ Architecture Overview  

```mermaid
flowchart TD
    UI[Flutter UI] --> Provider
    Provider --> LocalStore[LocalTaskStore]
    LocalStore --> WAL[Pending Operations (WAL)]
    WAL --> SyncManager
    SyncManager -->|Replay| API[TaskServiceHttp / Backend]
    AuthProvider --> SyncManager
```

---

## 📂 Project Structure  

```
lib/
  app/              # Navigation, tabs, theme
  models/           # Task, PendingOp
  providers/        # AuthProvider, TaskProvider, etc.
  services/         # LocalTaskStore, TaskServiceHttp, SyncManager
  screens/          # UI screens
```

---


## 📖 Why Offline-First Matters  

Many real-world apps must function in **low-connectivity environments** (mining, healthcare, field work).  
This project explores:  
- Applying **database WAL concepts** to client apps.  
- Ensuring **eventual consistency** in distributed systems.  
- Designing **resilient mobile UX** under flaky networks.  

---


## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (emulator or real device)

### Run locally
```bash
flutter pub get
flutter run
```
## 🏗️ Build Release

```bash
flutter build apk --release
flutter build appbundle --release
```

## 🔄 CI/CD

CI Workflow → Runs analyzer + tests on every push

CD Workflow → On main or when tagging v*, builds signed APK & AAB and attaches them to GitHub Releases

## 📜 License
Licensed under the [MIT License](./LICENSE) © 2025 Saad Yousaf.
