# Store privacy declarations — answers to enter

What to fill in **App Store Connect → App Privacy** and **Google Play Console → App content → Data safety**
for Sổ Sách Xịn. These forms live in the store consoles, not in the repository: this file is the source of truth
for the answers, kept in step with `assets/legal/privacy_policy.html` and `docs/BUSINESS_REQUIREMENT.md` §5.
Update all three together whenever the app starts or stops collecting something.

Last checked against the code: 27/11/2026.

## Facts the answers rest on (verify again before each release)

| Fact | Where in code |
|---|---|
| No advertising SDK, no IDFA / Advertising ID, no tracking across apps | no `AdSupport` / ad SDK in `pubspec.yaml`, Podfile, Gradle |
| Firebase Analytics is linked to the Firebase user ID after sign-in | `login_bloc.dart` → `CcAnalytics.setUserId(user.id)` |
| Crash reports carry no user ID, name, email or phone | no `setUserIdentifier` (Crashlytics); the app sets no `user_email` / `uid` custom parameter for the Slack handler. The temporary delete-account Slack trace (masked email) was removed on 27/11/2026; account deletion now logs only locally |
| Precise coordinates saved on expenses (LV3/VIP) and synced to Firestore | `expense_form_controller.dart`, `TransactionModel.lat/lng` |
| Country detection keeps only the country code, on the device | `CurrencyCatalog.detectSuggestedCurrencyFromGpsWithDetails` |
| Voice is transcribed by the OS; only text leaves the device (to Gemini, with consent) | `NSSpeechRecognitionUsageDescription`, smart entry pipeline |
| AI requests carry no name, email, phone or account ID | `ai_prompts.dart`, policy §3 |
| All traffic is HTTPS / TLS (Firebase, Gemini via Firebase AI Logic, Frankfurter) | — |
| Users can delete their account and all cloud data in the app | Profile → Delete account (`deleteCloudData`) |

## App Store Connect — App Privacy

**Do you or your third-party partners collect data from this app?** Yes.

**Tracking** ("used to track you"): **No** for every data type. Do not add the App Tracking Transparency prompt.

| Category → data type | Collected | Linked to the user | Used for |
|---|---|---|---|
| Contact Info → **Name** | Yes | Yes | App Functionality |
| Contact Info → **Email Address** | Yes | Yes | App Functionality |
| Contact Info → **Phone Number** | Yes | Yes | App Functionality |
| Location → **Precise Location** | Yes | Yes | App Functionality |
| Location → Coarse Location | **No** (the country is derived and kept on the device only) | — | — |
| Financial Info → **Other Financial Info** (wallets, transactions, budgets, debts) | Yes | Yes | App Functionality |
| User Content → **Photos or Videos** (receipt photo sent to Gemini) | Yes | No | App Functionality |
| User Content → **Customer Support** (in-app feedback and rating comments) | Yes | No | App Functionality |
| User Content → **Other User Content** (text typed or dictated for AI entry) | Yes | No | App Functionality |
| User Content → Audio Data | **No** (the OS transcribes; no recording leaves the device) | — | — |
| Identifiers → **User ID** (Firebase UID) | Yes | Yes | App Functionality, Analytics |
| Identifiers → **Device ID** (Firebase installation ID, push token) | Yes | Yes | App Functionality, Analytics |
| Usage Data → **Product Interaction** (Firebase Analytics events) | Yes | Yes | Analytics |
| Diagnostics → **Crash Data** | Yes | No | App Functionality |
| Diagnostics → **Performance Data** | Yes | No | App Functionality |
| Diagnostics → **Other Diagnostic Data** (device model, OS, app version) | Yes | No | App Functionality |

Not collected: Health & Fitness, Purchases (no in-app purchase yet — revisit when paid VIP ships), Browsing /
Search History, Sensitive Info, Contacts, Emails or Text Messages, Gameplay Content, Advertising Data.

**Privacy Policy URL**: the public URL of the same policy that is bundled in `assets/legal/privacy_policy.html`.

## Google Play Console — Data safety

**Does your app collect or share any of the required user data types?** Yes.
**Is all of the user data collected by your app encrypted in transit?** Yes.
**Do you provide a way for users to request that their data is deleted?** Yes — in the app (Profile → Delete
account) and by email (policy §9). **Account deletion web link** (required by Play, works without the app):
**https://app-qltc.vercel.app/delete-account**.

**Shared** (transferred to a third party): **none**. Firebase, Gemini (Firebase AI Logic) and Slack act as
service providers processing data on our behalf, which Play does not count as sharing.

| Data type | Collected | Required or optional | Processed ephemerally | Purposes |
|---|---|---|---|---|
| Location → **Precise location** | Yes | Optional | No | App functionality |
| Location → Approximate location | No (country kept on device only) | — | — | — |
| Personal info → **Name** | Yes | Optional (guest mode needs no account) | No | App functionality, Account management |
| Personal info → **Email address** | Yes | Optional | No | App functionality, Account management |
| Personal info → **Phone number** | Yes | Optional | No | App functionality, Account management |
| Personal info → **User IDs** | Yes | Optional | No | App functionality, Analytics, Account management |
| Financial info → **Other financial info** | Yes | Required (the app's purpose) | No | App functionality |
| Photos and videos → **Photos** | Yes | Optional | **Yes** (sent to Gemini to read the receipt, not stored by us) | App functionality |
| Audio → Voice or sound recordings | No (OS speech recognition) | — | — | — |
| App activity → **App interactions** | Yes | Required | No | Analytics |
| App activity → **Other user-generated content** (AI entry text, feedback) | Yes | Optional | AI text: Yes · feedback: No | App functionality |
| App info and performance → **Crash logs** | Yes | Required | No | App functionality |
| App info and performance → **Diagnostics** | Yes | Required | No | App functionality |
| Device or other IDs → **Device or other IDs** (Firebase installation ID, push token) | Yes | Required | No | App functionality, Analytics |

## Related items outside the forms

- **iOS purpose strings** (`ios/Runner/Info.plist` + `en.lproj` / `vi.lproj/InfoPlist.strings`): the location
  text now says the place of each expense is saved and backed up, and the unused "Always" key is removed.
- **iOS privacy manifest**: `ios/Runner/PrivacyInfo.xcprivacy`, registered in the Runner target's Resources. No tracking,
  no tracking domains, no required-reason APIs of its own (plugins and Flutter ship theirs), and the collected
  data types listed in the App Store table above. Keep the two in step.
- **Android permissions**: `MANAGE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`,
  `WRITE_INTERNAL_STORAGE` and `requestLegacyExternalStorage` were removed (27/11/2026): no code uses shared
  storage, and the receipt gallery uses the system photo picker, which needs no permission. Remaining:
  internet, biometrics, location (fine + coarse), notifications, microphone, camera.
