# iTasks 📋

> A modern task management system built with Flutter and Firebase, designed to streamline team workflows using Kanban methodology.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart)

---

## ✨ What is iTasks?

iTasks is a collaborative task management application that helps teams organize their work efficiently. Built with Flutter's cross-platform capabilities and powered by Firebase's real-time infrastructure, it provides a seamless experience across all devices.

Whether you're a manager coordinating multiple projects or a developer tracking your daily tasks, iTasks adapts to your workflow with intuitive Kanban boards and smart task organization.

---

## 🎯 Key Features

### 🔐 **Secure Authentication**
Role-based access control ensures team members see exactly what they need. Managers handle user creation and oversight, while developers focus on their assigned work.

### 📊 **Kanban Board**
Visualize your workflow with three customizable columns:
- **To Do** - Tasks waiting to be started
- **Doing** - Active work in progress (max 2 tasks per developer)
- **Done** - Completed work ready for review

Drag and drop tasks effortlessly to update their status in real-time.

### 👥 **User Management**
Managers can create and manage team members directly from the dashboard. No public registration means your workspace stays secure and controlled.

### 🏷️ **Task Categories**
Organize tasks by type (Bug, Feature, Enhancement, etc.) for better tracking and reporting.

### 📈 **Comprehensive Reports**
Export detailed CSV reports for completed and ongoing tasks. Perfect for sprint reviews, performance tracking, and project planning.

### 🌓 **Beautiful UI**
Modern glass morphism design with both light and dark themes. The interface adapts to your preferences while maintaining clarity and professionalism.

### ⚡ **Real-time Sync**
Changes made by one team member appear instantly for everyone. No refresh needed, no delays.

---

## 🏗️ Project Structure

The codebase follows clean architecture principles for maintainability and scalability:

```
lib/
├── core/                   # Shared foundation
│   ├── constants/         # Colors, dimensions, typography
│   ├── models/            # Data structures (User, Task, TaskType)
│   ├── providers/         # State management (Auth, Theme)
│   ├── services/          # Business logic layer
│   ├── theme/             # Design system configuration
│   └── widgets/           # Reusable UI components
│
└── features/              # Feature modules
    ├── auth/              # Login, password recovery
    ├── kanban/            # Board view, task cards, drag-and-drop
    ├── management/        # User & task type administration
    └── reports/           # CSV generation and exports
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:
- **Flutter SDK** 3.9.2 or higher ([Download here](https://flutter.dev/docs/get-started/install))
- A **Firebase project** with Firestore and Authentication enabled
- **Dart SDK** (comes with Flutter)
- Your favorite code editor (VS Code, Android Studio, IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Piteira1406/iTasks.git
   cd iTasks
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   ⚠️ **Important**: Firebase configuration files are NOT included in the repository for security reasons.
   
   **Option A: Using FlutterFire CLI (Recommended)**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```
   
   **Option B: Manual Configuration**
   
   a. Create `lib/firebase_options.dart`:
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```
   
   b. Get your Firebase config from [Firebase Console](https://console.firebase.google.com/):
   - Go to Project Settings > General
   - Add apps for each platform (Web, Android, iOS, etc.)
   - Copy the configuration values
   
   c. Create `android/app/google-services.json`:
   ```bash
   cp android/app/google-services.example.json android/app/google-services.json
   ```
   - Download from Firebase Console > Android App > google-services.json
   
   d. For iOS, add `ios/Runner/GoogleService-Info.plist`
   - Download from Firebase Console > iOS App > GoogleService-Info.plist
   
   e. Create `.firebaserc`:
   ```bash
   cp .firebaserc.example .firebaserc
   ```
   - Update with your Firebase project ID
   
   **Deploy Firestore Rules and Indexes:**
   ```bash
   # Deploy security rules
   firebase deploy --only firestore:rules
   
   # Deploy indexes
   firebase deploy --only firestore:indexes
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   flutter run -d chrome        # Web
   flutter run -d macos         # macOS
   flutter run -d windows       # Windows
   ```

---

## 🔐 Security & Authentication

iTasks implements enterprise-grade security practices:

### Authentication Flow
- **No public registration** - Users cannot create accounts themselves
- **Manager-controlled access** - Only authenticated Managers can add team members
- **Firebase Authentication** - Industry-standard security with email/password
- **Session management** - Automatic logout redirects maintain security

### Firestore Security Rules
Our security rules ensure:
- All operations require authentication
- Users access only their assigned data
- Managers have elevated permissions for administration
- Developers can modify only their own tasks
- Task creation is restricted to Managers

### Password Management

**For Users:**
1. Click "Forgot Password?" on the login screen
2. Enter your email address
3. Check your inbox for a secure reset link from Firebase
4. Click the link and set your new password
5. Log in with your new credentials

**Why can't Managers reset passwords?**
Firebase Authentication protects user passwords rigorously. Changing another user's password requires Admin SDK running in Cloud Functions, which needs Firebase's paid Blaze plan. iTasks runs on the free Spark plan to keep costs down while maintaining security.

---

## 📦 Technology Stack

### Core Framework
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Material Design 3** - Modern UI components

### Backend & Database
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Core** - Platform initialization

### State Management
- **Provider** - Simple, scalable state management

### UI/UX
- **Google Fonts** - Inter font family
- **Custom Theme** - Glass morphism design system
- **Responsive Layout** - Adapts to all screen sizes

### Utilities
- **Logger** - Structured debugging and error tracking
- **Intl** - Date formatting and internationalization
- **CSV** - Export functionality
- **Share Plus** - Cross-platform file sharing

---

## 🎨 Design Philosophy

iTasks embraces modern design trends while prioritizing usability:

- **Glass Morphism** - Translucent cards with blur effects create depth
- **Inter Font Family** - Clean, readable typography
- **Color Palette**
  - Primary Blue: `#0A7AFF` - Trust and productivity
  - Accent Purple: For highlights and special actions
  - Adaptive backgrounds that respect user theme preferences
