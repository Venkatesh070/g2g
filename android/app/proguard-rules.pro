# Keep Razorpay SDK
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*
-dontwarn proguard.annotation.**
-dontwarn com.razorpay.**

# Keep PhonePe IntentSDK
-keep class phonepe.intentsdk.** { *; }
-keep class com.phonepe.** { *; }

# Keep Flutter plugins that may use reflection
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep all classes with @Keep annotation
-keep class * { @androidx.annotation.Keep *; }

# Optional: Suppress warnings from old libraries
-dontwarn com.google.**
-dontwarn okhttp3.**
-dontwarn org.conscrypt.**

