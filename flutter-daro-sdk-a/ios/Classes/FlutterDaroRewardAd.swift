import AppTrackingTransparency
import Foundation
import Daro
import UIKit

public class FlutterDaroRewardAdLoadListener {
    var onAdLoadSuccess: ((_ adItem: FlutterDaroRewardAd, _ ad: Any?, _ adInfo: Any?) -> Void)?
    var onAdLoadFail: ((_ error: DaroError) -> Void)?
    var onAdImpression: ((_ adInfo: Any?) -> Void)?
    var onAdClicked: ((_ adInfo: Any?) -> Void)?
    
    public init(
        onAdLoadSuccess: ((_ adItem: FlutterDaroRewardAd, _ ad: Any?, _ adInfo: Any?) -> Void)? = nil,
        onAdLoadFail: ((_ error: DaroError) -> Void)? = nil,
        onAdImpression: ((_ adInfo: Any?) -> Void)? = nil,
        onAdClicked: ((_ adInfo: Any?) -> Void)? = nil
    ) {
        self.onAdLoadSuccess = onAdLoadSuccess
        self.onAdLoadFail = onAdLoadFail
        self.onAdImpression = onAdImpression
        self.onAdClicked = onAdClicked
    }
    
    deinit {
        onAdLoadSuccess = nil
        onAdLoadFail = nil
        onAdImpression = nil
        onAdClicked = nil
    }
}

public class FlutterDaroRewardAdListener {
    var onShown: ((_ adInfo: Any?) -> Void)?
    var onRewarded: ((_ adInfo: Any?, _ reward: DaroRewardedItem?) -> Void)?
    var onDismiss: ((_ adInfo: Any?) -> Void)?
    var onFailedToShow: ((_ adInfo: Any?, _ error: DaroError) -> Void)?
    
    public init(
        onShown: ((_ adInfo: Any?) -> Void)? = nil,
        onRewarded: ((_ adInfo: Any?, _ reward: DaroRewardedItem?) -> Void)? = nil,
        onDismiss: ((_ adInfo: Any?) -> Void)? = nil,
        onFailedToShow: ((_ adInfo: Any?, _ error: DaroError) -> Void)? = nil
    ) {
        self.onShown = onShown
        self.onRewarded = onRewarded
        self.onDismiss = onDismiss
        self.onFailedToShow = onFailedToShow
    }
    
    deinit {
        onShown = nil
        onRewarded = nil
        onDismiss = nil
        onFailedToShow = nil
    }
}

// 광고 타입 정의
public enum FlutterDaroRewardAdType: String {
    case interstitial
    case rewardedVideo
    case popup
    case opening
    
    static func fromString(_ value: String?) -> FlutterDaroRewardAdType? {
        guard let value = value else { return nil }
        return FlutterDaroRewardAdType(rawValue: value)
    }
}

// Factory 클래스
public struct FlutterDaroRewardAdFactory {
    static func create(
        adType: FlutterDaroRewardAdType,
        adUnit: String,
        placement: String? = nil,
        options: [String: Any]? = nil,
        listener: FlutterDaroRewardAdLoadListener? = nil,
    ) -> FlutterDaroRewardAd {
        switch adType {
        case .interstitial:
            return FlutterDaroInterstitialAd(adUnit: adUnit, placement: placement, loadListener: listener)
        case .rewardedVideo:
            return FlutterDaroRewardedVideoAd(adUnit: adUnit, placement: placement, loadListener: listener)
        case .popup:
            return FlutterDaroPopupAd(adUnit: adUnit, placement: placement, loadListener: listener, options: options)
        case .opening:
            return FlutterDaroOpeningAd(adUnit: adUnit, placement: placement, loadListener: listener)
        }
    }
}

// 추상 광고 클래스
public class FlutterDaroRewardAd: UIViewController {
    // 상위 클래스에서 공통으로 관리하는 loader와 ad
    private var loader: Any?
    var ad: Any?
    
    // 공통 프로퍼티
    let adUnit: String
    let placement: String?
    var loadListener: FlutterDaroRewardAdLoadListener?
    
