import AppTrackingTransparency
import Foundation
import Daro
import Flutter

public class FlutterDaroBannerFactory: NSObject, FlutterPlatformViewFactory {
    
    var bannerView:FlutterDaroAdBannerView?
    var registrar:FlutterPluginRegistrar?
    private var messenger:FlutterBinaryMessenger
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = FlutterDaroBannerFactory(messenger: registrar.messenger())
        plugin.registrar = registrar
        registrar.register(plugin, withId: "flutter_daro_banner_view")
    }
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        self.bannerView = FlutterDaroAdBannerView(frame: frame, viewId: viewId, messenger: messenger, args: args)
        self.registrar?.addApplicationDelegate(self.bannerView!)
        return self.bannerView!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    public func applicationWillEnterForeground() {}
}

class FlutterDaroAdBannerView: NSObject, FlutterPlugin, FlutterPlatformView {
    
    static func register(with registrar: FlutterPluginRegistrar) { }
    
    private var controller:FlutterDaroBannerController
    
    deinit {
        NSLog("[dealloc] flutter_daro_banner_view")
    }
    
    init(frame:CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        /* set view properties */
        self.controller = FlutterDaroBannerController(viewId: viewId, messenger: messenger, args: args)
        super.init()
    }
    
    /* create native view */
    func view() -> UIView {
        return self.controller.view
    }
    
}

class FlutterDaroBannerController: UIViewController, FlutterStreamHandler {
    private var viewId: Int64?
    private var messenger: FlutterBinaryMessenger?
    
    /* Flutter event streamer properties */
    private var eventChannel: FlutterEventChannel?
    var flutterEventSink: FlutterEventSink?
    
    private var adUnit: String?
    private var adView: DaroAdBannerView?
    
    init(viewId: Int64, messenger:FlutterBinaryMessenger, args: Any?) {
        self.viewId = viewId
        self.messenger = messenger
        super.init(nibName: nil, bundle: nil)
        
        setupEventChannel(viewId: viewId, messenger: messenger)
        self.inflateAdView(args)
        // setupMethodChannel(viewId: viewId, messenger: messenger)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewId = nil
        self.messenger = nil
        super.init(coder: aDecoder)
    }
    
    
    /* set Flutter event channel */
    private func setupEventChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
        self.eventChannel = FlutterEventChannel(
            name: "com.daro.flutter_daro_sdk/events_" + String(viewId),
            binaryMessenger: messenger,
            codec: FlutterJSONMethodCodec.sharedInstance()
        )
       self.eventChannel!.setStreamHandler(self)
    }
    
    // /* set Flutter method channel */
    // private func setupMethodChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
    //     let nativeMethodsChannel = FlutterMethodChannel(
    //         name: "com.daro.flutter_daro_sdk/method_" + String(viewId),
    //         binaryMessenger: messenger
    //     );
    //     nativeMethodsChannel.setMethodCallHandler({
    //         (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
    //         else { result(FlutterMethodNotImplemented) }
    //     })
    // }
    
    // Inflate Ad View
    func inflateAdView(_ args: Any?) {
        /* data as JSON */
        if let parsedData = args as? [String: Any] {
            if let adUnit = parsedData["adUnit"] as? String, let adSizeValue = parsedData["adSize"] as? String {
                self.adUnit = adUnit
                let adSize: DaroAdBannerSize
                switch adSizeValue.lowercased() {
                    case "banner":
                        adSize = .banner
                    case "mrec":
                        adSize = .MREC
                    default:
                        adSize = .banner
                }
                self.adView = DaroAdBannerView(
                    unit: DaroAdUnit(unitId: adUnit),
                    bannerSize: adSize,
                    autoLoad: false
                )
                self.adView?.listener.onAdLoadSuccess = {ad, adInfo in
                    self.callback("onAdLoaded", adUnit)
                }
                self.adView?.listener.onAdLoadFail = {error in
                    self.callback("onAdFailedToLoad", adUnit, data: [
                        "code": error.code.rawValue,
                        "message": error.localizedDescription,
                    ])
                }
                self.adView?.listener.onAdImpression = {adInfo in
                    self.callback("onAdImpression", adUnit)
                }
                self.adView?.listener.onAdClicked = {adInfo in
                    self.callback("onAdClicked", adUnit)
                }
                // 배너 뷰가 컨테이너(PlatformView, Flutter가 320x50 / 300x250로 사이징)를
                // 가득 채우도록 Auto Layout 제약을 건다. (제약이 없으면 frame이 .zero라 보이지 않음)
                self.adView!.translatesAutoresizingMaskIntoConstraints = false
                // 클릭 시 랜딩을 띄울 presenting VC. self(배너 컨테이너 컨트롤러)를 넣으면
                // controller<->adView retain cycle이 생기므로, 키 윈도우의 root VC를 사용한다.
                self.adView!.rootViewController = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?.rootViewController
                self.view.addSubview(self.adView!)
                NSLayoutConstraint.activate([
                    self.adView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    self.adView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    self.adView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                    self.adView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                ])
                self.loadAd()
                return
            }
        }
        
        self.callback("onAdFailedToLoad", adUnit, data: [
            "code": 1001,
            "message": "INVALID_ARGUMENT",
            "details": "Invalid arguments : \(String(describing: args))"
        ])
    }
    
    private func loadAd() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                // ATT 콜백은 메인 스레드 보장이 없으므로 UIKit 호출은 메인에서 수행.
                DispatchQueue.main.async {
                    self?.adView?.loadAd()
                }
            }
        } else {
            self.adView?.loadAd()
        }
    }

    private func callback(_ event: String, _ adUnit: String?, data: [String:Any?] = [:]) {
        self.flutterEventSink?(["event": event, "adUnit": adUnit, "data": data])
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.flutterEventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.flutterEventSink = nil
        return nil
    }
}
