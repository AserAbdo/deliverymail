# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep HTTP/HTTPS classes
-keep class org.apache.http.** { *; }
-keep class android.net.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.http.**

# Keep Dart HTTP packages
-keep class **.BuildConfig { *; }

# Keep Google Fonts
-keep class com.google.** { *; }
-dontwarn com.google.**

# Prevent R8 from stripping interface information
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
