# Regenerar la Base de datos

fvm flutter pub run build_runner build --delete-conflicting-outputs

# Ver base datos modo Watch 

fvm flutter pub run build_runner watch

## Configurar ISAR

2) Fuerza isar_flutter_libs a 35 (comando para abrirlo)
notepad "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle"


Dentro, deja sí o sí:

android {
    compileSdkVersion 35
}


Si hay una línea tipo:

compileSdkVersion rootProject.ext.compileSdkVersion


cámbiala a 35 directo.

Guarda.