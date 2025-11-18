# Rules for uCrop library which uses OkHttp and Okio
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }

# Keep OkHttp and Okio classes that uCrop depends on
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class okio.** { *; }
-keep interface okio.** { *; }
-dontwarn okio.**