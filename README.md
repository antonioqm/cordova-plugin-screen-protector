# Cordova Plugin Screen Protector

A Cordova plugin to protect your app's content against screenshots and screen recordings on iOS and Android.

## Features

- Blocks screenshots and screen recordings on iOS and Android
- Works with all activities, including WebViews and third-party activities
- Automatic protection - no need to enable/disable manually
- Compatible with Cordova, Ionic, and other hybrid frameworks

## Installation

### Using npm

```bash
cordova plugin add cordova-plugin-screen-protector
```

### Using GitHub

```bash
cordova plugin add https://github.com/antonioqm/cordova-plugin-screen-protector.git
```

## Usage

The plugin automatically protects all activities in your app. No additional code is needed - just install the plugin and it will work.

### TypeScript/Angular

```typescript
import { Component } from '@angular/core';
import { Platform } from '@ionic/angular';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
})
export class AppComponent {
  constructor(private platform: Platform) {
    this.initializeApp();
  }

  private initializeApp() {
    this.platform.ready().then(() => {
      console.log('Platform ready');
      // Plugin is automatically protecting all activities
    });
  }
}
```

### JavaScript

```javascript
document.addEventListener('deviceready', function() {
    console.log('Device ready');
    // Plugin is automatically protecting all activities
}, false);
```

## How It Works

The plugin uses:
- `FLAG_SECURE` on Android to prevent screenshots and screen recordings
- `UIScreen.isCaptured` on iOS to detect screen recording and show a protection overlay

## Limitations

### Android System Limitations
- On Android 10 and below, `FLAG_SECURE` cannot be disabled once enabled for an activity
- Some Android manufacturers may have custom implementations that affect the behavior of `FLAG_SECURE`
- System-level screen recording (like Android's built-in screen recorder) may still be able to capture content in some cases

### iOS System Limitations
- Screen recording detection is only available on iOS 13 and above
- The protection overlay will be shown when screen recording is detected, as this is the only way iOS allows apps to respond to screen recording
- System-level screen recording may still be able to capture content in some cases

## Troubleshooting

If you experience any issues:
1. Make sure the plugin is properly installed
2. Check the device logs for any error messages
3. Verify that your app has the necessary permissions

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
