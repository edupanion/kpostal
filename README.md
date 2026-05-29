[![pub package](https://img.shields.io/pub/v/webview_flutter_kpostal.svg?label=webview_flutter_kpostal&color=blue)](https://pub.dev/packages/webview_flutter_kpostal)
[![Pub Likes](https://img.shields.io/pub/likes/webview_flutter_kpostal)](https://pub.dev/packages/webview_flutter_kpostal/score)
[![Test](https://github.com/TykanN/kpostal/actions/workflows/test.yml/badge.svg)](https://github.com/TykanN/kpostal/actions/workflows/test.yml)

[![English](https://img.shields.io/badge/Language-English-9cf?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-9cf?style=for-the-badge)](README.ko-kr.md)

# About webview_flutter_kpostal

`webview_flutter_kpostal` can search for Korean postal addresses using the [Kakao postcode service](https://postcode.map.daum.net/guide).  
This package is inspired by the discontinued [Kopo](https://pub.dev/packages/kopo) package.

> **Built on [`webview_flutter`](https://pub.dev/packages/webview_flutter).**
> This is a fork of [`kpostal`](https://pub.dev/packages/kpostal) that replaces the
> `flutter_inappwebview` dependency with the official `webview_flutter` plugin.
> See [Why webview_flutter?](#why-webview_flutter) for the motivation and migration notes.

The search page is **bundled with the package** and loaded from assets via
`WebViewController.loadHtmlString` with an `https` base URL — there is no remote hosting and
no local HTTP server, so it works out of the box with zero platform setup.

It also provides the latitude / longitude of the selected address using the free Geocoding services provided by the iOS and Android platforms. This means that there are restrictions to their use. More information can be found in the [Apple documentation for iOS](https://developer.apple.com/documentation/corelocation/clgeocoder), the [Google documentation for Android](https://developer.android.com/reference/android/location/Geocoder), and the [geocoding](https://pub.dev/packages/geocoding) plugin.

Support Null-Safety!

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## Getting Started

Add `webview_flutter_kpostal` to your pubspec.yaml file:

```yaml
dependencies:
  webview_flutter_kpostal:
```

## Setup

**🧑🏻‍💻 No iOS or Android configuration is required.** The page is served from bundled
app assets over `https`, so there is no need for `usesCleartextTraffic` or
`NSAppTransportSecurity`.

**[Android] Make sure the internet permission is present** (the bundled page loads the Kakao
postcode script from the network):

```xml
// AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Example

```dart
import 'package:webview_flutter_kpostal/webview_flutter_kpostal.dart';

// Use callback.
TextButton(
    onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(
            builder: (_) => KpostalView(
                callback: (Kpostal result) {
                    print(result.address);
                    // result.latitude / result.longitude are filled
                    // via the platform geocoder.
                },
            ),
        ));
    },
    child: Text('Search!'),
),

// Not use callback.
TextButton(
    onPressed: () async {
        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
        print(result.address);
    },
    child: Text('Search!'),
),
```

## Why webview_flutter?

The original [`kpostal`](https://pub.dev/packages/kpostal) package depends on
[`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).
`webview_flutter_kpostal` replaces it with the officially maintained
[`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin (from the Flutter team).

Reasons for the switch:

- **Official, first-party plugin** — long-term maintenance and faster compatibility with new Flutter / Gradle / iOS toolchains.
- **Lighter native footprint** — fewer transitive native dependencies and a smaller permission/manifest surface.
- **Simpler API surface** — the address search needs only a JavaScript channel plus page-load callbacks, which `webview_flutter` covers directly.
- **No hosting, no local server** — the search page ships as a bundled asset and is loaded with `loadHtmlString` (using an `https` base URL so the embedded Kakao postcode iframe can post back), so the package no longer depends on remote hosting or a runtime `HttpServer`.

### What changed under the hood

| Concern | `flutter_inappwebview` (kpostal) | `webview_flutter` (this package) |
| --- | --- | --- |
| WebView widget | `InAppWebView` | `WebViewWidget` + `WebViewController` |
| JS → Dart bridge | `addWebMessageListener` / `addJavaScriptHandler` (`onComplete`) | `addJavaScriptChannel('onComplete', ...)` |
| Page-finished hook | `onLoadStop` | `NavigationDelegate.onPageFinished` |
| Page hosting | remote GitHub Pages **or** `InAppLocalhostServer` | bundled asset via `loadHtmlString` + `https` base URL (no remote, no server) |

### Migrating from `kpostal`

```yaml
# pubspec.yaml
dependencies:
-  kpostal: ^1.1.0
+  webview_flutter_kpostal: ^2.0.0
```

```dart
- import 'package:kpostal/kpostal.dart';
+ import 'package:webview_flutter_kpostal/webview_flutter_kpostal.dart';
```

`KpostalView` and the `Kpostal` result model are otherwise the same, with these removals:

- **Removed `useLocalServer` / `localPort`** — the page is always loaded from bundled assets, so these are no longer needed (and the cleartext / ATS settings they required are gone too).
- **Removed Kakao geocoding** (`kakaoKey`, `useKakaoGeocoder`, and the `kakaoLatitude` / `kakaoLongitude` fields). The address still returns `latitude` / `longitude` via the platform geocoder.
