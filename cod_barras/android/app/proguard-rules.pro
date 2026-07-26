#Reglas necesarias para que mobile_scanner (y Google ML Kit, que usa por
#debajo para leer códigos de barras) no se rompa al compilar en modo release.
#Sin esto, R8 puede eliminar clases internas que el plugin
#necesita en tiempo de ejecución, causando NullPointerException aleatorios
#que no aparecen en modo debug.

-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode_bundled.** { *; }
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.odml.image.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_vision_barcode.**

#Reglas generales recomendadas por CameraX (usado también por mobile_scanner)
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
