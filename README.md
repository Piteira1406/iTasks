# iTasks - Task Management System

A modern Flutter application for task management using Kanban methodology with Firebase backend.

## 🎯 Features

- **Authentication System**: Secure Firebase Authentication with role-based access
- **Kanban Board**: Drag-and-drop task management with three columns (ToDo, Doing, Done)
- **User Management**: Manager and Developer roles with different permissions
- **Task Types**: Customizable task categories
- **Reports**: Generate CSV reports for completed and ongoing tasks
- **Real-time Updates**: Live synchronization across all connected clients
- **Dark/Light Theme**: Modern UI with glass morphism design

## 🏗️ Architecture

The project follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── models/         # Data models (User, Task, etc.)
│   ├── providers/      # Core state management (Auth, Theme)
│   ├── services/       # Business logic (Auth, Firestore, CSV, Logger)
│   ├── theme/          # App theming configuration
│   └── widgets/        # Reusable UI components
└── features/
    ├── auth/           # Authentication screens and logic
    ├── kanban/         # Kanban board functionality
    ├── management/     # User and task type management
    └── reports/        # Reporting functionality
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase project configured
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Piteira1406/iTasks.git
cd iTasks
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Ensure `firebase_options.dart` is properly configured
   - Set up Firestore Security Rules (see `firestore.rules`)

4. Run the application:
```bash
flutter run
```

## 🔐 Security

The application implements comprehensive Firestore Security Rules:

- **Authentication Required**: All operations require authenticated users
- **Role-Based Access**: Managers and Developers have different permissions
- **Data Isolation**: Users can only access their assigned data
- **Secure Task Updates**: Developers can only modify their own tasks
- **No Public Registration**: User accounts are created ONLY by Managers through the admin dashboard

### User Registration Flow

**Important**: There is NO public self-registration in this application.

- ❌ Users CANNOT create their own accounts
- ✅ Only authenticated Managers can create user accounts
- ✅ User creation is done through the User Management Dashboard
- ✅ Managers use `UserManagementProvider.createNewUser()` to register users

### Password Management

**Limitação do Firebase**: Não é possível alterar a password de outros utilizadores diretamente na aplicação.

#### Como Alterar Password de um Utilizador

1. **Utilizador faz logout** da aplicação
2. No ecrã de login, clica em **"Esqueci a password"**
3. Introduz o email da conta
4. **Firebase envia email** com link seguro de recuperação
5. Utilizador clica no link e **define nova password**
6. Faz login com a nova password

**Porquê esta limitação?**
- Firebase Authentication não permite que clientes alterem passwords de outros utilizadores
- Esta funcionalidade requer Admin SDK em Cloud Functions
- Cloud Functions necessitam do plano Blaze (pay-as-you-go)
- O projeto está no plano Spark (gratuito)

## 📦 Dependencies

### Core Dependencies
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Cloud database
- `firebase_auth` - Authentication
- `provider` - State management
- `google_fonts` - Typography

### Utility Dependencies
- `logger` - Structured logging
- `intl` - Internationalization and date formatting
- `csv` - CSV file generation
- `share_plus` - File sharing functionality

## 🎨 Design System

- **Font**: Inter (via Google Fonts)
- **Color Scheme**: 
  - Primary: Blue (#0A7AFF)
  - Light Theme: Soft Blue Background
  - Dark Theme: Midnight Blue Background
- **Components**: Glass morphism cards with blur effects

## 🔄 Business Rules

### Task Movement Rules (for Developers)
1. Can only move their own assigned tasks
2. Maximum 2 tasks in "Doing" status simultaneously
3. Cannot move tasks that are "Done"
4. Must follow task execution order (complete lower order tasks first)

### Manager Permissions
- Create and assign tasks
- **Manage users (create, update, delete)** - The ONLY way to add users to the system
- Access all reports
- Modify task types

### Developer Permissions
- View assigned tasks
- Move own tasks through workflow
- Update task status
- View own reports
- **Cannot register new users or modify other users**

## 📊 Data Models

### User Types
- **AppUser**: Base user information
- **Manager**: Manager-specific data (department)
- **Developer**: Developer-specific data (level, assigned manager)

### Task Model
```dart
Task {
  id, description, taskStatus, order, storyPoints,
  creationDate, previsionStartDate, previsionEndDate,
  realStartDate, realEndDate,
  idManager, idDeveloper, idTaskType
}
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is private and proprietary.

## 👨‍💻 Development Status

**Version**: 1.0.0+1  
**Status**: Active Development  
**Last Updated**: November 2025

## 🔧 Recent Improvements

- ✅ Implemented comprehensive Firestore Security Rules
- ✅ Added structured logging system
- ✅ Standardized code nomenclature to English
- ✅ Implemented missing FirestoreService methods
- ✅ Added rollback mechanism for failed operations
- ✅ Enhanced error handling across the application
- ✅ Fixed code duplication issues

## 📞 Contact

**Project Owner**: Piteira1406  
**Repository**: [iTasks](https://github.com/Piteira1406/iTasks)

---

Built with ❤️ using Flutter and Firebase
