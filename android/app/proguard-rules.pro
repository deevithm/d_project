# TensorFlow Lite ProGuard Rules
# Keep TensorFlow Lite GPU classes
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep GPU delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep TensorFlow Lite model classes
-keep class com.google.android.gms.tflite.** { *; }
-dontwarn com.google.android.gms.tflite.**

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
