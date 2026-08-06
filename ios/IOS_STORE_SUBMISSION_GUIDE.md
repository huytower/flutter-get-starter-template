# iOS Info.plist Updates for Apple Store Submission

## Overview
Updated `ios/Runner/Info.plist` with proper app descriptions and permission usage descriptions for Apple App Store submission compliance.

## Changes Made

### 1. Permission Usage Descriptions (CRITICAL for Apple Approval)

#### Face ID Authentication
**Before:** "My app use face id for authentication"
**After:** "Sổ Sách Xịn uses Face ID to securely authenticate your account and protect your financial data from unauthorized access."

**Why:** Apple requires clear, specific explanations for how biometric data is used. Financial apps need extra security justification.

#### Photo Library Access
**Before:** "This app needs access to your photo library to save and access images"
**After:** "Sổ Sách Xịn needs access to your photo library to attach receipt images to your transactions and import expense photos for automatic data entry."

**Why:** Specific use case (receipt images) helps reviewers understand the necessity for financial app workflows.

#### Photo Library Add Usage
**Before:** "This app needs permission to save photos to your photo library"
**After:** "Sổ Sách Xịn needs permission to save receipt images and transaction photos to your photo library for your records."

**Why:** Users need to understand why the app is saving photos to their library.

#### Camera Access (NEW)
**Added:** "Sổ Sách Xịn needs camera access to capture receipt images and expense photos for automatic transaction entry and record keeping."

**Why:** Your business requirements mention image processing for receipts. Camera permission was missing but needed.

#### Documents Folder Access
**Before:** "This app needs access to your documents folder to save files"
**After:** "Sổ Sách Xịn needs access to your documents folder to save and export your financial reports and transaction data."

**Why:** Specific mention of financial reports justifies the permission for a finance app.

#### Location Access
**Before:** "This app needs access to your location to detect your country code for phone number input"
**After:** "Sổ Sách Xịn uses your location to detect your country code for phone number formatting and provide smart spending suggestions based on nearby merchants (optional feature)."

**Why:** Added explanation of smart spending feature from your business requirements. Mentioning "optional feature" helps reviewers understand it's not always required.

### 2. App Identity and Description

#### App Spoken Name
**Added:** `<key>CFBundleSpokenName</key><string>Sổ Sách Xịn</string>`

**Why:** Siri and VoiceOver will pronounce the app name correctly as "Sổ Sách Xịn" instead of reading the full bundle name.

#### App Category
**Added:** `<key>LSApplicationCategoryType</key><string>public.app-category.finance</string>`

**Why:** Proper categorization helps App Store users find your app and improves discoverability in the Finance category.

#### App Description (Get Info String)
**Added:** `<key>CFBundleGetInfoString</key><string>Sổ Sách Xịn - Quản Lý Tài Chính cá nhân: Ứng dụng quản lý thu chi, ngân sách và đầu tư thông minh với AI</string>`

**Why:** Provides a concise app description that appears in system dialogs and crash reports.

### 3. Network Security Configuration

#### App Transport Security
**Added:** NSAppTransportSecurity configuration with exceptions for Firebase and Google APIs

**Why:** 
- Modern iOS requires HTTPS by default
- Firebase and Google APIs need specific exceptions
- Ensures secure communication while allowing required services

## Apple App Store Compliance Checklist

### Permission Descriptions ✅
- [x] Face ID: Clear security justification
- [x] Photo Library: Specific use case (receipt images)
- [x] Camera: Added for receipt capture feature
- [x] Documents: Financial reports justification
- [x] Location: Phone formatting + smart suggestions (optional)

### App Identity ✅
- [x] Proper category (Finance)
- [x] Spoken name for accessibility
- [x] App description in Vietnamese

### Security ✅
- [x] HTTPS enforcement by default
- [x] Firebase API exceptions configured
- [x] Google API exceptions configured

## Additional Files to Check

### 1. Podfile (ios/Podfile)
Ensure proper platform and deployment target:
```ruby
platform :ios, '13.0'  # Minimum iOS version
```

