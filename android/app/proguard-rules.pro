# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefilemap SourceFile "com.example.app.R"

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Flutter engine classes
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep model classes
-keep class * extends java.io.Serializable { *; }
-keep class * implements java.io.Serializable { *; }

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep parcelable classes
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep BuildConfig
-keep class **.BuildConfig { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** i(...);
    public static *** d(...);
}

# Keep Socket.IO classes
-keep class io.socket.** { *; }
-keep class org.json.** { *; }
-keep class com.github.nkzawa.** { *; }

# Keep image picker classes
-keep class com.fluttercandies.photo_manager.** { *; }

# Keep file picker classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