    // 각 구체 클래스에서 로더 생성 구현
    func createLoader() -> Any? {
        fatalError("createLoader() must be implemented by subclass")
    }
    
    // 각 구체 클래스에서 로더 구현
    func loadAdInternal(
        loader: Any,
        autoShow: Bool,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        fatalError("loadAdInternal() must be implemented by subclass")
    }
    
    // 각 구체 클래스에서 광고 리스너 설정 및 표시 구현
    func showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        fatalError("showAdInternal() must be implemented by subclass")
    }
    
    // 각 구체 클래스에서 광고 해제 구현
    func destroyAd(_ ad: Any?) {
        fatalError("destroyAd() must be implemented by subclass")
    }
    
    init(adUnit: String, placement: String? = nil, loadListener: FlutterDaroRewardAdLoadListener? = nil) {
        self.adUnit = adUnit
        self.placement = placement
        self.loadListener = loadListener
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupLoader() {
        loader = createLoader()
    }
    
    // 공통 로드 로직
    public func loadAd(autoShow: Bool = false, listener: FlutterDaroRewardAdListener? = nil, result: @escaping (Bool, Error?) -> Void) {
        if ad != nil {
            // 이미 로드된 광고가 있으면 바로 리턴
            loadListener?.onAdLoadSuccess?(self, ad, nil)
            result(true, nil)
            return
        }
        
        if loader == nil {
            setupLoader()
        }
        
        guard let currentLoader = loader else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create loader"]))
            return
        }
        
        loadAdInternal(loader: currentLoader, autoShow: autoShow, listener: listener, result: result)
    }
    
    // 공통 표시 로직
    public func showAd(listener: FlutterDaroRewardAdListener?, result: @escaping (Bool, Error?) -> Void) {
        guard let currentAd = ad else {
            loadAd(autoShow: true, listener: listener, result: result)
            return
        }
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                self?.showAdInternal(ad: currentAd, listener: listener, result: result)
            }
        } else {
            self.showAdInternal(ad: currentAd, listener: listener, result: result)
        }
    }
    
    // 공통 해제 로직
    public func destroy() {
        if let currentAd = ad {
            destroyAd(currentAd)
        }
        removeListeners()
        ad = nil
        loader = nil
        loadListener = nil
    }
    
    private func removeListeners() {
        // 리스너 nil 처리로 강한 참조 해제
        if let interstitialAd = ad as? DaroInterstitialAd {
            interstitialAd.interstitialListener.onShown = nil
            interstitialAd.interstitialListener.onDismiss = nil
            interstitialAd.interstitialListener.onFailedToShow = nil
        } else if let rewardedAd = ad as? DaroRewardedAd {
            rewardedAd.rewardedAdListener.onShown = nil
            rewardedAd.rewardedAdListener.onEarnedReward = nil
            rewardedAd.rewardedAdListener.onDismiss = nil
            rewardedAd.rewardedAdListener.onFailedToShow = nil
        } else if let popupAd = ad as? DaroLightPopupAd {
            popupAd.lightPopupAdListener.onShown = nil
            popupAd.lightPopupAdListener.onDismiss = nil
            popupAd.lightPopupAdListener.onFailedToShow = nil
        } else if let openingAd = ad as? DaroAppOpenAd {
            openingAd.appOpenAdListener.onShown = nil
            openingAd.appOpenAdListener.onDismiss = nil
            openingAd.appOpenAdListener.onFailedToShow = nil
        }
        // loader 타입별로 리스너 해제
        if let interstitialLoader = loader as? DaroInterstitialAdLoader {
            interstitialLoader.listener.onAdLoadSuccess = nil
            interstitialLoader.listener.onAdLoadFail = nil
            interstitialLoader.listener.onAdClicked = nil
            interstitialLoader.listener.onAdImpression = nil
        } else if let rewardedLoader = loader as? DaroRewardedAdLoader {
            rewardedLoader.listener.onAdLoadSuccess = nil
            rewardedLoader.listener.onAdLoadFail = nil
            rewardedLoader.listener.onAdClicked = nil
            rewardedLoader.listener.onAdImpression = nil
        } else if let popupLoader = loader as? DaroLightPopupAdLoader {
            popupLoader.listener.onAdLoadSuccess = nil
            popupLoader.listener.onAdLoadFail = nil
            popupLoader.listener.onAdClicked = nil
            popupLoader.listener.onAdImpression = nil
        } else if let openingLoader = loader as? DaroAppOpenAdLoader {
            openingLoader.listener.onAdLoadSuccess = nil
            openingLoader.listener.onAdLoadFail = nil
            openingLoader.listener.onAdClicked = nil
            openingLoader.listener.onAdImpression = nil
        }
    }
    
    deinit {
        destroy()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        destroy()
    }
}