- **Consistent Spacing** - Rhythm in layout creates visual harmony
- **Icon-First Actions** - Intuitive visual cues reduce learning curve

---

## 📋 Business Rules

### For Developers

**Task Movement Restrictions:**
- You can only move tasks assigned to you
- Maximum 2 tasks in "Doing" simultaneously (prevents context switching)
- Completed tasks ("Done") are locked from further changes
- Lower-order tasks must be completed before moving to higher-order ones

**Workflow:**
1. View your assigned tasks in To Do
2. Drag a task to Doing when you start work
3. Move to Done when complete
4. Repeat (respecting the 2-task limit)
**Workflow:**
1. View your assigned tasks in To Do
2. Drag a task to Doing when you start work
3. Move to Done when complete
4. Repeat (respecting the 2-task limit)

### For Managers

**Superpowers:**
- Create and assign tasks to developers
- Manage the team roster (create, update, deactivate users)
- Configure task types and categories
- Access comprehensive reports across all projects
- Monitor team workload and progress

**User Creation Process:**
1. Navigate to User Management
2. Fill in user details (name, email, role)
3. System creates Firebase Auth account
4. Manager is logged out automatically (security measure)
5. Manager logs back in to continue work
6. New user receives credentials and can log in

---

## 💾 Data Models

### Users
```dart
// Base user information
AppUser {
  int id
  String uid              // Firebase Auth ID
  String name
  String username         // Unique identifier
  String email
  String type            // "Manager" or "Developer"
}

// Manager-specific data
Manager {
  int idManager
  String department
  String uid
}

// Developer-specific data
Developer {
  int idDeveloper
  String level           // Junior, Mid, Senior
  int idManager          // Assigned manager
  String uid
}
```

### Tasks
```dart
Task {
  int id
  String description
  String taskStatus          // "ToDo", "Doing", "Done"
  int order                  // Execution priority
  int storyPoints           // Complexity estimate
  
  Timestamp creationDate
  Timestamp? previsionStartDate
  Timestamp? previsionEndDate
  Timestamp? realStartDate
  Timestamp? realEndDate
  
  int idManager             // Creator
  int? idDeveloper          // Assignee
  int idTaskType            // Category
}
```

### Task Types
```dart
TaskType {
  int id
  String name              // "Bug", "Feature", "Enhancement"
}
```

---

## 🧪 Testing & Quality

### Run Tests
```bash
flutter test                    # Unit and widget tests
flutter test --coverage         # With coverage report
```

### Code Analysis
```bash
flutter analyze                 # Static analysis
dart format lib/               # Auto-format code
```

