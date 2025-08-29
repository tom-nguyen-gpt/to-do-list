# Flutter To-Do List Application

A comprehensive task management application built with Flutter and Firebase. This application allows users to create, manage, organize, and get reminded of their tasks, all while providing a seamless experience with support for both online and offline functionality.

![Flutter To-Do List App](https://img.shields.io/badge/Flutter-To--Do%20List-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Authentication](#authentication)
- [Task Management](#task-management)
- [Notifications](#notifications)
- [Themes](#themes)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

### Authentication
- Email/password registration and login
- Firebase authentication with local fallback
- Account recovery with password reset
- Success messages on registration
- Persistent login sessions

### Task Management
- Create, read, update, and delete tasks
- Task categorization
- Priority levels (Low, Medium, High, Urgent)
- Due dates and times
- Task completion tracking
- Task filtering (All, Completed, Pending, By Category)
- Task sorting (Due Date, Priority, Creation Time)
- Search functionality

### Notifications
- Task due date reminders (1 hour before deadline)
- Daily task summary at 9:00 AM
- Customizable notification settings
- Instant notifications on task completion

### User Interface
- Intuitive and clean design
- Dark and light theme support
- Responsive layout
- Loading states and error handling
- User-friendly forms with validation

## Architecture

The application follows a clean architecture approach with clear separation of concerns:

### Layers
- **Models**: Data structures representing the domain entities
- **Repositories**: Data source abstractions and implementations
- **Providers**: State management and business logic
- **Screens**: UI components and user interaction
- **Services**: Platform-specific functionality (notifications, etc.)
- **Widgets**: Reusable UI components

### State Management
- Provider pattern for reactive state management
- ChangeNotifier for UI updates
- Repository pattern for data access

## Technologies Used

- **Flutter**: UI framework for cross-platform mobile development
- **Dart**: Programming language
- **Firebase**: Backend services
  - Firebase Authentication: User management
  - Firestore: Cloud database
  - Firebase Realtime Database: Real-time data synchronization
- **Provider**: State management
- **SharedPreferences**: Local data persistence
- **Flutter Local Notifications**: Push notifications
- **Timezone**: Time zone handling for notifications

## Prerequisites

- Flutter SDK (Channel stable, v3.9.0 or higher)
- Dart SDK (v3.0.0 or higher)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- Firebase account

## Installation

1. Clone the repository:
```bash
git clone https://github.com/tom-nguyen-gpt/to-do-list.git
cd to-do-list
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Configuration

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Enable Firebase Authentication services:
   - Email/Password authentication
   - Anonymous authentication
5. Create Firestore database with appropriate security rules

### Environment Configuration

The app uses a hybrid authentication system that can work with or without Firebase. When Firebase is unavailable or encounters issues, it automatically falls back to local authentication.

## Usage

### Authentication

The application offers several authentication options:

1. **Email/Password Registration**:
   - Navigate to the Registration screen
   - Enter email and password
   - Submit the form
   - Receive confirmation of successful registration

2. **Email/Password Login**:
   - Enter registered email and password
   - Submit the login form

3. **Password Reset**:
   - Navigate to the Reset Password screen
   - Enter registered email
   - Follow the instructions sent to the email

### Task Management

1. **Creating a Task**:
   - Tap the "+" button on the home screen
   - Fill in the task details (title, description, due date, priority, category)
   - Save the task

2. **Viewing Tasks**:
   - All tasks are displayed on the home screen
   - Tap on a task to view its details

3. **Updating a Task**:
   - Navigate to the task details screen
   - Tap the edit button
   - Modify task details
   - Save the changes

4. **Completing a Task**:
   - Tap the checkbox next to a task to mark it as completed
   - Tap again to mark it as incomplete

5. **Deleting a Task**:
   - Swipe left on a task to delete it
   - Or navigate to task details and tap the delete button

6. **Filtering and Sorting**:
   - Use the filter button to filter tasks by status or category
   - Use the sort button to sort tasks by due date, priority, or creation time

7. **Searching**:
   - Use the search bar to find specific tasks by title or description

### Notification Settings

1. **Accessing Notification Settings**:
   - Navigate to the Settings screen
   - Tap on "Notifications"

2. **Enabling/Disabling Notifications**:
   - Toggle "Enable Notifications" to turn all notifications on/off

3. **Daily Reminder**:
   - Toggle "Daily Task Reminder" to receive a daily summary of pending tasks at 9:00 AM

## Project Structure

```
lib/
├── models/             # Data models
│   ├── task.dart
│   ├── task_list.dart
│   └── user_model.dart
│
├── providers/          # State management
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   └── theme_provider.dart
│
├── repositories/       # Data layer
│   ├── auth_repository.dart
│   ├── auth_repository_hybrid.dart
│   ├── auth_repository_local.dart
│   ├── task_repository.dart
│   └── task_repository_local.dart
│
├── screens/            # UI screens
│   ├── add_task_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── notification_settings_screen.dart
│   ├── register_screen.dart
│   ├── reset_password_screen.dart
│   ├── settings_screen.dart
│   └── task_detail_screen.dart
│
├── services/           # Application services
│   └── notification_service.dart
│
├── widgets/            # Reusable UI components
│   ├── task_item.dart
│   └── task_list.dart
│
└── main.dart           # Application entry point
```

## Roadmap

Upcoming features and improvements:

- [ ] Google and Facebook OAuth integration
- [ ] Collaboration features (shared tasks and lists)
- [ ] Offline synchronization for seamless offline usage
- [ ] Data export and backup functionality
- [ ] Custom themes and additional customization options
- [ ] Task attachments (images, files)
- [ ] Recurring tasks
- [ ] Sub-tasks support
- [ ] Task statistics and productivity insights
- [ ] Widget for home screen

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- Project Repository: [https://github.com/tom-nguyen-gpt/to-do-list](https://github.com/tom-nguyen-gpt/to-do-list)
- Developer: Tom Nguyen