# ProGuard / R8 Configuration for Godot Engine 4.x Android Builds

# Keep all Godot engine core classes and plugin interfaces
-keep class com.godot.** { *; }
-keep class org.godotengine.** { *; }
-keep class ** extends org.godotengine.godot.plugin.GodotPlugin { *; }
-keep class ** extends org.godotengine.godot.GodotPlugin { *; }

# Keep Android framework components
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# Keep all JNI native methods and classes declaring them
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve attributes necessary for runtime reflection and debugging
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# Suppress harmless warnings from optional dependencies or build tools
-dontwarn org.godotengine.**
-dontwarn com.google.android.gms.**
-dontwarn androidx.**
