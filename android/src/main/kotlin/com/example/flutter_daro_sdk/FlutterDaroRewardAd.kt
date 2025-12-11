package com.example.flutter_daro_sdk

import android.app.Activity
import android.content.Context
import droom.daro.core.adunit.DaroAppOpenAdUnit
import droom.daro.core.adunit.DaroInterstitialAdUnit
import droom.daro.core.adunit.DaroLightPopupAdUnit
import droom.daro.core.adunit.DaroRewardedAdUnit
import droom.daro.core.listener.DaroAppOpenAdListener
import droom.daro.core.listener.DaroAppOpenAdLoaderListener
import droom.daro.core.listener.DaroInterstitialAdListener
import droom.daro.core.listener.DaroInterstitialAdLoaderListener
import droom.daro.core.listener.DaroLightPopupAdListener
import droom.daro.core.listener.DaroLightPopupAdLoaderListener
import droom.daro.core.listener.DaroRewardedAdListener
import droom.daro.core.listener.DaroRewardedAdLoaderListener
import droom.daro.core.model.DaroAdDisplayFailError
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroAppOpenAd
import droom.daro.core.model.DaroInterstitialAd
import droom.daro.core.model.DaroLightPopupAd
import droom.daro.core.model.DaroRewardedAd
import droom.daro.loader.DaroAppOpenAdLoader
import droom.daro.loader.DaroInterstitialAdLoader
import droom.daro.loader.DaroLightPopupAdLoader
import droom.daro.loader.DaroRewardedAdLoader

// 광고 타입 정의
enum class FlutterDaroRewardAdType(val value: String) {
    INTERSTITIAL("interstitial"),
    REWARDED_VIDEO("rewardedVideo"),
    POPUP("popup"),
    OPENING("opening");

    companion object {
        fun fromString(value: String?): FlutterDaroRewardAdType? {
            if(value == null) return null
            return entries.find { it.value == value }
        }
    }
}

// 광고 로드 리스너
interface FlutterDaroRewardAdLoadListener {
    fun onAdLoadSuccess(ad: FlutterDaroRewardAd, adInstance: Any?, adInfo: DaroAdInfo?) {}
    fun onAdLoadFail(error: Any) {}
}

