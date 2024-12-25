# Desire  

**Desire** is a Flutter-based mobile application designed as a personal workout tracker. It helps users maintain fitness goals with gamification, accountability, and automation features.  

## Features  

### Workout Tasks and Tracking  
- **Defined Exercises:**  
  - Run (in kilometers)  
  - Plank Hold (in seconds)  
  - Sprints (rounds)  
  - Push-ups  
  - Side Shuffle (rounds)  
  - Lunges  
  - Cobra Stretch (in seconds)  
  - Squats  
- Tasks can only be marked as complete if the user visits a specified access point on the map.  
- Tasks are disabled unless the user reaches the access point.  

### Map Integration  
- Real-time location tracking with integrated map views.  
- Highlights the user’s current location and the designated access point.  

### Automated Processes  
- **Password Authentication:**  
  - No navigation buttons; users automatically log in upon entering the correct password.  
- **Task Management:**  
  - Tasks auto-save to Firebase at midnight.  
  - All tasks reset daily at 12:00 AM.  

### Point-Based System  
- **Weekly Targets:**  
  - Maximum: 560 points (80 points/day).  
  - Minimum: 400 points to avoid penalties.  
- **Accountability:**  
  - If the target is not met, funds are deducted and sent to the assigned keeper (a trusted person).  

### Reformation (Customization)  
- Customize workout targets such as reps, time, or rounds for each task.  

### Scrolls (Daily Records)  
- Automatically stores daily records in Firebase.  
- Displays task completion, points earned, and map history in a scrollable format.  

## Workflow Overview  

### User Authentication  
- Enter the password to log in automatically without manual buttons.  

### Daily Workflow  
1. Visit the access point on the map to enable task checkmarks.  
2. Complete tasks and check them off throughout the day.  
3. Tasks auto-save at midnight, reset for the next day.  

### Weekly Workflow  
1. Achieve 400 points by Sunday night to avoid penalties.  
2. Weekly scores are evaluated, and results are notified to the user.  

### Reformation  
- Modify workout targets anytime through the Reformation feature.  

## Technology and Automation  

- **Firebase Integration:**  
  - Secure authentication and real-time database for storing records and scores.  
- **Location Services:**  
  - Powered by `geolocator` and `flutter_map` for precise access point tracking.  
- **Automation:**  
  - Weekly evaluations and automated fund transfers to the keeper if goals are not met.  

## File Structure  

lib/
├── main.dart             // Entry point
├── screens/
│   ├── login.dart        // Password authentication
│   ├── home.dart         // Main dashboard with tasks and map
│   ├── reformation.dart  // Customization of targets
│   └── scrolls.dart      // Display of daily records
├── widgets/
│   ├── task_card.dart    // Individual task representation
│   ├── map_view.dart     // Map integration for access points
└── utils/
    ├── firebase_service.dart  // Firebase interactions
    ├── location_service.dart  // Location tracking and validation
assets/
└── images/
    └── background.jpg        // App background image

##Images

### Login Screen
![Login Screen](https://link_to_your_image.com/login_screen_image.jpg)

### Task Dashboard with Map
![Task Dashboard](https://link_to_your_image.com/task_dashboard_image.jpg)

### Scrolls (Daily Records)
![Scrolls Screen](https://link_to_your_image.com/scrolls_image.jpg)