### 2. Project Settings (Xcode)
In Xcode, verify:
- **Deployment Target**: iOS 13.0 or higher
- **Bundle Identifier**: Matches your App Store configuration
- **Team**: Your Apple Developer Team selected
- **Signing**: Automatic or Manual signing configured

### 3. Entitlements File (if needed)
If you add features later, you may need:
- [ ] **Push Notifications**: `aps-environment` entitlement
- [ ] **Siri**: Siri capability entitlement
- [ ] **iCloud**: iCloud containers entitlement

## App Store Connect Preparation

### App Information Required
1. **App Name**: Sổ Sách Xịn - Quản Lý Tài Chính
2. **Subtitle**: Quản lý thu chi thông minh
3. **Description**: Use your business requirements summary
4. **Keywords**: tài chính, quản lý chi tiêu, ngân sách, thu nhập, chi tiêu
5. **Support URL**: https://app-qltc.vercel.app
6. **Marketing URL**: https://app-qltc.vercel.app (same for now)
7. **Privacy Policy URL**: Create separate privacy policy page

### App Store Screenshots Needed
1. **iPhone 6.7" Display**: 3-10 screenshots
2. **iPhone 6.5" Display**: 3-10 screenshots  
3. **iPad Pro 12.9" Display**: 3-10 screenshots (if iPad supported)

### App Information
- **Category**: Finance
- **Age Rating**: 4+ (no violence, no restricted content)
- **Content Rights**: "No" (using standard UI components)

## Permission Justification Summary for Reviewers

### Why This App Needs These Permissions:

**Camera & Photo Library**: 
- Users can photograph receipts for automatic expense entry
- Images attached to transactions for record keeping
- Reduces manual data entry and improves accuracy

**Location**:
- Auto-detects country for phone number formatting
- Optional smart spending suggestions based on nearby merchants
- User can disable location features if preferred

**Face ID**:
- Secure authentication for financial data protection
- Prevents unauthorized access to sensitive financial information
- Industry standard for finance apps

**Documents**:
- Export financial reports for tax purposes
- Backup transaction data for record keeping
- Import/export functionality for data portability

## Testing Before Submission

### Permission Testing
1. **Camera**: Test receipt photo capture
2. **Photo Library**: Test image selection and saving
3. **Location**: Test phone number formatting with location enabled/disabled
4. **Face ID**: Test biometric authentication flow
5. **Documents**: Test report export functionality

### Security Testing
1. Test app with network off (offline mode)
2. Test Firebase connection
3. Test data sync functionality
4. Verify HTTPS enforcement

## Common Apple Rejection Reasons & Prevention

### Rejection: "Insufficient Permission Justification"
**Prevention**: Our updated descriptions are specific and explain exact use cases

### Rejection: "App Category Mismatch"  
**Prevention**: We set proper Finance category

### Rejection: "Missing Privacy Policy"
**Prevention**: You'll need to create a separate privacy policy page

### Rejection: "Inadequate Screenshots"
**Prevention**: Prepare proper screenshots showing key features

## Next Steps

### Immediate Actions
1. **Test all permissions** on physical device
2. **Create privacy policy** page (separate from terms)
3. **Prepare app screenshots** for all required sizes
4. **Verify bundle identifier** matches App Store Connect

### App Store Connect Setup
1. Create app in App Store Connect
2. Fill in all required information
3. Upload screenshots
4. Submit for review

### After Submission
- Monitor review status (typically 1-3 days)
- Be prepared to answer reviewer questions
- Have test account ready if requested
- Address any rejection feedback promptly

## Notes for Vietnamese Market

### Localization
- App name and description in Vietnamese
- Permission descriptions in Vietnamese (currently English - may want to localize)
- Consider Vietnamese screenshots for App Store

### Compliance
- Ensure compliance with Vietnamese financial app regulations
- Consider any local data residency requirements
- Review Vietnamese consumer protection laws

The Info.plist is now properly configured for Apple App Store submission with clear permission justifications and proper app categorization!
