# Firebase Configuration Guide

## Setup Steps

1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase for your project:**
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project or create a new one
   - Choose platforms (Android, iOS, Web)
   - This will generate `firebase_options.dart`

3. **For Android:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/` directory

4. **For iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/` directory

## Database Rules (Firestore)

Set these rules in Firebase Console > Firestore Database > Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Ingredients - read-only for now
    match /ingredients/{ingredientId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Households
    match /households/{householdId} {
      allow read, write: if true; // For testing, adjust in production
      
      // Inventory subcollection
      match /inventory/{inventoryId} {
        allow read, write: if true;
      }
      
      // Other subcollections
      match /{document=**} {
        allow read, write: if true;
      }
    }
    
    // Users
    match /users/{userId} {
      allow read, write: if true;
    }
  }
}
```

## Test the Setup

1. Run the app
2. Go to Settings > Debug Tools
3. Click "Seed Database" to populate sample data
4. Check Firebase Console to verify data was created
5. Go to "Barcode Generator" to see generated barcodes
6. Test barcode scanning in the Fridge screen

## Troubleshooting

- If Firebase initialization fails, make sure `firebase_options.dart` exists
- Check that `google-services.json` is in the correct location
- Ensure internet connection for Firebase operations
- Check Firebase Console for any security rule issues
