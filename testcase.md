# To-Do List Application Test Cases

This document outlines comprehensive test cases for the To-Do List application. These test cases cover all major features and functionality to ensure the application works as expected across different scenarios.

## Table of Contents
1. [Authentication Tests](#authentication-tests)
2. [Task Management Tests](#task-management-tests)
3. [Notification Tests](#notification-tests)
4. [UI/UX Tests](#uiux-tests)
5. [Data Persistence Tests](#data-persistence-tests)
6. [Performance Tests](#performance-tests)
7. [Security Tests](#security-tests)
8. [Offline Functionality Tests](#offline-functionality-tests)
9. [Integration Tests](#integration-tests)

---

## Authentication Tests

### User Registration
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| AUTH-001 | Register with valid email and password | 1. Navigate to registration screen<br>2. Enter valid email<br>3. Enter valid password and confirm password<br>4. Submit form | User account is created successfully and user is redirected to home screen | To Test |
| AUTH-002 | Register with invalid email format | 1. Navigate to registration screen<br>2. Enter invalid email (e.g., "test")<br>3. Enter valid password<br>4. Submit form | Error message displayed indicating invalid email format | To Test |
| AUTH-003 | Register with weak password | 1. Navigate to registration screen<br>2. Enter valid email<br>3. Enter password with less than 6 characters<br>4. Submit form | Error message displayed indicating password requirements | To Test |
| AUTH-004 | Register with mismatched passwords | 1. Navigate to registration screen<br>2. Enter valid email<br>3. Enter different passwords in password and confirm password fields<br>4. Submit form | Error message displayed indicating passwords do not match | To Test |
| AUTH-005 | Register with already used email | 1. Navigate to registration screen<br>2. Enter email that already exists in the system<br>3. Enter valid password<br>4. Submit form | Error message displayed indicating email already in use | To Test |
| AUTH-006 | Registration success message | 1. Complete valid registration process | Success message displayed after successful registration | To Test |
| AUTH-007 | Register with Firebase offline | 1. Turn off internet connection<br>2. Navigate to registration screen<br>3. Complete registration form<br>4. Submit form | Registration completes successfully using local fallback | To Test |

### User Login
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| AUTH-008 | Login with valid credentials | 1. Navigate to login screen<br>2. Enter valid email and password<br>3. Submit form | User is logged in and directed to home screen | To Test |
| AUTH-009 | Login with invalid email | 1. Navigate to login screen<br>2. Enter non-existent email and password<br>3. Submit form | Error message displayed indicating invalid credentials | To Test |
| AUTH-010 | Login with incorrect password | 1. Navigate to login screen<br>2. Enter valid email but incorrect password<br>3. Submit form | Error message displayed indicating invalid credentials | To Test |
| AUTH-011 | Login with empty fields | 1. Navigate to login screen<br>2. Submit form without entering any data | Form validation errors displayed for empty fields | To Test |
| AUTH-012 | Login persistence after app restart | 1. Login successfully<br>2. Close app<br>3. Reopen app | User remains logged in | To Test |
| AUTH-013 | Login with Firebase offline | 1. Turn off internet connection<br>2. Navigate to login screen<br>3. Enter valid credentials<br>4. Submit form | Login completes successfully using local fallback | To Test |

### Password Reset
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| AUTH-014 | Password reset with valid email | 1. Navigate to password reset screen<br>2. Enter registered email<br>3. Submit form | Success message displayed indicating reset instructions sent | To Test |
| AUTH-015 | Password reset with unregistered email | 1. Navigate to password reset screen<br>2. Enter unregistered email<br>3. Submit form | Error message displayed indicating email not found | To Test |

### Logout
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| AUTH-016 | User logout | 1. Login successfully<br>2. Navigate to settings<br>3. Tap logout option<br>4. Confirm logout | User is logged out and redirected to login screen | To Test |
| AUTH-017 | Session termination after logout | 1. Logout successfully<br>2. Attempt to access protected screens without logging in | User is redirected to login screen | To Test |

---

## Task Management Tests

### Task Creation
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-001 | Create task with all fields | 1. Navigate to add task screen<br>2. Fill all fields (title, description, due date, priority, category)<br>3. Save task | Task is created and appears in the task list | To Test |
| TASK-002 | Create task with only required fields | 1. Navigate to add task screen<br>2. Fill only title field<br>3. Save task | Task is created with default values for other fields | To Test |
| TASK-003 | Create task with invalid data | 1. Navigate to add task screen<br>2. Submit form without filling title<br>3. Save task | Validation error displayed for required fields | To Test |
| TASK-004 | Task creation date accuracy | 1. Create new task<br>2. Check the creation date of the task | Creation date should match current date/time | To Test |

### Task Viewing
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-005 | View task list | 1. Login to application<br>2. Navigate to home screen | All created tasks for the user are displayed | To Test |
| TASK-006 | View task details | 1. Navigate to home screen<br>2. Tap on a specific task | Task details screen displays all task information | To Test |
| TASK-007 | View tasks with different priorities | 1. Create tasks with different priorities<br>2. Navigate to home screen | Tasks display with appropriate priority indicators | To Test |
| TASK-008 | View tasks with due dates | 1. Create tasks with due dates<br>2. Navigate to home screen | Tasks display with due date information | To Test |

### Task Updating
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-009 | Update task title | 1. Navigate to task details<br>2. Edit the task title<br>3. Save changes | Task title is updated in the task list and details | To Test |
| TASK-010 | Update task description | 1. Navigate to task details<br>2. Edit the task description<br>3. Save changes | Task description is updated | To Test |
| TASK-011 | Update task due date | 1. Navigate to task details<br>2. Change the due date<br>3. Save changes | Task due date is updated and any related notifications are rescheduled | To Test |
| TASK-012 | Update task priority | 1. Navigate to task details<br>2. Change the priority<br>3. Save changes | Task priority is updated and displayed correctly | To Test |
| TASK-013 | Update task category | 1. Navigate to task details<br>2. Change the category<br>3. Save changes | Task category is updated | To Test |

### Task Completion
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-014 | Mark task as complete | 1. Navigate to home screen<br>2. Tap the checkbox on a task | Task is marked as completed and visually indicated | To Test |
| TASK-015 | Mark completed task as incomplete | 1. Navigate to home screen<br>2. Find a completed task<br>3. Tap the checkbox again | Task is marked as incomplete | To Test |
| TASK-016 | Completion timestamp | 1. Mark a task as complete<br>2. View task details | Completion date is set to current date/time | To Test |
| TASK-017 | Completion notification | 1. Mark a task as complete | Completion notification is displayed (if enabled) | To Test |

### Task Deletion
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-018 | Delete task via swipe | 1. Navigate to home screen<br>2. Swipe left on a task<br>3. Tap delete | Task is removed from the list | To Test |
| TASK-019 | Delete task via details | 1. Navigate to task details<br>2. Tap delete button<br>3. Confirm deletion | Task is deleted and user is returned to task list | To Test |
| TASK-020 | Delete task notification removal | 1. Create task with due date<br>2. Delete the task | Any scheduled notifications for the task are cancelled | To Test |

### Task Filtering and Sorting
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-021 | Filter tasks by completion status | 1. Navigate to home screen<br>2. Apply filter for completed/incomplete tasks | Only tasks matching filter criteria are displayed | To Test |
| TASK-022 | Filter tasks by category | 1. Navigate to home screen<br>2. Apply filter for specific category | Only tasks in selected category are displayed | To Test |
| TASK-023 | Sort tasks by due date | 1. Navigate to home screen<br>2. Apply sorting by due date | Tasks are displayed in order of due dates | To Test |
| TASK-024 | Sort tasks by priority | 1. Navigate to home screen<br>2. Apply sorting by priority | Tasks are displayed in order of priority | To Test |
| TASK-025 | Sort tasks by creation time | 1. Navigate to home screen<br>2. Apply sorting by creation time | Tasks are displayed in order of creation time | To Test |
| TASK-026 | Filter and sort combination | 1. Apply both filter and sort options | Tasks are filtered and sorted according to criteria | To Test |

### Task Searching
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| TASK-027 | Search tasks by title | 1. Navigate to home screen<br>2. Enter search term matching task title | Only tasks with matching titles are displayed | To Test |
| TASK-028 | Search tasks by description | 1. Navigate to home screen<br>2. Enter search term matching task description | Only tasks with matching descriptions are displayed | To Test |
| TASK-029 | Search with no results | 1. Enter search term with no matching tasks | Empty state is displayed with appropriate message | To Test |
| TASK-030 | Clear search | 1. Enter search term<br>2. Clear search field | All tasks are displayed again | To Test |

---

## Notification Tests

### Notification Settings
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| NOTIF-001 | Enable notifications | 1. Navigate to notification settings<br>2. Toggle notifications on | Notification preference is saved | To Test |
| NOTIF-002 | Disable notifications | 1. Navigate to notification settings<br>2. Toggle notifications off | Notification preference is saved and all notifications are cancelled | To Test |
| NOTIF-003 | Enable daily reminder | 1. Navigate to notification settings<br>2. Toggle daily reminder on | Daily reminder preference is saved and reminder is scheduled | To Test |
| NOTIF-004 | Disable daily reminder | 1. Navigate to notification settings<br>2. Toggle daily reminder off | Daily reminder preference is saved and reminder is cancelled | To Test |
| NOTIF-005 | Settings persistence | 1. Change notification settings<br>2. Close and reopen app | Notification settings persist | To Test |

### Task Reminders
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| NOTIF-006 | Due date reminder scheduling | 1. Create task with future due date<br>2. Ensure notifications are enabled | Reminder is scheduled for 1 hour before due date | To Test |
| NOTIF-007 | Due date reminder display | 1. Wait for task reminder time | Notification is displayed at scheduled time | To Test |
| NOTIF-008 | Due date reminder cancellation | 1. Create task with due date<br>2. Delete task | Scheduled reminder is cancelled | To Test |
| NOTIF-009 | Due date reminder rescheduling | 1. Create task with due date<br>2. Update due date | Reminder is rescheduled based on new due date | To Test |

### Daily Reminders
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| NOTIF-010 | Daily reminder scheduling | 1. Enable daily reminders<br>2. Wait until scheduled time (9:00 AM) | Daily reminder notification is displayed | To Test |
| NOTIF-011 | Daily reminder content | 1. Create pending tasks<br>2. Wait for daily reminder | Reminder mentions pending tasks | To Test |

### Completion Notifications
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| NOTIF-012 | Task completion notification | 1. Create task<br>2. Mark task as completed | Completion notification is displayed | To Test |
| NOTIF-013 | Disabled notifications | 1. Disable notifications<br>2. Complete a task | No notification is displayed | To Test |

---

## UI/UX Tests

### Theme
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| UI-001 | Toggle dark mode | 1. Navigate to settings<br>2. Toggle dark mode on | App theme changes to dark mode | To Test |
| UI-002 | Toggle light mode | 1. Navigate to settings with dark mode on<br>2. Toggle dark mode off | App theme changes to light mode | To Test |
| UI-003 | Theme persistence | 1. Set theme preference<br>2. Close and reopen app | Selected theme persists | To Test |
| UI-004 | System theme integration | 1. Set app to follow system theme<br>2. Change system theme | App theme updates accordingly | To Test |

### Responsiveness
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| UI-005 | Landscape orientation | 1. Rotate device to landscape | UI adapts to landscape orientation | To Test |
| UI-006 | Portrait orientation | 1. Rotate device to portrait | UI adapts to portrait orientation | To Test |
| UI-007 | Different screen sizes | 1. Test app on different device sizes | UI scales appropriately | To Test |

### Loading States
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| UI-008 | Loading indicator during authentication | 1. Submit login form<br>2. Observe UI during process | Loading indicator displayed during authentication | To Test |
| UI-009 | Loading indicator during task operations | 1. Create/update/delete task<br>2. Observe UI during process | Loading indicator displayed during operation | To Test |
| UI-010 | Loading indicator during data fetch | 1. Open app and login<br>2. Observe UI during initial data load | Loading indicator displayed during data fetch | To Test |

### Error States
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| UI-011 | Form validation errors | 1. Submit form with invalid data | Error messages displayed for invalid fields | To Test |
| UI-012 | Network error handling | 1. Turn off internet connection<br>2. Perform operation requiring network | Appropriate error message displayed | To Test |
| UI-013 | Empty state handling | 1. Delete all tasks<br>2. View task list | Empty state message/UI displayed | To Test |

---

## Data Persistence Tests

### Local Storage
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| DATA-001 | User credentials persistence | 1. Register/login<br>2. Close app<br>3. Reopen app | User remains logged in | To Test |
| DATA-002 | Task data persistence | 1. Create tasks<br>2. Close app<br>3. Reopen app | All tasks are still present | To Test |
| DATA-003 | Settings persistence | 1. Change settings (theme, notifications)<br>2. Close app<br>3. Reopen app | Settings remain as configured | To Test |

### Cloud Synchronization
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| DATA-004 | Task synchronization with Firebase | 1. Create task with internet connection<br>2. Verify task is saved to Firebase | Task exists in Firebase database | To Test |
| DATA-005 | Multi-device synchronization | 1. Login on two devices<br>2. Create task on first device<br>3. Check second device | Task appears on second device | To Test |
| DATA-006 | Conflict resolution | 1. Update same task on two devices while offline<br>2. Connect both to internet | Changes are merged according to conflict resolution policy | To Test |

---

## Performance Tests

### Load Time
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| PERF-001 | App startup time | 1. Launch app<br>2. Measure time until interactive | App loads within acceptable time (< 3 seconds) | To Test |
| PERF-002 | Task list loading time | 1. Navigate to task list with many tasks<br>2. Measure loading time | Task list loads quickly (< 2 seconds) | To Test |

### Resource Usage
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| PERF-003 | Memory usage | 1. Use app with many tasks<br>2. Monitor memory usage | Memory usage remains within acceptable limits | To Test |
| PERF-004 | CPU usage | 1. Perform various operations<br>2. Monitor CPU usage | CPU usage spikes only briefly during intensive operations | To Test |
| PERF-005 | Battery impact | 1. Use app for extended period<br>2. Monitor battery usage | Battery consumption is reasonable | To Test |

---

## Security Tests

### Authentication Security
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| SEC-001 | Password security | 1. Register with password<br>2. Check if password is stored securely | Password is hashed, not stored as plaintext | To Test |
| SEC-002 | Session handling | 1. Login<br>2. Close app without logout<br>3. Reopen app | Session is maintained securely | To Test |
| SEC-003 | Authentication token expiry | 1. Login<br>2. Wait for token expiry<br>3. Attempt to use app | User is prompted to re-authenticate | To Test |

### Data Security
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| SEC-004 | Data encryption | 1. Check local storage<br>2. Examine transmitted data | Sensitive data is encrypted | To Test |
| SEC-005 | Access control | 1. Login as user A<br>2. Attempt to access user B's tasks | Access is denied | To Test |

---

## Offline Functionality Tests

### Offline Creation
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| OFF-001 | Create task offline | 1. Turn off internet connection<br>2. Create new task<br>3. Save task | Task is saved locally | To Test |
| OFF-002 | Sync offline created task | 1. Create task offline<br>2. Turn on internet connection | Task is synchronized to cloud | To Test |

### Offline Editing
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| OFF-003 | Update task offline | 1. Turn off internet connection<br>2. Update existing task<br>3. Save changes | Changes are saved locally | To Test |
| OFF-004 | Sync offline updated task | 1. Update task offline<br>2. Turn on internet connection | Changes are synchronized to cloud | To Test |

### Offline Deletion
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| OFF-005 | Delete task offline | 1. Turn off internet connection<br>2. Delete task | Task is marked for deletion locally | To Test |
| OFF-006 | Sync offline deletion | 1. Delete task offline<br>2. Turn on internet connection | Deletion is synchronized to cloud | To Test |

---

## Integration Tests

### System Integration
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| INT-001 | Authentication with task management | 1. Login<br>2. Create task<br>3. Logout<br>4. Login as different user | First user's task is not visible to second user | To Test |
| INT-002 | Notification with task management | 1. Create task with due date<br>2. Update due date | Notification is rescheduled accordingly | To Test |
| INT-003 | Theme with all screens | 1. Change theme<br>2. Navigate through all screens | Theme is consistent across all screens | To Test |

### End-to-End Workflow
| Test ID | Test Case Description | Test Steps | Expected Result | Status |
|---------|------------------------|------------|----------------|--------|
| INT-004 | Complete user workflow | 1. Register<br>2. Create task<br>3. Receive notification<br>4. Mark task complete<br>5. Logout | All steps complete successfully | To Test |
| INT-005 | Multiple user workflow | 1. Use app with multiple users simultaneously<br>2. Each user performs various operations | All operations complete correctly with proper data isolation | To Test |

---

## Test Execution Guidelines

### Test Environment
- Android devices: Minimum API level 21 (Android 5.0 Lollipop) and above
- iOS devices: iOS 11.0 and above
- Flutter version: Latest stable release
- Firebase: Project configured with Authentication and Firestore

### Test Reporting
For each test case:
1. Record the test date and tester name
2. Document the actual result
3. Mark the test status (Pass/Fail)
4. If failed, include:
   - Screenshot or screen recording
   - Error messages
   - Steps to reproduce consistently
   - Device information (model, OS version)

### Bug Severity Levels
- **Critical**: App crashes, data loss, security breach, complete feature failure
- **High**: Major function impaired but workaround possible
- **Medium**: Function works but with noticeable problems
- **Low**: Minor visual issues, unclear messages, slight inconvenience

---

## Automated Tests

In addition to manual testing, the following automated tests should be implemented:

1. **Unit Tests**:
   - Authentication services
   - Task repository methods
   - Business logic in providers
   - Utility functions

2. **Widget Tests**:
   - Task list rendering
   - Form validations
   - Navigation flow
   - UI state management

3. **Integration Tests**:
   - Complete authentication flow
   - Task creation to completion flow
   - Notification interaction