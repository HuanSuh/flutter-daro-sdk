# DARO SDK ProGuard Rules
# Non-Reward 앱용 ProGuard 규칙
# Reward 앱의 경우 별도로 proguard를 설정하지 않아도 됩니다.

# ByteDance (Pangle)
-keep class com.bytedance.sdk.** { *; }

# PubNative
-keepattributes Signature
-keep class net.pubnative.** { *; }
-keep class com.iab.omid.library.pubnativenet.** { *; }

# Amazon
-keep class com.amazon.** { *; }

# Google Ads
-keep public class com.google.android.gms.ads.** {
    public *;
}
-keep class com.iabtcf.** {*;}

# Smaato
-keep public class com.smaato.sdk.** { *; }
-keep public interface com.smaato.sdk.** { *; }

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# IronSource
-keep class com.ironsource.adapters.** { *; }
-dontwarn com.ironsource.**
-dontwarn com.ironsource.adapters.**
-keepclassmembers class com.ironsource.** { public *; }
-keep public class com.ironsource.**
-keep class com.ironsource.adapters.** { *; }

# AppLovin
-keepclassmembers class com.applovin.sdk.AppLovinSdk {
    static *;
}
-keep public interface com.applovin.sdk** {*; }
-keep public interface com.applovin.adview** {*; }
-keep public interface com.applovin.mediation** {*; }
-keep public interface com.applovin.communicator** {*; }

# AndroidX
-keep class androidx.localbroadcastmanager.content.LocalBroadcastManager { *;}
-keep class androidx.recyclerview.widget.RecyclerView { *;}
-keep class androidx.recyclerview.widget.RecyclerView$OnScrollListener { *;}

# Activity
-keep class * extends android.app.Activity

# DARO SDK
-flattenpackagehierarchy droom.daro.a
-keep public class droom.daro.** {
    public protected *;
}
-keep interface droom.daro.** {
    public protected *;
}

# Kotlin Coroutines
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

