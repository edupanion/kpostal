library;

export 'src/kpostal_model.dart';
export 'src/constant.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:webview_flutter_kpostal/src/kpostal_model.dart';
import 'package:webview_flutter_kpostal/src/log.dart';

class KpostalView extends StatefulWidget {
  static const String routeName = '/kpostal';

  /// AppBar's title
  ///
  /// 앱바 타이틀
  final String title;

  /// AppBar's background color
  ///
  /// 앱바 배경색
  final Color appBarColor;

  /// AppBar's contents color
  ///
  /// 앱바 아이콘, 글자 색상
  final Color titleColor;

  /// this callback function is called when user selects addresss.
  ///
  /// 유저가 주소를 선택했을 때 호출됩니다.
  final void Function(Kpostal result)? callback;

  /// build custom AppBar.
  ///
  /// 커스텀 앱바를 추가할 수 있습니다. 추가할 경우 다른 관련 속성은 무시됩니다.
  final PreferredSizeWidget? appBar;

  /// 웹뷰 로딩 시 인디케이터 색상
  final Color loadingColor;

  /// 웹뷰 로딩 시 표시할 커스텀 위젯
  ///
  /// 해당 옵션 사용 시, 기존 인디케이터를 대체하며, [loadingColor] 옵션은 무시됩니다.
  final Widget? onLoading;

  const KpostalView({
    super.key,
    this.title = '주소검색',
    this.appBarColor = Colors.white,
    this.titleColor = Colors.black,
    this.appBar,
    this.callback,
    this.loadingColor = Colors.blue,
    this.onLoading,
  });

  @override
  State<KpostalView> createState() => _KpostalViewState();
}

class _KpostalViewState extends State<KpostalView> {
  /// 패키지에 번들된 카카오 우편번호 검색 페이지(에셋) 키.
  ///
  /// 패키지에서 선언한 에셋은 `packages/<package_name>/...` 경로로 번들됩니다.
  static const String _assetPath =
      'packages/webview_flutter_kpostal/assets/kakao_postcode.html';

  /// 번들 HTML 을 로드할 때 부여할 origin.
  ///
  /// 카카오(다음) 우편번호 위젯은 내부적으로 `postcode.map.daum.net` iframe 을 띄우고,
  /// 주소 선택 시 그 iframe 이 부모 페이지로 `postMessage` 를 보내 `oncomplete` 를
  /// 호출합니다. 이 통신은 부모 페이지가 실제 http(s) origin 을 가져야 동작하므로,
  /// `file://` 가 되는 [WebViewController.loadFlutterAsset] 대신
  /// [WebViewController.loadHtmlString] 에 https baseUrl 을 지정해 로드합니다.
  /// iframe 도메인과 동일하게 맞춰 same-origin 으로 동작시킵니다.
  static const String _baseUrl = 'https://postcode.map.daum.net';

  late final WebViewController _controller;

  bool initLoadComplete = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'onComplete',
        onMessageReceived: (JavaScriptMessage message) =>
            handleMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              initLoadComplete = true;
            });
          },
        ),
      );

    _loadPostcodePage();
  }

  /// 번들된 우편번호 페이지를 https origin 으로 로드합니다.
  Future<void> _loadPostcodePage() async {
    final String html = await rootBundle.loadString(_assetPath);
    await _controller.loadHtmlString(html, baseUrl: _baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: widget.appBarColor,
            title: Text(
              widget.title,
              style: TextStyle(
                color: widget.titleColor,
              ),
            ),
            iconTheme:
                Theme.of(context).iconTheme.copyWith(color: widget.titleColor),
          ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          initLoadComplete
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: widget.onLoading ??
                        CircularProgressIndicator(color: widget.loadingColor),
                  ),
                ),
        ],
      ),
    );
  }

  void handleMessage(String? message) async {
    final navigator = Navigator.of(context);
    try {
      if (message != null) {
        log(message);
        Kpostal result = Kpostal.fromJson(jsonDecode(message));

        Location? latLng = await result.latLng;

        if (latLng != null) {
          result.latitude = latLng.latitude;
          result.longitude = latLng.longitude;
        }
        widget.callback?.call(result);
        navigator.pop(result);
      } else {
        throw 'fail to load message : message is null';
      }
    } catch (e) {
      navigator.pop();
    }
  }
}