// 광고 표시 리스너
interface FlutterDaroRewardAdListener {
    fun onShown(adInfo: DaroAdInfo) {}
    fun onRewarded(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {}
    fun onAdImpression(adInfo: DaroAdInfo) {}
    fun onAdClicked(adInfo: DaroAdInfo) {}
    fun onDismiss(adInfo: DaroAdInfo) {}
    fun onFailedToShow(adInfo: DaroAdInfo, error: Any) {}
}

class FlutterDaroRewardAd(
    private val adType: FlutterDaroRewardAdType,
    private val adUnit: String,
    private val placement: String? = null,
    private val context: Context,
    private var loadListener: FlutterDaroRewardAdLoadListener? = null
) {
    private var loader: Any? = null
    private var ad: Any? = null

    init {
        setupLoader()
    }

    // 광고 타입에 따라 알맞은 로더 인스턴스 생성
    private fun setupLoader() {
        loader = when (adType) {
            FlutterDaroRewardAdType.INTERSTITIAL -> {
                val unit = DaroInterstitialAdUnit(
                    key = adUnit,
                    placement = placement ?: ""
                )
                DaroInterstitialAdLoader(
                    context = context,
                    adUnit = unit
                )
            }
            FlutterDaroRewardAdType.REWARDED_VIDEO -> {
                val unit = DaroRewardedAdUnit(
                    key = adUnit,
                    placement = placement ?: ""
                )
                DaroRewardedAdLoader(
                    context = context,
                    adUnit = unit
                )
            }
            FlutterDaroRewardAdType.POPUP -> {
                val unit = DaroLightPopupAdUnit(
                    key = adUnit,
                    placement = placement ?: ""
                )
                DaroLightPopupAdLoader(
                    context = context,
                    adUnit = unit
                )
            }
            FlutterDaroRewardAdType.OPENING -> {
                val unit = DaroAppOpenAdUnit(
                    key = adUnit,
                    placement = placement ?: ""
                )
                DaroAppOpenAdLoader(
                    context = context,
                    adUnit = unit
                )
            }
        }
    }

    // 광고 로드 실행
    fun loadAd(
        autoShow: Boolean = false,
        listener: FlutterDaroRewardAdListener? = null,
        result: (Boolean, Any?) -> Unit
    ) {
        if (loader == null) {
            setupLoader()
        }

        when (val currentLoader = loader) {
            is DaroInterstitialAdLoader -> {
                currentLoader.setListener(object : DaroInterstitialAdLoaderListener {
                    override fun onAdLoadSuccess(ad: DaroInterstitialAd, adInfo: DaroAdInfo) {
                        this@FlutterDaroRewardAd.ad = ad
                        loadListener?.onAdLoadSuccess(this@FlutterDaroRewardAd, ad, adInfo)
                        
                        if (autoShow) {
                            showAd(listener) { success, error ->
                                result(success, error)
                            }
                        } else {
                            result(true, null)
                        }
                    }

                    override fun onAdLoadFail(err: DaroAdLoadError) {
                        val error = Exception(err.message)
                        loadListener?.onAdLoadFail(error)
                        result(false, error)
                    }
                })
                currentLoader.load()
            }
            is DaroRewardedAdLoader -> {
                currentLoader.setListener(object : DaroRewardedAdLoaderListener {
                    override fun onAdLoadSuccess(ad: DaroRewardedAd, adInfo: DaroAdInfo) {
                        this@FlutterDaroRewardAd.ad = ad
                        loadListener?.onAdLoadSuccess(this@FlutterDaroRewardAd, ad, adInfo)
                        
                        if (autoShow) {
                            showAd(listener) { success, error ->
                                result(success, error)
                            }
                        } else {
                            result(true, null)
                        }
                    }

                    override fun onAdLoadFail(err: DaroAdLoadError) {
                        val error = Exception(err.message)
                        loadListener?.onAdLoadFail(error)
                        result(false, error)
                    }
                })
                currentLoader.load()
            }
            is DaroLightPopupAdLoader -> {
                currentLoader.setListener(object : DaroLightPopupAdLoaderListener {
                    override fun onAdLoadSuccess(ad: DaroLightPopupAd, adInfo: DaroAdInfo) {
                        this@FlutterDaroRewardAd.ad = ad
                        loadListener?.onAdLoadSuccess(this@FlutterDaroRewardAd, ad, adInfo)
                        
                        if (autoShow) {
                            showAd(listener) { success, error ->
                                result(success, error)
                            }
                        } else {
                            result(true, null)
                        }
                    }

                    override fun onAdLoadFail(err: DaroAdLoadError) {
                        val error = Exception(err.message)
                        loadListener?.onAdLoadFail(error)
                        result(false, error)
                    }
                })
                currentLoader.load()
            }
            is DaroAppOpenAdLoader -> {
                currentLoader.setListener(object : DaroAppOpenAdLoaderListener {
                    override fun onAdLoadSuccess(ad: DaroAppOpenAd, adInfo: DaroAdInfo) {
                        this@FlutterDaroRewardAd.ad = ad
                        loadListener?.onAdLoadSuccess(this@FlutterDaroRewardAd, ad, adInfo)
                        
                        if (autoShow) {
                            showAd(listener) { success, error ->
                                result(success, error)
                            }
                        } else {
                            result(true, null)
                        }
                    }

                    override fun onAdLoadFail(err: DaroAdLoadError) {
                        val error = Exception(err.message)
                        loadListener?.onAdLoadFail(error)
                        result(false, error)
                    }
                })
                currentLoader.load()
            }
            else -> {
                result(false, Exception("Invalid ad type"))
            }
        }
    }

    // 광고 표시 처리
    fun showAd(
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        val currentActivity = context as? Activity
        if (currentActivity == null) {
            result(false, Exception("No activity available to show ad"))
            return
        }

        when (val currentAd = ad) {
            is DaroInterstitialAd -> {
                currentAd.setListener(object : DaroInterstitialAdListener {
                    override fun onAdImpression(adInfo: DaroAdInfo) {
                        listener?.onAdImpression(adInfo)
                    }

                    override fun onAdClicked(adInfo: DaroAdInfo) {
                        listener?.onAdClicked(adInfo)
                    }

                    override fun onShown(adInfo: DaroAdInfo) {
                        listener?.onShown(adInfo)
                    }

                    override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                        val exception = Exception(error.message)
                        listener?.onFailedToShow(adInfo, exception)
                        result(false, exception)
                    }

                    override fun onDismiss(adInfo: DaroAdInfo) {
                        listener?.onDismiss(adInfo)
                        result(true, null)
                    }
                })
                currentAd.show(activity = currentActivity)
            }
            is DaroRewardedAd -> {
                var reward: DaroRewardedAd.DaroRewardedItem? = null
                currentAd.setListener(object : DaroRewardedAdListener {
                    override fun onAdImpression(adInfo: DaroAdInfo) {
                        listener?.onAdImpression(adInfo)
                    }

                    override fun onAdClicked(adInfo: DaroAdInfo) {
                        listener?.onAdClicked(adInfo)
                    }

                    override fun onShown(adInfo: DaroAdInfo) {
                        listener?.onShown(adInfo)
                    }

                    override fun onEarnedReward(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {
                        reward = rewardItem
                        listener?.onRewarded(adInfo, rewardItem)
                    }

                    override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                        val exception = Exception(error.message)
                        listener?.onFailedToShow(adInfo, exception)
                        result(false, exception)
                    }

                    override fun onDismiss(adInfo: DaroAdInfo) {
                        listener?.onDismiss(adInfo)
                        result(reward != null, null)
                    }
                })
                currentAd.show(activity = currentActivity)
            }
            is DaroLightPopupAd -> {
                currentAd.setListener(object : DaroLightPopupAdListener {
                    override fun onAdImpression(adInfo: DaroAdInfo) {
                        listener?.onAdImpression(adInfo)
                    }

                    override fun onAdClicked(adInfo: DaroAdInfo) {
                        listener?.onAdClicked(adInfo)
                    }

                    override fun onShown(adInfo: DaroAdInfo) {
                        listener?.onShown(adInfo)
                    }

                    override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                        val exception = Exception(error.message)
                        listener?.onFailedToShow(adInfo, exception)
                        result(false, exception)
                    }

                    override fun onDismiss(adInfo: DaroAdInfo) {
                        listener?.onDismiss(adInfo)
                        result(true, null)
                    }
                })
                currentAd.show(activity = currentActivity)
            }
            is DaroAppOpenAd -> {
                currentAd.setListener(object : DaroAppOpenAdListener {
                    override fun onAdImpression(adInfo: DaroAdInfo) {
                        listener?.onAdImpression(adInfo)
                    }

                    override fun onAdClicked(adInfo: DaroAdInfo) {
                        listener?.onAdClicked(adInfo)
                    }

                    override fun onShown(adInfo: DaroAdInfo) {
                        listener?.onShown(adInfo)
                    }

                    override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                        val exception = Exception(error.message)
                        listener?.onFailedToShow(adInfo, exception)
                        result(false, exception)
                    }

                    override fun onDismiss(adInfo: DaroAdInfo) {
                        listener?.onDismiss(adInfo)
                        result(true, null)
                    }
                })
                currentAd.show(activity = context)
            }
            else -> {
                // 광고가 로드되지 않았으면 자동으로 로드 후 표시
                loadAd(autoShow = true, listener = listener, result = result)
            }
        }
    }

    // 광고 인스턴스 해제
    fun destroy() {
        when (val currentAd = ad) {
            is DaroInterstitialAd -> {
                currentAd.destroy()
            }
            is DaroRewardedAd -> {
                currentAd.destroy()
            }
            is DaroLightPopupAd -> {
                currentAd.destroy()
            }
            is DaroAppOpenAd -> {
                currentAd.destroy()
            }
        }
        
        ad = null
        loader = null
        loadListener = null
    }
}
