## 2.0.0

### BREAKING CHANGES

- Renamed the package from `kpostal` to `webview_flutter_kpostal`.
  - Update the dependency: `kpostal` → `webview_flutter_kpostal`.
  - Update the import: `package:kpostal/kpostal.dart` → `package:webview_flutter_kpostal/webview_flutter_kpostal.dart`.
- Replaced the `flutter_inappwebview` dependency with the official `webview_flutter` plugin.
  - `InAppWebView` → `WebViewWidget` + `WebViewController`.
  - JS → Dart bridge now uses `addJavaScriptChannel('onComplete', ...)`.
  - Page-load completion now uses `NavigationDelegate.onPageFinished`.
- The search page is now loaded from a bundled asset via `WebViewController.loadHtmlString`
  with an `https` base URL (so the embedded Kakao postcode iframe can post results back).
  No remote hosting and no runtime `HttpServer` are used, so `usesCleartextTraffic` /
  `NSAppTransportSecurity` are no longer required.
  - **Removed `useLocalServer` and `localPort`** — the page always loads from bundled assets.
- **Removed Kakao geocoding.** Dropped `kakaoKey`, `useKakaoGeocoder`, and the
  `Kpostal.kakaoLatitude` / `Kpostal.kakaoLongitude` fields. The selected address still exposes
  `latitude` / `longitude` resolved through the platform geocoder (`geocoding` plugin).

`KpostalView` and the `Kpostal` result model are otherwise unchanged.

## 1.1.0

- Updated minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Updated `flutter_inappwebview` dependency version to the latest `^6.1.5`

## 1.0.0

### ENHANCEMENTS

- Fix typo
- Example App targets Android SDK 34 version
- Update docs and example

### BREAKING CHANGES

- Dart SDK version `>=2.17.0 <4.0.0`
- Flutter minimum version `3.0.0`
- Updated Android `minSdkVersion` to `19`
- Changed `flutter_inappwebview` dependency version to `^6.0.0`
- Changed `geocoding` dependency version to `^3.0.0`
- The minimum iOS version to be `9.0`(ios/Podfile) with `XCode version >= 14`

## 0.5.1

- fix #12 issue : show representative jibunAddress

## 0.5.0

- remove pubspec.lock from git.
- update dependencies.
- improve method for searching latitude and logitude through geocoding.
  if not found by eng address, retry using kor address.
- log info.

## 0.4.2

- fix a bug below Android 10.

## 0.4.1

- add "bname1" parameter.

## 0.4.0

- remove "webview_flutter" from dependencies.
  all components related to Webview(local hosting, javascript message, view page...) are integrated using "flutter_inappwebview" package.

## 0.3.2

- fix "not callback when geocoding value is null"
- fix protocol error and update html file

## 0.3.1

- fix platform geocoding returns wrong coordinates.
- add kakao geocoding(optional)
- update docs

## 0.3.0

- provides latitude and logitude
- update docs

## 0.2.0

- add search w/ localhost server

## 0.1.3

- update README.md
- add Korean docs
- add 'userSelectedAddress' getter

## 0.1.2

- update docs typo

## 0.1.1

- update docs & fix android bug(can't listen callback)

## 0.1.0

- initial publish