// 전면 광고 클래스
class FlutterDaroInterstitialAd: FlutterDaroRewardAd {
    
    override func createLoader() -> Any? {
        let unit = DaroAdUnit(unitId: adUnit)
        return DaroInterstitialAdLoader(unit: unit)
    }
    
    override func loadAdInternal(
        loader: Any,
        autoShow: Bool,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let interstitialLoader = loader as? DaroInterstitialAdLoader else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid loader type"]))
            return
        }
        
        interstitialLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            self?.ad = ad
            self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
            
            if autoShow {
                self?.showAd(listener: listener) { success, error in
                    result(success, error)
                }
            } else {
                result(true, nil)
            }
        }
        
        interstitialLoader.listener.onAdLoadFail = { [weak self] error in
            self?.loadListener?.onAdLoadFail?(error)
            result(false, error)
        }
        
        interstitialLoader.listener.onAdImpression = { [weak self] adInfo in
            self?.loadListener?.onAdImpression?(adInfo)
        }
        
        interstitialLoader.listener.onAdClicked = { [weak self] adInfo in
            self?.loadListener?.onAdClicked?(adInfo)
        }
        
        interstitialLoader.loadAd()
    }
    
    override func showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let interstitialAd = ad as? DaroInterstitialAd else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ad type"]))
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller available"]))
            return
        }
        
        interstitialAd.interstitialListener.onShown = { adInfo in
            listener?.onShown?(adInfo)
        }
        
        interstitialAd.interstitialListener.onDismiss = { [weak self] adInfo in
            listener?.onDismiss?(adInfo)
            self?.destroy()
            result(true, nil)
        }
        
        interstitialAd.interstitialListener.onFailedToShow = { [weak self] adInfo, error in
            listener?.onFailedToShow?(adInfo, error)
            self?.destroy()
            result(false, error)
        }
        
        interstitialAd.show(viewController: rootViewController)
    }
    
    override func destroyAd(_ ad: Any?) {
        // DaroInterstitialAd는 destroy 메서드가 없을 수 있음
    }
}

// 리워드 비디오 광고 클래스
class FlutterDaroRewardedVideoAd: FlutterDaroRewardAd {
    
    override func createLoader() -> Any? {
        let unit = DaroAdUnit(unitId: adUnit)
        return DaroRewardedAdLoader(unit: unit)
    }
    
    override func loadAdInternal(
        loader: Any,
        autoShow: Bool,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let rewardedLoader = loader as? DaroRewardedAdLoader else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid loader type"]))
            return
        }
        
        rewardedLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            self?.ad = ad
            self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
            
