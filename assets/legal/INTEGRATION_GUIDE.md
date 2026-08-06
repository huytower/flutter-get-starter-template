# Terms of Service Integration Guide

## Quick Integration Steps

### 1. Add Asset to pubspec.yaml
```yaml
flutter:
  assets:
    - assets/legal/terms_of_service.html
```

### 2. Create WebView Page Component
Create a new file: `lib/presentation/legal/terms_of_service_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/legal/terms_of_service.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều Khoản Sử Dụng'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### 3. Add Link to Login Page
In your login page (e.g., `shared/cc_micro_features/lib/features/auth/presentation/pages/login_page.dart`), add the Terms of Service link:

```dart
// Add this near your social login buttons
Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsOfServicePage(),
            ),
          );
        },
        child: Text(
          'Điều khoản sử dụng',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 12,
          ),
        ),
      ),
    ],
  ),
)
```

### 4. Alternative: Simple Link Style
If you prefer a more subtle approach:

```dart
// At the bottom of your login page, above the login button
Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bằng cách đăng nhập, bạn đồng ý với '),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServicePage(),
              ),
            );
          },
          child: const Text(
            'Điều khoản sử dụng',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),
    // Your login button here
  ],
)
```

## Customization Options

### 1. Change Default Language
To start with English instead of Vietnamese, modify the HTML file:

```html
<!-- Change this line -->
<div class="container vietnamese-content" id="content-vi">

<!-- To this -->
<div class="container english-content" id="content-en" style="display: block;">
```

And update the button states:
```javascript
// Change initial button states
document.getElementById('btn-vi').classList.remove('active');
document.getElementById('btn-en').classList.add('active');
```

### 2. Auto-Detect Language
You can pass language preference from Flutter:

```dart
// In your TermsOfServicePage
class TermsOfServicePage extends StatefulWidget {
  final String initialLanguage;
  const TermsOfServicePage({super.key, this.initialLanguage = 'vi'});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

// Then in initState
@override
void initState() {
  super.initState();
  _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          // Set initial language
          _controller.runJavaScript(
            widget.initialLanguage == 'vi' 
              ? 'showVietnamese()' 
              : 'showEnglish()'
          );
        },
      ),
    )
    ..loadFlutterAsset('assets/legal/terms_of_service.html');
}
```

### 3. Styling Customization
Modify the CSS in the HTML file to match your app's theme:

```css
/* Update these colors to match your app */
h1 {
    color: #2c3e50;  /* Change to your primary color */
    border-bottom: 3px solid #3498db;  /* Change to your accent color */
}

.language-toggle button.active {
    background: #3498db;  /* Your primary color */
    color: white;
}
```

## Testing Checklist

### Functional Testing
- [ ] Terms link opens correctly from login page
- [ ] WebView loads the HTML content
- [ ] Language toggle works correctly
- [ ] Back button returns to login page
- [ ] Content scrolls properly on different screen sizes

### UI Testing
- [ ] Text is readable on both light and dark themes
- [ ] Links are tappable and provide visual feedback
- [ ] Loading indicator shows while content loads
- [ ] Layout works on different screen sizes (mobile/tablet)

### Localization Testing
- [ ] Vietnamese text displays correctly
- [ ] English text displays correctly
- [ ] Language switching works smoothly
- [ ] No encoding issues with special characters

## Troubleshooting

### Issue: WebView doesn't load content
**Solution**: 
1. Ensure the asset is added to pubspec.yaml
2. Run `flutter clean && flutter pub get`
3. Check that the file path is correct

### Issue: Language toggle doesn't work
**Solution**:
1. Ensure JavaScript is enabled: `setJavaScriptMode(JavaScriptMode.unrestricted)`
2. Check browser console for JavaScript errors
3. Verify the HTML file structure is correct

### Issue: Text encoding issues
**Solution**:
1. Ensure the HTML file is saved with UTF-8 encoding
2. Check that the meta charset is set to UTF-8
3. Test with Vietnamese characters specifically

### Issue: Styling doesn't match app theme
**Solution**:
1. Customize the CSS colors in the HTML file
2. Consider using your app's color scheme
3. Test on both light and dark themes

## Store Submission Preparation

### Before Submitting to Apple App Store
1. [ ] Update contact information in HTML file
2. [ ] Test on physical iOS device
3. [ ] Verify terms link is easily accessible
4. [ ] Ensure account deletion option is available
5. [ ] Test language switching functionality

### Before Submitting to Google Play Store
1. [ ] Update contact information in HTML file
2. [ ] Test on physical Android device
3. [ ] Verify terms link is easily accessible
4. [ ] Test on different Android versions
5. [ ] Ensure back navigation works correctly

## Maintenance

### When to Update Terms
- Adding new features that collect new data
- **Adding paid features or subscriptions** (currently free)
- Modifying data retention policies
- Adding new payment methods
- Changing contact information

### Update Process
1. Update the HTML file with new content
2. Update the "Last updated" date
3. Test the updated content in the app
4. Consider notifying users of significant changes
5. Update store submission if required

## Additional Resources

### Apple Guidelines
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Google Play Guidelines
- [Google Play Developer Policy Center](https://play.google.com/developer/policy)
- [User Data Policy](https://play.google.com/developer/policy/user-data)

### Legal Resources
- Consider consulting with a legal professional for final review
- Ensure compliance with local Vietnamese laws
- Review terms annually for updates
