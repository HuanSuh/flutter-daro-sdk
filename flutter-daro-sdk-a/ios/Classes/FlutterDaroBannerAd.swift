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
                        // "details": error.code.name,
                    ])
                }
                self.adView?.listener.onAdImpression = {adInfo in
                    self.callback("onAdImpression", adUnit)
                }
                self.adView?.listener.onAdClicked = {adInfo in
                    self.callback("onAdClicked", adUnit)
                }
                self.view.addSubview(self.adView!)
                self.loadAd()
                return
            }
        }
        
        self.callback("onAdFailedToLoad", adUnit, data: [
            "code": -1,
            "message": "Invalid arguments : \(String(describing: args))"
        ])
    }
    
    private func loadAd() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                self?.adView?.loadAd()
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
