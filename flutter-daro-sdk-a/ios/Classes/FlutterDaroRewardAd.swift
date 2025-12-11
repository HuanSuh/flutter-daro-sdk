import Daro

public class FlutterDaroRewardAdLoadListener {
    var onAdLoadSuccess: ((_ adItem: FlutterDaroRewardAd, _ ad: Any?, _ adInfo: Any?) -> Void)?
    var onAdLoadFail: ((_ error: Error) -> Void)?
    var onAdImpression: ((_ adInfo: Any?) -> Void)?
    var onAdClicked: ((_ adInfo: Any?) -> Void)?
    
    public init(
        onAdLoadSuccess: ((_ adItem: FlutterDaroRewardAd, _ ad: Any?, _ adInfo: Any?) -> Void)? = nil,
        onAdLoadFail: ((_ error: Error) -> Void)? = nil,
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
    var onFailedToShow: ((_ adInfo: Any?, _ error: Error) -> Void)?
    
    public init(
        onShown: ((_ adInfo: Any?) -> Void)? = nil,
        onRewarded: ((_ adInfo: Any?, _ reward: DaroRewardedItem?) -> Void)? = nil,
        onDismiss: ((_ adInfo: Any?) -> Void)? = nil,
        onFailedToShow: ((_ adInfo: Any?, _ error: Error) -> Void)? = nil
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
}

public class FlutterDaroRewardAd: UIViewController {
    private var adType: FlutterDaroRewardAdType
    private var adUnit: String
    private var placement: String?
    private var loader: Any?
    private var ad: Any?

    // 광고 리스너
    var loadListener: FlutterDaroRewardAdLoadListener?
    
    public init(
        adType: FlutterDaroRewardAdType, 
        adUnit: String, 
        placement: String? = nil, 
        listener: FlutterDaroRewardAdLoadListener? = nil) {
            self.adType = adType
            self.adUnit = adUnit
            self.placement = placement
            self.loadListener = listener
            super.init(nibName: nil, bundle: nil)
            setupLoader()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 광고 타입에 따라 알맞은 로더 인스턴스 생성
    private func setupLoader() {
        switch adType {
        case .interstitial:
            let unit = DaroAdUnit(unitId: adUnit)
            self.loader = DaroInterstitialAdLoader(unit: unit)
        case .rewardedVideo:
            let unit = DaroAdUnit(unitId: adUnit)
            self.loader = DaroRewardedAdLoader(unit: unit)
        case .popup:
            let unit = DaroAdUnit(unitId: adUnit)
            self.loader = DaroLightPopupAdLoader(unit: unit)
        case .opening:
            let unit = DaroAdUnit(unitId: adUnit)
            self.loader = DaroAppOpenAdLoader(unit: unit)
        }
    }
    
    // 광고 로드 실행
    public func loadAd(autoShow: Bool = false, listener: FlutterDaroRewardAdListener? = nil, result: @escaping (Bool, Error?) -> Void) {
        if self.loader == nil {
            self.setupLoader()
        }
        if let interstitialLoader = self.loader as? DaroInterstitialAdLoader {
            interstitialLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
                self?.ad = ad
                self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
                // 즉시 노출 옵션이 true일 경우 광고 표시
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
        } else if let rewardedLoader = self.loader as? DaroRewardedAdLoader {
            rewardedLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
                self?.ad = ad
                self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
                // 즉시 노출 옵션이 true일 경우 광고 표시
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
                result(false, error)
            }
            rewardedLoader.listener.onAdImpression = { [weak self] adInfo in
                self?.loadListener?.onAdImpression?(adInfo)
            }
            rewardedLoader.listener.onAdClicked = { [weak self] adInfo in
                self?.loadListener?.onAdClicked?(adInfo)
            }

            rewardedLoader.loadAd()
        } else if let popupLoader = self.loader as? DaroLightPopupAdLoader {
            popupLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
                self?.ad = ad
                self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
                // 즉시 노출 옵션이 true일 경우 광고 표시
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
                result(false, error)
            }
            popupLoader.listener.onAdImpression = { [weak self] adInfo in
                self?.loadListener?.onAdImpression?(adInfo)
            }
            popupLoader.listener.onAdClicked = { [weak self] adInfo in
                self?.loadListener?.onAdClicked?(adInfo)
            }
            
            popupLoader.loadAd()
        } else if let openingLoader = self.loader as? DaroAppOpenAdLoader {
            openingLoader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
                self?.ad = ad
                self?.loadListener?.onAdLoadSuccess?(self!, ad, adInfo)
                // 즉시 노출 옵션이 true일 경우 광고 표시
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
                result(false, error)
            }
            openingLoader.listener.onAdImpression = { [weak self] adInfo in
                self?.loadListener?.onAdImpression?(adInfo)
            }
            openingLoader.listener.onAdClicked = { [weak self] adInfo in
                self?.loadListener?.onAdClicked?(adInfo)
            }
            openingLoader.loadAd()
        } else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ad type"]))
        }
    }

    // 광고 표시 처리
    public func showAd(listener: FlutterDaroRewardAdListener?, result: @escaping (Bool, Error?) -> Void) {
        // rootViewController 가져오기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            result(false, NSError(domain: "FlutterDaroRewardAd", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller available"]))
            return
        }
        
        // 광고 타입별로 실제 광고 표시 함수 호출 및 리스너 연결
        if let interstitialAd = self.ad as? DaroInterstitialAd {
            interstitialAd.interstitialListener.onShown = { adInfo in
                listener?.onShown?(adInfo)
            }
            interstitialAd.interstitialListener.onDismiss = { adInfo in
                listener?.onDismiss?(adInfo)
                result(true, nil)
            }
            interstitialAd.interstitialListener.onFailedToShow = { adInfo, error in
                listener?.onFailedToShow?(adInfo, error)
                result(false, error)
            }
            // Interstitial 광고 표시 - rootViewController 사용
            interstitialAd.show(viewController: rootViewController)
        } else if let rewardedAd = self.ad as? DaroRewardedAd {
            var reward: DaroRewardedItem?
            rewardedAd.rewardedAdListener.onShown = { adInfo in
                listener?.onShown?(adInfo)
            }
            rewardedAd.rewardedAdListener.onEarnedReward = { adInfo, rewardedItem in
                listener?.onRewarded?(adInfo, rewardedItem)
                reward = rewardedItem
            }
            rewardedAd.rewardedAdListener.onDismiss = { adInfo in
                listener?.onDismiss?(adInfo)
                result(reward != nil, nil)
            }
            rewardedAd.rewardedAdListener.onFailedToShow = { adInfo, error in
                listener?.onFailedToShow?(adInfo, error)
                result(false, error)
            }
            // Rewarded Video 광고 표시 - rootViewController 사용
            rewardedAd.show(viewController: rootViewController)
        } else if let popupAd = self.ad as? DaroLightPopupAd {
            popupAd.lightPopupAdListener.onShown = { adInfo in
                listener?.onShown?(adInfo)
            }
            popupAd.lightPopupAdListener.onDismiss = { adInfo in
                listener?.onDismiss?(adInfo)
                result(true, nil)
            }
            popupAd.lightPopupAdListener.onFailedToShow = { adInfo, error in
                listener?.onFailedToShow?(adInfo, error)
                result(false, error)
            }
            // Popup 광고 표시 - rootViewController 사용
            popupAd.show(viewController: rootViewController)
        } else if let openingAd = self.ad as? DaroAppOpenAd {
            openingAd.appOpenAdListener.onShown = { adInfo in
                listener?.onShown?(adInfo)
            }
            openingAd.appOpenAdListener.onDismiss = { adInfo in
                listener?.onDismiss?(adInfo)
            }
            openingAd.appOpenAdListener.onFailedToShow = { adInfo, error in
                listener?.onFailedToShow?(adInfo, error)
            }
            // Opening 광고 표시
            openingAd.show()
        } else {
            self.loadAd(autoShow: true, listener: listener, result: result)
        }
    }

    deinit {
        self.destroy()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.destroy()
    }

    public func destroy() {
        removeListeners()
        self.loader = nil
        self.ad = nil
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
        self.loadListener = nil
    }
}
