# Plan: adaptive navigation shell in the SDK

Status: **N1 and N2 done** (`CcAdaptiveNavigationScaffold` in `cc_sdk_ui`; the app shell uses it). N3 waits for
approval.

N2 differs from the plan in two places:
- The app wraps the **whole** scaffold in `mainShell.watchTabs` instead of using `navigationBuilder`: the tab
  badges are read while the destination list is built, so the list has to be built inside the GetX `Obx`. The
  page keeps its state across that rebuild (the scaffold keys it), and `buildTab` returns `const` pages, so the
  rebuild is cheap.
- No widget test for `NavigationBar` itself: its `initState` resolves real providers through `getIt`, which the
  test rules forbid registering. The scaffold's 26 SDK tests cover the layout on every reference window.

## Why

Every app built on the SDK needs the same top-level shell: a bottom bar on phones and upright tablets, a side rail
on wide windows (tablets held sideways, desktop), the tab's state kept when it switches, and a bar that fits both
gesture and 3-button navigation. Today the SDK only has the pieces (`CcCurvedNavigationBar`,
`CcNavigationRail`, `CcNavigationRailScope`, `CcCurvedNavigationMixin`); the decision and the wiring live in this
app's `lib/presentation/main_navigation/navigation_bar.dart` (243 lines), so a new project rewrites them.

## What is generic and what stays in the app

| In `navigation_bar.dart` today | Goes to | Why |
|---|---|---|
| Bar below the *expanded* window class (< 840 dp), rail from expanded up | SDK | Same rule for any app (`AGENTS.md` rule 9) |
| Rail with labels from *extraLarge* (≥ 1600 dp) | SDK (parameter) | Same |
| `GlobalKey` around the content so the open tab keeps its state when bar ↔ rail switches (rotation, split screen) | SDK | Easy to forget, easy to get wrong |
| `CcNavigationRailScope` around the content (pages square the edge next to the rail) | SDK | Already an SDK type |
| Bottom inset: a gesture indicator (≤ 34 dp) is capped to 22 dp, a 3-button bar keeps its full inset; colour behind the system bar | SDK | Device behaviour, not app behaviour |
| Hide the navigation (splash) | SDK flag `hasNavigation` | Generic |
| Tabs (`MainTab`), their pages, badges, icons, labels, colours (`PrjColors`) | **App** | App content |
| Reactive rebuild of badges (`mainShell.watchTabs`, GetX `Obx`) | **App**, through a builder callback | The SDK must stay state-management agnostic |
| Double back to exit, status / navigation bar style, boot services (`NavigationLogicMixin`), splash | **App** | App behaviour |

## Design

### `cc_sdk_ui`: `CcAdaptiveNavigationScaffold` (new, `widgets/navigation/`)

```dart
CcAdaptiveNavigationScaffold(
  destinations: items,              // List<CcCurvedNavigationItem>, shared by bar and rail
  currentIndex: index,
  onSelect: setIndex,
  primaryIndex: entryIndex,         // raised "+" in the bar, round action in the rail (optional)
  hasNavigation: !showSplash,
  navigationBuilder: (nav) => shell.watchTabs(() => nav),   // optional: app's reactive wrapper
  activeColor: ..., activeIconColor: ..., fabColor: ..., barHeight: ...,  // optional, theme by default
  railFrom: CcWindowSizeClass.expanded,          // defaults shown
  extendedRailFrom: CcWindowSizeClass.extraLarge,
  body: content,
)
```

- A `StatefulWidget` (it owns the content `GlobalKey`), built on `Scaffold`: `bottomNavigationBar` below
  `railFrom`, `Row(rail, Expanded(content))` from it.
- Measured from the window (`context.windowSizeClass`), as rule 9 allows for the navigation shell.
- No strings, no `get` / Bloc: `navigationBuilder` is how an app adds its own reactive rebuild.
- About 150 lines plus a small `CcBottomInset` helper for the gesture / 3-button rule if the file grows.

### `CcCurvedNavigationMixin`: remove (breaking, goes into the pending `3.0.0`)

Its job (build the bar and the rail from one item list) moves into the scaffold. It also still ships hard-coded
English defaults (`'Dashboard'`, `'Notification'`, `'Profile'` and a default item list), which the SDK rules
forbid. Only this app uses it. Removal is listed under `### Breaking` with the migration ("use
`CcAdaptiveNavigationScaffold`"), its test is replaced by the scaffold's, and the `cc_mixin` example comment is
updated.

### App

`navigation_bar.dart` keeps only app content: the three tabs (items, labels, badges, colours), splash, double
back to exit, the system bar style and `NavigationLogicMixin`. Expected size: about 120 lines instead of 243.
The `MainShellProvider` doc comment that mentions `buildCurvedNavigationBar` is updated.

## Tests

SDK widget tests on `CcReferenceWindows`:
- bottom bar on phones, 7"/10" and iPad upright (all < 840 dp); rail on every tablet held sideways, iPad 13"
  upright and desktop; labels on the rail only from 1600 dp;
- the open tab keeps its state when the window crosses 840 dp (a counter in the body survives the switch);
- `primaryIndex` shows the raised "+" / round rail action; `hasNavigation: false` hides both;
- gesture inset (≤ 34 dp) capped to 22 dp, 3-button inset kept;
- `navigationBuilder` wraps the bar and the rail.

App: the existing tests plus a check that the shell shows the bar on a phone and the rail on a landscape tablet.

## Phases (one SDK commit + one app commit each; nothing pushed without your go-ahead)

| Phase | Items |
|---|---|
| N1 | `CcAdaptiveNavigationScaffold` + tests (additive, nothing breaks) |
| N2 | App shell on the scaffold; manual-test list (rotation, split screen, gesture vs 3-button phones) |
| N3 | Remove `CcCurvedNavigationMixin` (breaking), docs: `AGENTS.md` rule 9, SDK skill "Adopting the SDK" step 6, CHANGELOGs |

## Decisions for you

1. **Remove `CcCurvedNavigationMixin`** in N3 (recommended), or keep it next to the scaffold?
2. **Gesture-inset rule** (cap a gesture indicator's inset at 22 dp) **in the SDK** (recommended, every app has
   the same Android/iOS indicators), or leave it to each app?
3. **Breakpoints as parameters** with today's defaults (recommended), or fixed in the SDK?
