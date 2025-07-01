# PrayerTracker Product Requirements Document (PRD)

## 1. Overview

PrayerTracker is a mobile application designed to help users track their daily prayers and manage any missed prayers (debt).

## 2. Data Persistence and Syncing Strategy

To provide a seamless and private user experience, PrayerTracker will utilize Apple's native data persistence and cloud synchronization frameworks.

### 2.1. Core Technology

- **SwiftData:** The application will use SwiftData as its core persistence layer. SwiftData is a modern, Swift-native framework that simplifies data modeling and management. Its tight integration with SwiftUI ensures a reactive and efficient UI.

- **CloudKit:** To enable data synchronization across a user's devices (iPhone, iPad, Mac, etc.), the app will integrate with CloudKit. 

### 2.2. Implementation Details

- **Private Database:** All user data is considered personal and sensitive. Therefore, the application will exclusively use the user's **private CloudKit database**. This ensures that prayer logs and other personal information are stored securely within the user's own iCloud account and are not accessible to the developer or any other party.

- **Automatic Syncing:** SwiftData's native CloudKit integration will be leveraged for automatic and transparent data syncing. By configuring the `ModelContainer` with the app's CloudKit container identifier (`iCloud.com.PrayerTracker`), the framework will handle the complexities of syncing data between the local device and the cloud.

### 2.3. Rationale (Why this approach?)

1.  **Privacy First:** Using the private CloudKit database is a best practice that respects user privacy for sensitive data.
2.  **Seamless User Experience:** Users expect their data to be available across all their devices. This architecture provides that functionality out-of-the-box with no extra configuration required from the user.
3.  **Modern & Maintainable:** Building with SwiftData and native CloudKit integration aligns the app with the latest Apple technologies, ensuring long-term maintainability and performance.

### 2.4. Data Models

- **UserProfile:** Stores basic user information.
- **PrayerDebt:** Tracks the number of missed prayers for each prayer type.
- **DailyLog:** Records the status of each prayer on a given day.
