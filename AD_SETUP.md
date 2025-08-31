# AdMob Integration Setup Guide

This guide explains how to set up AdMob ads for hints in Quantum Sync.

## 🎯 Overview

The app now includes a complete AdMob integration for rewarded video ads. Users can watch ads to get hints when they run out of free daily hints.

## 📱 Current Implementation

### Features:
- ✅ **Rewarded Video Ads** for hints
- ✅ **Daily Free Hints** (3 per day)
- ✅ **Ad Preloading** for better UX
- ✅ **Error Handling** for ad failures
- ✅ **Test Ads** for development

### Flow:
1. User runs out of free hints
2. User taps hint button
3. Ad loads and shows
4. User watches full ad
5. User gets hint as reward

## 🔧 Setup Instructions

### 1. Install Dependencies

The `google_mobile_ads` dependency is already added to `pubspec.yaml`:

```yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

Run:
```bash
flutter pub get
```

### 2. Get AdMob Account

1. Go to [AdMob Console](https://admob.google.com/)
2. Create a new account or sign in
3. Create a new app
4. Get your **App ID** and **Ad Unit IDs**

### 3. Update Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`):
Replace the test App ID with your real one:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

#### iOS (`ios/Runner/Info.plist`):
Add your AdMob App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

#### Ad Service (`lib/services/ad_service.dart`):
Replace the test Ad Unit ID with your real one:

```dart
static const String _rewardedAdUnitId = kDebugMode 
  ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
  : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your production ID
```

### 4. Test the Integration

1. Run the app in debug mode
2. Go to any level
3. Use up your free hints
4. Try to get a hint - you should see a test ad
5. Watch the full ad to get a hint

## 🎮 How It Works

### Hint System:
- **3 free hints per day**
- **Resets daily at midnight**
- **Rewarded ads for additional hints**

### Ad Integration:
- **Preloads ads** for better performance
- **Handles ad failures** gracefully
- **Shows user feedback** for all states
- **Preloads next ad** after successful completion

### User Experience:
1. **Free hints available**: Shows hint immediately
2. **No free hints**: Shows ad option
3. **Ad loading**: Shows loading indicator
4. **Ad failed**: Shows error message
5. **Ad completed**: Shows hint result

## 🛠️ Customization

### Change Daily Hint Limit:
Edit `lib/services/hint_service.dart`:
```dart
static const int _dailyFreeHints = 5; // Change from 3 to 5
```

### Change Ad Unit ID:
Edit `lib/services/ad_service.dart`:
```dart
static const String _rewardedAdUnitId = 'your-ad-unit-id-here';
```

### Add More Ad Types:
You can add banner ads, interstitial ads, etc. by extending the `AdService` class.

## 🚨 Important Notes

### For Production:
1. **Replace all test IDs** with real AdMob IDs
2. **Test thoroughly** on real devices
3. **Follow AdMob policies** for rewarded ads
4. **Handle edge cases** (no internet, ad blockers, etc.)

### AdMob Policies:
- Users must watch the **full ad** to get reward
- **Don't force ads** - always provide free alternatives
- **Respect user experience** - don't show too many ads
- **Follow platform guidelines** for ad placement

### Testing:
- Use **test ad unit IDs** during development
- Test on **real devices** (ads don't work in simulators)
- Test **offline scenarios** and **slow connections**

## 🔍 Troubleshooting

### Common Issues:

1. **"Ad not available" error**:
   - Check internet connection
   - Verify AdMob App ID is correct
   - Ensure ad unit ID is valid

2. **Ads not showing**:
   - Check if running in debug mode (uses test ads)
   - Verify AdMob account is active
   - Check ad unit status in AdMob console

3. **App crashes on ad load**:
   - Check Android manifest configuration
   - Verify all dependencies are installed
   - Check for conflicting ad libraries

### Debug Tips:
- Check console logs for ad-related messages
- Use AdMob test devices for development
- Monitor ad performance in AdMob console

## 📊 Analytics

The integration includes logging for:
- Ad load success/failure
- Ad show events
- User reward events
- Error tracking

Monitor these in your development console and AdMob dashboard.

## 🎉 Success!

Once configured, users will be able to:
- Get 3 free hints daily
- Watch ads for additional hints
- Enjoy a smooth, non-intrusive ad experience
- Continue playing without being forced to watch ads

The ad integration is designed to be **user-friendly** and **non-disruptive** to the gaming experience!