            if autoShow {
                self?.showAd(listener: listener) { success, error in
                    result(success, error)
                }
            } else {
                result(true, nil)
            }
        }
        
        rewardedLoader.listener.onAdLoadFail = { [weak self] error in
            self?.loadListener?.onAdLoadFail?(error)
            self?.destroy()
            result(false, error)
        }
        
        rewardedLoader.listener.onAdImpression = { [weak self] adInfo in
            self?.loadListener?.onAdImpression?(adInfo)
        }
        
        rewardedLoader.listener.onAdClicked = { [weak self] adInfo in
            self?.loadListener?.onAdClicked?(adInfo)
        }
        
        rewardedLoader.loadAd()
    }
    
    override func showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let rewardedAd = ad as? DaroRewardedAd else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ad type"]))
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller available"]))
            return
        }
        
        var reward: DaroRewardedItem?
        
        rewardedAd.rewardedAdListener.onShown = { adInfo in
            listener?.onShown?(adInfo)
        }
        
        rewardedAd.rewardedAdListener.onEarnedReward = { adInfo, rewardedItem in
            listener?.onRewarded?(adInfo, rewardedItem)
            reward = rewardedItem
        }
        
        rewardedAd.rewardedAdListener.onDismiss = { [weak self] adInfo in
            listener?.onDismiss?(adInfo)
            self?.destroy()
            result(reward != nil, nil)
        }
        
        rewardedAd.rewardedAdListener.onFailedToShow = { [weak self] adInfo, error in
            listener?.onFailedToShow?(adInfo, error)
            self?.destroy()
            result(false, error)
        }
        
        rewardedAd.show(viewController: rootViewController)
    }
    
    override func destroyAd(_ ad: Any?) {
        // DaroRewardedAd는 destroy 메서드가 없을 수 있음
    }
}

// 팝업 광고 클래스
class FlutterDaroPopupAd: FlutterDaroRewardAd {
    private let options: [String: Any]?
    
    init(adUnit: String, placement: String? = nil, loadListener: FlutterDaroRewardAdLoadListener? = nil, options: [String: Any]? = nil) {
        self.options = options
        super.init(adUnit: adUnit, placement: placement, loadListener: loadListener)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createLoader() -> Any? {
        let unit = DaroAdUnit(unitId: adUnit)
        return DaroLightPopupAdLoader(unit: unit)
    }
    
    override func loadAdInternal(
        loader: Any,
        autoShow: Bool,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let popupLoader = loader as? DaroLightPopupAdLoader else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid loader type"]))
            return
        }
        
        popupLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            self?.ad = ad
            self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
            
            if autoShow {
                self?.showAd(listener: listener) { success, error in
                    result(success, error)
                }
            } else {
                result(true, nil)
            }
        }
        
        popupLoader.listener.onAdLoadFail = { [weak self] error in
            self?.loadListener?.onAdLoadFail?(error)
            self?.destroy()
            result(false, error)
        }
        
        popupLoader.listener.onAdImpression = { [weak self] adInfo in
            self?.loadListener?.onAdImpression?(adInfo)
        }
        
        popupLoader.listener.onAdClicked = { [weak self] adInfo in
            self?.loadListener?.onAdClicked?(adInfo)
        }
        
