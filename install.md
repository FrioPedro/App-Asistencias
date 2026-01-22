# Install FVM

'''
dart pub global activate fvm
'''

Configurar el entorno de sistema en win

'''
%USERPROFILE%\AppData\Local\Pub\Cache\bin
''


Instalar version de flutter

fvm install 3.22.3

Confirmar que se esta en la version establecida

fvm flutter doctor -v

Cambiar SDK a la version de Android-34

seleciona la version de fvm

fvm use <version>


# Instalar FLutter proyecto nuevo

fvm flutter create --platforms=android --org com.friopacking --project-name app_asistencias .

