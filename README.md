# **Desire**  
*Your Personal Workout Tracker with a Twist!*  

**Desire** is a beautifully designed Flutter app that transforms workout routines into an engaging game, blending fitness goals with gamification, accountability, and automation.  

---

## 🌟 **Key Features**  

### **🏋️‍♂️ Workout Tasks & Tracking**  
Track progress with predefined exercises:  
- **Run**: Distance in kilometers  
- **Plank Hold**: Duration in seconds  
- **Sprints**: Number of rounds  
- **Push-ups**: Reps  
- **Side Shuffle**: Rounds  
- **Lunges**, **Cobra Stretch**, and **Squats**: Reps and time  

🔐 **Access-Point Based Validation**  
- Tasks activate only when you reach specific map points.  
- Progress gets verified in real-time!  

---

### **🗺️ Map Integration**  
- Live tracking with integrated maps.  
- Highlights your location and access points.  

---

### **🤖 Automation & Smart Features**  
- **Password-Free Login**: Enter the correct password, and you’re in—no buttons needed.  
- **Auto-Save & Reset**: Tasks save automatically at midnight and reset daily.  

---

### **🎯 Point System**  
- **Weekly Goal**:  
  - Maximum: 560 points (80/day)  
  - Minimum: 400 points to avoid penalties  
- **Accountability Partner**: Miss the target? Funds get deducted and sent to your chosen keeper.  

---

### **🔧 Customization & Logs**  
- **Reformation**: Adjust reps, rounds, or time for any exercise.  
- **Scrolls**: View a detailed record of daily achievements, points, and map history—all saved securely in Firebase.  

---

## 🔄 **How It Works**  

### **Daily Workflow**  
1. Visit map access points to activate tasks.  
2. Complete and check off tasks throughout the day.  
3. Midnight magic: auto-save and reset!  

### **Weekly Workflow**  
- Hit at least 400 points by Sunday or face penalties.  
- Weekly evaluations notify you of progress.  

---

## 💡 **Technology Highlights**  
- **Firebase**: Secure login, real-time updates, and score tracking.  
- **Geolocation**: Powered by `geolocator` and `flutter_map`.  
- **Automation**: Seamless fund transfers to keepers for missed goals.  

---

## 📸 **App Previews**  

### **🔐 Login Screen**  
![Login And Home](https://github.com/Aniketps/Project-Images/blob/main/Screenshot%202024-12-25%20090237.png)

### **📍 Task Dashboard with Map**  
![Change Goal and Penalty](https://github.com/Aniketps/Project-Images/blob/main/Screenshot%202024-12-25%20090254.png)  

### **📜 Scrolls (Daily Records)**  
![Scrolls](https://github.com/Aniketps/Project-Images/blob/main/Screenshot%202024-12-25%20090313.png)  


## 📂 **File Structure**  

```plaintext
lib/    
├── firebase_options.dart
├── home.dart
├── home.dart      
├── home.dart 
├── reformation.dart  
└── scrolls.dart     
└── utils/
    ├── firebase_service.dart  # Firebase operations
    ├── location_service.dart  # Location tracking
assets/
└── images/
    └── background.jpg        # App background image
 