### Performance Profiling
```bash
flutter run --profile          # Profile mode
flutter run --release          # Release build
```

---

## 📱 Platform Support

iTasks runs everywhere Flutter does:

| Platform | Status | Notes |
|----------|--------|-------|
| 🤖 Android | ✅ Fully Supported | Android 5.0+ |
| 🍎 iOS | ✅ Fully Supported | iOS 12.0+ |
| 🌐 Web | ✅ Fully Supported | Modern browsers |
| 💻 macOS | ✅ Fully Supported | macOS 10.14+ |
| 🪟 Windows | ✅ Fully Supported | Windows 10+ |
| 🐧 Linux | ✅ Fully Supported | Ubuntu 20.04+ |

---

## 🤝 Contributing

We welcome contributions! Here's how to get involved:

1. **Fork** the repository
2. **Create a branch** for your feature
   ```bash
   git checkout -b feature/amazing-improvement
   ```
3. **Make your changes** following our code style
4. **Test thoroughly** - ensure nothing breaks
5. **Commit** with clear messages
   ```bash
   git commit -m "Add: amazing improvement that does X"
   ```
6. **Push** to your fork
   ```bash
   git push origin feature/amazing-improvement
   ```
7. **Open a Pull Request** with a detailed description

### Code Style Guidelines
- Follow Dart's official style guide
- Use meaningful variable names
- Comment complex logic
- Keep functions small and focused
- Write tests for new features

---

## 📝 Changelog

### Version 1.0.0 (December 2024)

**🎉 Initial Release**
- Complete authentication system with role-based access
- Kanban board with drag-and-drop functionality
- User management dashboard for Managers
- Task type configuration
- CSV report generation
- Dark and light theme support
- Real-time data synchronization
- Comprehensive security rules

**🔒 Security Enhancements**
- Implemented granular Firestore Security Rules
- Added structured logging system
- Enhanced error handling across all features
- Rollback mechanism for failed operations

**🛠️ Code Quality**
- Standardized nomenclature to English
- Eliminated code duplication
- Added comprehensive documentation
- Improved architecture with clear separation of concerns

---

## 🐛 Known Issues & Limitations

### Password Reset
- Managers cannot reset user passwords directly
- Users must use "Forgot Password" flow
- Requires Firebase Blaze plan for Admin SDK (future enhancement)

### Session Management
- Creating a new user logs out the Manager (Firebase Auth limitation)
- Simple workaround: Manager logs back in immediately

### Offline Support
- Limited offline capabilities (Firebase default behavior)
- Full offline mode planned for future release

---

## 🗺️ Roadmap

### Upcoming Features
- [ ] Push notifications for task assignments
- [ ] Comments and attachments on tasks
- [ ] Time tracking and burndown charts
- [ ] Custom task workflows beyond Kanban
- [ ] Mobile app polish and optimization
- [ ] Team performance analytics
- [ ] Integration with external tools (Slack, Jira, etc.)

### Performance Improvements
- [ ] Image optimization and lazy loading
- [ ] Pagination for large task lists
- [ ] Advanced caching strategies
- [ ] Offline-first architecture

---

## 📞 Support & Community

### Getting Help
- 📧 **Email**: Open an issue on GitHub
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/Piteira1406/iTasks/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/Piteira1406/iTasks/discussions)

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

## 📄 License

This project is private and proprietary. All rights reserved.

For licensing inquiries, please contact the repository owner.

---

## 🙏 Acknowledgments

Built with passion using amazing open-source technologies:
- **Flutter Team** - For the incredible framework
- **Firebase Team** - For the robust backend infrastructure
- **Provider Package** - For elegant state management
- **Google Fonts** - For beautiful typography
- **The Dart Community** - For continuous support and innovation

---

## 👨‍💻 About the Project

**Version**: 1.0.0  
**Status**: 🟢 Active Development  
**Last Updated**: December 2024  
**Maintained by**: [Piteira1406](https://github.com/Piteira1406)

---

<div align="center">

**Built with ❤️ using Flutter and Firebase**

[⭐ Star this repo](https://github.com/Piteira1406/iTasks) • [🐛 Report Bug](https://github.com/Piteira1406/iTasks/issues) • [💡 Request Feature](https://github.com/Piteira1406/iTasks/issues)

</div>
