[![pub package](https://img.shields.io/pub/v/webview_flutter_kpostal.svg?label=webview_flutter_kpostal&color=blue)](https://pub.dev/packages/webview_flutter_kpostal)
[![Pub Likes](https://img.shields.io/pub/likes/webview_flutter_kpostal)](https://pub.dev/packages/webview_flutter_kpostal/score)
[![Test](https://github.com/TykanN/kpostal/actions/workflows/test.yml/badge.svg)](https://github.com/TykanN/kpostal/actions/workflows/test.yml)

[![English](https://img.shields.io/badge/Language-English-blueviolet?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-blueviolet?style=for-the-badge)](README.ko-kr.md)

# webview_flutter_kpostal에 대해

`webview_flutter_kpostal` 패키지는 [카카오 우편번호 서비스](https://postcode.map.daum.net/guide)를 이용해서 한국 도로명 주소/우편번호를 검색할 수 있습니다.  
더 이상 지원이 중단된 [Kopo](https://pub.dev/packages/kopo) 패키지를 참고하여 제작되었습니다.

> **[`webview_flutter`](https://pub.dev/packages/webview_flutter) 기반으로 동작합니다.**
> 이 패키지는 [`kpostal`](https://pub.dev/packages/kpostal)에서 `flutter_inappwebview` 의존성을
> Flutter 공식 플러그인인 `webview_flutter`로 교체한 포크입니다.
> 전환 배경과 마이그레이션 가이드는 [webview_flutter를 사용하는 이유](#webview_flutter를-사용하는-이유)를 참고하세요.

주소 검색 페이지는 **패키지에 번들**되어, `https` baseUrl 을 지정한
`WebViewController.loadHtmlString` 으로 로드됩니다. 원격 호스팅도, 로컬 HTTP 서버도 없으므로
별도의 플랫폼 설정 없이 바로 동작합니다.

선택한 주소의 경위도 정보도 제공합니다. iOS 및 Android 플랫폼이 제공하는 무료 지오코딩 서비스를 사용합니다. 이것은 사용에 제한이 있다는 것을 의미합니다. 자세한 내용은 [Apple docs for iOS](https://developer.apple.com/documentation/corelocation/clgeocoder), [Google docs for Android](https://developer.android.com/reference/android/location/Geocoder) 그리고 [geocoding](https://pub.dev/packages/geocoding) 플러그인을 참조하십시오.

Null-Safety를 지원합니다.

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## 시작하기

pubspec.yaml 파일에 `webview_flutter_kpostal`을 추가해주세요:

```yaml
dependencies:
  webview_flutter_kpostal:
```

## 플랫폼별 설정

**🧑🏻‍💻 iOS / Android 모두 추가 설정이 필요 없습니다.** 페이지를 번들 에셋에서 `https`로 로드하므로
`usesCleartextTraffic` 이나 `NSAppTransportSecurity` 설정이 필요하지 않습니다.

**[Android] 인터넷 권한이 있는지 확인해주세요** (번들 페이지가 카카오 우편번호 스크립트를 네트워크에서 불러옵니다):

```xml
// AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## 사용 예시

```dart
import 'package:webview_flutter_kpostal/webview_flutter_kpostal.dart';

// 콜백 기능으로 사용
TextButton(
    onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(
            builder: (_) => KpostalView(
                callback: (Kpostal result) {
                    print(result.address);
                    // result.latitude / result.longitude 는
                    // 플랫폼 지오코더로 채워집니다.
                },
            ),
        ));
    },
    child: Text('Search!'),
),

// 콜백 없이 결과값을 리턴 받아서 사용
TextButton(
    onPressed: () async {
        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
        print(result.address);
    },
    child: Text('Search!'),
),
```

## webview_flutter를 사용하는 이유

기존 [`kpostal`](https://pub.dev/packages/kpostal) 패키지는
[`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)에 의존합니다.
`webview_flutter_kpostal`은 이를 Flutter 팀이 공식 관리하는
[`webview_flutter`](https://pub.dev/packages/webview_flutter) 플러그인으로 교체했습니다.

전환 이유:

- **공식 1st-party 플러그인** — 장기 유지보수가 보장되고 새로운 Flutter / Gradle / iOS 툴체인 대응이 빠릅니다.
- **가벼운 네이티브 구성** — 전이 네이티브 의존성이 적고, 권한·매니페스트 영향 범위가 작습니다.
- **단순한 API** — 주소 검색에는 JavaScript 채널과 페이지 로드 콜백만 필요하며, `webview_flutter`가 이를 직접 지원합니다.
- **호스팅·로컬 서버 불필요** — 검색 페이지를 번들 에셋으로 포함해 `loadHtmlString`(임베드된 카카오 우편번호 iframe 이 부모로 응답할 수 있도록 `https` baseUrl 지정)으로 로드하므로, 원격 호스팅이나 런타임 `HttpServer`에 더 이상 의존하지 않습니다.

### 내부 변경 사항

| 항목 | `flutter_inappwebview` (kpostal) | `webview_flutter` (이 패키지) |
| --- | --- | --- |
| WebView 위젯 | `InAppWebView` | `WebViewWidget` + `WebViewController` |
| JS → Dart 브릿지 | `addWebMessageListener` / `addJavaScriptHandler` (`onComplete`) | `addJavaScriptChannel('onComplete', ...)` |
| 페이지 로드 완료 콜백 | `onLoadStop` | `NavigationDelegate.onPageFinished` |
| 페이지 호스팅 | 원격 GitHub Pages **또는** `InAppLocalhostServer` | 번들 에셋을 `loadHtmlString` + `https` baseUrl 로 로드 (원격·서버 없음) |

### `kpostal`에서 마이그레이션

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

`KpostalView`와 `Kpostal` 결과 모델은 대부분 동일하며, 다음 항목만 제거되었습니다.

- **`useLocalServer` / `localPort` 제거** — 항상 번들 에셋에서 로드하므로 불필요하며, 이들이 요구하던 cleartext / ATS 설정도 함께 사라졌습니다.
- **카카오 지오코딩 제거** (`kakaoKey`, `useKakaoGeocoder`, `kakaoLatitude` / `kakaoLongitude` 필드). 주소의 `latitude` / `longitude` 는 플랫폼 지오코더로 계속 제공됩니다.