        popupLoader.loadAd()
    }

    
    // ARGB 형식의 Int/Long을 UIColor로 변환
    private func valueToUIColor(_ value: Any?, defaultValue: String) -> UIColor {
        if let intValue = value as? Int {
            let a = CGFloat((intValue >> 24) & 0xFF) / 255.0
            let r = CGFloat((intValue >> 16) & 0xFF) / 255.0
            let g = CGFloat((intValue >> 8) & 0xFF) / 255.0
            let b = CGFloat(intValue & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if let longValue = value as? Int64 {
            let a = CGFloat((longValue >> 24) & 0xFF) / 255.0
            let r = CGFloat((longValue >> 16) & 0xFF) / 255.0
            let g = CGFloat((longValue >> 8) & 0xFF) / 255.0
            let b = CGFloat(longValue & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if let stringValue = value as? String {
            return UIColor(hexCode: stringValue) ?? UIColor(hexCode: defaultValue) ?? UIColor.clear
        } else if let uiColor = value as? UIColor {
            return uiColor
        } else {
            return UIColor(hexCode: defaultValue) ?? UIColor.clear
        }
    }

    override func showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let popupAd = ad as? DaroLightPopupAd else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ad type"]))
            return
        }

        if let options = options {
            let configuration = DaroLightPopupConfiguration()
            configuration.backgroundColor = valueToUIColor(options["backgroundColor"], defaultValue: "#B2121416")
            configuration.cardViewBackgroundColor = valueToUIColor(options["containerColor"], defaultValue: "#121416")
            configuration.adMarkLabelTextColor = valueToUIColor(options["adMarkLabelTextColor"], defaultValue: "#F7FAFF")
            configuration.adMarkLabelBackgroundColor = valueToUIColor(options["adMarkLabelBackgroundColor"], defaultValue: "#3E434F")
            configuration.titleTextColor = valueToUIColor(options["titleColor"], defaultValue: "#F7FAFF")
            configuration.bodyTextColor = valueToUIColor(options["bodyColor"], defaultValue: "#B6BECC")
            configuration.ctaButtonTextColor = valueToUIColor(options["ctaTextColor"], defaultValue: "#FFFFFF")
            configuration.ctaButtonBackgroundColor = valueToUIColor(options["ctaBackgroundColor"], defaultValue: "#EB2640")
            configuration.closeButtonText = options["closeButtonText"] as? String ?? "Close"
            configuration.closeButtonTextColor = valueToUIColor(options["closeButtonColor"], defaultValue: "#F7FAFF")

            popupAd.configuration = configuration
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller available"]))
            return
        }
        
        popupAd.lightPopupAdListener.onShown = { adInfo in
            listener?.onShown?(adInfo)
        }
        
        popupAd.lightPopupAdListener.onDismiss = { [weak self] adInfo in
            listener?.onDismiss?(adInfo)
            self?.destroy()
            result(true, nil)
        }
        
        popupAd.lightPopupAdListener.onFailedToShow = { [weak self] adInfo, error in
            listener?.onFailedToShow?(adInfo, error)
            self?.destroy()
            result(false, error)
        }
        
        popupAd.show(viewController: rootViewController)
    }
    
    override func destroyAd(_ ad: Any?) {
        // DaroLightPopupAd는 destroy 메서드가 없을 수 있음
    }
}

// 앱 오프닝 광고 클래스
class FlutterDaroOpeningAd: FlutterDaroRewardAd {
    
    override func createLoader() -> Any? {
        let unit = DaroAdUnit(unitId: adUnit)
        return DaroAppOpenAdLoader(unit: unit)
    }
    
    override func loadAdInternal(
        loader: Any,
        autoShow: Bool,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let openingLoader = loader as? DaroAppOpenAdLoader else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid loader type"]))
            return
        }
        
        openingLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            self?.ad = ad
            self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
            
            if autoShow {
                self?.showAd(listener: listener) { success, error in
                    result(success, error)
                }
            } else {
                result(true, nil)
            }
        }
        
        openingLoader.listener.onAdLoadFail = { [weak self] error in
            self?.loadListener?.onAdLoadFail?(error)
            self?.destroy()
            result(false, error)
        }
        
        openingLoader.listener.onAdImpression = { [weak self] adInfo in
            self?.loadListener?.onAdImpression?(adInfo)
        }
        
        openingLoader.listener.onAdClicked = { [weak self] adInfo in
            self?.loadListener?.onAdClicked?(adInfo)
        }
        
        openingLoader.loadAd()
    }
    
    override func showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: @escaping (Bool, Error?) -> Void
    ) {
        guard let openingAd = ad as? DaroAppOpenAd else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ad type"]))
            return
        }
        
        openingAd.appOpenAdListener.onShown = { adInfo in
            listener?.onShown?(adInfo)
        }
        
        openingAd.appOpenAdListener.onDismiss = { [weak self] adInfo in
            listener?.onDismiss?(adInfo)
            self?.destroy()
            result(true, nil)
        }
        
        openingAd.appOpenAdListener.onFailedToShow = { [weak self] adInfo, error in
            listener?.onFailedToShow?(adInfo, error)
            self?.destroy()
            result(false, error)
        }
        
        openingAd.show()
    }
    
    override func destroyAd(_ ad: Any?) {
        // DaroAppOpenAd는 destroy 메서드가 없을 수 있음
    }
}
extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}