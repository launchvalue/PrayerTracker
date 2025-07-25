# CRITICAL: Production Credentials Required for App Store Submission

## ❌ BLOCKING ISSUES - MUST FIX BEFORE SUBMISSION

### 1. GoogleService-Info.plist - Invalid Production Credentials

**CURRENT INVALID VALUES:**
```xml
<key>API_KEY</key>
<string>AIzaSyAq3gVPBgTK46FVUEox8Lu1y1yi2ZA__Fk</string>  

<key>GOOGLE_APP_ID</key>  
<string>1:313804251285:ios:qe4kjlo3s81c1im7b9mqvv2lis3i7k6s.apps.googleusercontent.com</string>  
```

**ACTION REQUIRED:**
1. Log into Google Cloud Console (https://console.cloud.google.com)
2. Go to your "prayer-tracker-project" project
3. Navigate to APIs & Services > Credentials
4. Create/get production API key for iOS
5. Get the correct GOOGLE_APP_ID for your project
6. Replace placeholder values with real production credentials

**CORRECT FORMAT SHOULD BE:**
```xml
<key>API_KEY</key>
<string>AIzaSy[REAL_PRODUCTION_KEY_HERE]</string>

<key>GOOGLE_APP_ID</key>  
<string>1:313804251285:ios:[REAL_APP_ID_HERE]</string>
```

### 2. Entitlements - Development Environment

**CURRENT INVALID VALUE:**
```xml
<key>aps-environment</key>
<string>development</string>  <!-- ❌ MUST BE "production" -->
```

**ACTION REQUIRED:**
Update PrayerTracker.entitlements:
```xml
<key>aps-environment</key>
<string>production</string>  <!-- ✅ REQUIRED FOR APP STORE -->
```

## ⚠️ IMPORTANT NOTES

- **App will be REJECTED by Apple** if submitted with dummy/placeholder credentials
- Google Sign-In will NOT work in production with dummy API key
- Push notifications require production aps-environment
- These changes must be made BEFORE creating App Store build

## ✅ ALREADY CORRECT

- Bundle identifier: `com.prayerstack.prayertracker` ✅
- Client ID: Valid Google OAuth client ID ✅
- Bundle ID in GoogleService-Info.plist: Matches app bundle ID ✅
- Version number: 1.0 (appropriate for initial release) ✅

## NEXT STEPS

1. Fix GoogleService-Info.plist with real production credentials
2. Update entitlements to production environment  
3. Test Google Sign-In functionality with production credentials
4. Create production build for App Store submission
