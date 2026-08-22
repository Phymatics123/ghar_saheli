# Keep rules for the release build.
#
# Flutter's own plugin contributes the engine's rules automatically, so this
# file only covers what this app adds on top.

# The updater's method channel is reached by name from Dart. R8 has no way to
# see that call and would otherwise be free to rename or remove the class.
-keep class com.gharsaheli.ghar_saheli.MainActivity { *; }

# FileProvider is named as a string in AndroidManifest.xml rather than
# referenced in code, so nothing points R8 at it.
-keep class androidx.core.content.FileProvider { *; }

# sqlite3_flutter_libs loads its native library through JNI.
-keep class com.tekartik.** { *; }

# Suppress warnings for optional desugaring classes that are not present at
# runtime on the API levels this app supports.
-dontwarn java.lang.invoke.**
