::                                 _____             _____               _         _     
::                          ____  |_   _|           |  __ \             | |       | |    
::                         / __ \   | |   _ __ ___  | |__) |__ _ __   __| |  ___  | |__  
::                        / / _` |  | |  | '_ ` _ \ |  ___// _` |\ \ / /| | / _ \ | '_ \ 
::                       | | (_| | _| |_ | | | | | || |   | (_| | \ V / | || (_) || | | |
::                        \ \__,_||_____||_| |_| |_||_|    \__,_|  \_/  |_| \___/ |_| |_|
::                         \____/                                                        
::                                          Versión 1.0 - Licencia Mit                       

::                              Script de automatización de proyectos Maven en Java

:: Este script realiza las siguientes tareas de forma automática a través de acceso remoto:
:: 1. Limpieza del proyecto: Elimina los artefactos generados en compilaciones anteriores para asegurar una compilación limpia.
:: 2. Instalación de dependencias: Descarga e instala todas las dependencias necesarias para el script y el proyecto utilizando Curl y Maven.
:: 3. Compilación del proyecto: Compila el código fuente del proyecto Maven para generar un archivo ejecutable JAR. ~ Se podría modificar para generar archivos War mediante perfiles en pom.xml y luego cuando se quiera compilar usar el atributo -Pwar o -Pjar
:: 4. Verificación de archivo: Comprueba que exista el archivo Jar buscando el archivo creado o modificado más reciente.
:: 5. Verificación de servicios: Antes de proceder con el despliegue, el script verifica que los servicios Apache y Tomcat estén activos y funcionando correctamente en el servidor destino. [beta]
:: 6. Transferencia del archivo JAR: Utiliza SSH (plink + plink) para subir el archivo JAR compilado al servidor de destino.
:: 7. Despliegue del proyecto: Realiza las acciones necesarias para desplegar el archivo JAR en el servidor, asegurando que se integre correctamente con los servicios de Tomcat y Apache.
:: 8. Despliegue automático: Mediante crontab la web se iniciará automáticamente al iniciarse el servidor. [beta]

:: Nota: Este script requiere que el usuario tenga configurados los accesos SSH previamente y que tenga los permisos adecuados para realizar operaciones en el servidor destino. Además de tener lista la base de datos en local (usuario, contraseña y base de datos creada)
:: Antes de ejecutarlo comprueba que están todos los datos correctamentes completados para evitar problemas.


@echo off
setlocal enabledelayedexpansion

:: Completar los siguientes datos correctamente
set "SERVER=usuario@servidor"
set "REMOTEDIR=/ruta/"
set "URL=http://ejemplo.com"
set "IP=127.0.0.1:8080"
set "HOSTKEY=ssh-ed25519 255 SHA256:clave"

:: Esto no necesita cambios si se ejecuta desde el directorio raíz del proyecto
set "JAR_DIR=./target/"
set "MAVEN=./mvnw.cmd"
set "POM=./pom.xml"
set "LOG_FILE=./log.txt"

:: No cambiar los enlaces ~ Este script solo funciona en dispositivos Windows 10-11 64 bits por seguridad
set "PLINK_URL=https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe"
set "PSCP_URL=https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe"
set "DOWNLOAD_DIR=%~dp0"

:: Inicialización del entorno y registro del log (se puede ver en log.txt)
call :initializeEnvironment

:: Operaciones con Maven
call :mavenOperation clean "Realizando limpieza del proyecto..."
call :mavenOperation install "Instalando dependencias..."
call :mavenOperation compile "Compilando el proyecto en Jar..."

:: Comprobar que el archivo Jar exista
call :checkJar

:: Comprobar el puerto 8080 para Tomcat (puede haber conflicto)
call :checkTomcat

:: Deploy de archivo (subida al servidor, administración de Apache y ejecución de archivo Jar ~ Java)
call :executeJar
exit

:initializeEnvironment
%SystemRoot%\System32\mode.com con: cols=50 lines=40
chcp 65001
color 0E
cls

echo ╔════════════════════════════════════════════════╗
echo ║             %date% %time%             ║
echo Registro de actividades iniciado el %date% %time% >> "!LOG_FILE!"
echo ╚══════════ Automatizando los procesos ══════════╝
echo.

:: comprueba y descarga Plink y PSCP si no están presentes
:: ~ si no funciona descargarlo manualmente ~
call :downloadTools plink PLINK_URL
call :downloadTools pscp PSCP_URL

:: Solicita la contraseña SSH una vez
:contraseñassh
:: -> no borrar esta linea <-
echo   ·  Por favor escribe la contraseña SSH:
set /p SSHPASS="»»»  "
echo.
echo   »  Verificando la contraseña SSH...
echo   »  Verificando la contraseña SSH... >> "!LOG_FILE!"

:: Conexión SSH de prueba usando Plink para comprobar la contraseña
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "exit" >nul 2>&1

if !errorlevel! neq 0 (
    echo   □  La contraseña SSH es incorrecta.
    echo   □  Error: La contraseña SSH proporcionada es incorrecta. >> "!LOG_FILE!"
    echo.
    goto contraseñassh
)
echo   ■  Contraseña SSH correcta.
echo   ■  La contraseña SSH es correcta. >> "!LOG_FILE!"
echo.

:: Solicita la contraseña SSH una vez
:contraseñasudo
:: -> no borrar esta linea <-
echo   ·  Por favor escribe la contraseña para SUDO:
set /p SUDOPASS="»»»  "
echo.
echo   »  Verificando la contraseña para SUDO...
echo   »  Verificando la contraseña para SUDO... >> "!LOG_FILE!"

:: Ejecución de un comando trivial con sudo para comprobar la contraseña
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "echo %SUDOPASS% | sudo -S whoami" >nul 2>&1

if !errorlevel! neq 0 (
    echo   □  La contraseña para SUDO es incorrecta.
    echo   □  Error: La contraseña para SUDO proporcionada es incorrecta. >> "!LOG_FILE!"
    echo.
    goto contraseñasudo
)
echo   ■  Contraseña para SUDO correcta.
echo   ■  La contraseña para SUDO es correcta. >> "!LOG_FILE!"
echo.

if "!SERVER!"=="" (
    echo   □  No se ha especificado el servidor.
    echo   □  Error: No se ha especificado el servidor. >> "!LOG_FILE!"
    exit /b 1
)

echo   »  Inicialización completada.
echo.
exit /b

:mavenOperation
echo   »  %~2
echo.
echo   »  %~2 >> "!LOG_FILE!"
call "!MAVEN!" %1 -f "!POM!" >> "!LOG_FILE!" 2>&1
if !errorlevel! neq 0 (
    echo   □  Error en la operación Maven: %1.
    echo   □  Error en la operación Maven: %1. >> "!LOG_FILE!"
    echo   □  Comprueba el historial ~ !LOG_FILE!
    pause
    exit /b !errorlevel!
)
exit /b

:checkTomcat
echo   »  Comprobando Tomcat...
echo   »  Comprobando Tomcat... >> "!LOG_FILE!"
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "netstat -an | grep ':8080' | grep LISTEN" > nul 2>&1
if not errorlevel 1 (
    echo   □  El servicio Tomcat está activo.
    echo   □  El servicio Tomcat está activo. >> "!LOG_FILE!"
    echo   ·  ¿Quieres detener el servicio? s/n
    set /p userResp="»»»  "
    echo.
    if /i "!userResp!"=="s" (
        echo   »  Deteniendo Tomcat...
        :: se podría mejorar para detectar la versión de tomcat ya que esto puede fallar
        plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "echo %SUDOPASS% | sudo -S systemctl stop tomcat9" > nul 2>&1
        if !errorlevel! neq 0 (
            echo   □  Error al detener Tomcat.
            echo   □  Error al detener Tomcat. >> "!LOG_FILE!"
            pause
            exit /b !errorlevel!
        ) else (
            echo   ■  Tomcat detenido exitosamente.
            echo   ■  Tomcat detenido exitosamente. >> "!LOG_FILE!"
            echo.
            exit /b
        )
    ) else (
        echo   ·  Script finalizado.
        echo   ·  Script finalizado. >> "!LOG_FILE!"
        pause
        exit
    )
) else (
    echo   ■  El servicio Tomcat está inactivo.
    echo   ■  El servicio Tomcat está inactivo. >> "!LOG_FILE!"
    echo.
    exit /b
)

:checkPort8080
echo.
echo   »  Comprobando Apache...
echo   »  Comprobando el servicio Apache2... >> "!LOG_FILE!"
:: comprueba si está activo apache2
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "systemctl is-active apache2" > nul 2>&1
if !errorlevel! neq 0 (
    echo   □  El servicio Apache está activo.
    echo   □  El servicio Apache está activo. >> "!LOG_FILE!"
    echo   ·  ¿Quieres detener el servicio? s/n
    set /p userResp="»»»  "
    echo.
    if /i "!userResp!"=="s" (
        call :stopServer
        call :deployJarApache
    ) else (
        echo.
        echo   ·  Script finalizado sin ejecutar Apache.
        echo   ·  El script se completó sin ejecutar el archivo en Apache. >> "!LOG_FILE!"
        pause
        exit /b 0
    )
) else (
    echo   ■  El servicio Apache está inactivo.
    echo   ■  El servicio Apache está inactivo. >> "!LOG_FILE!"
    echo.
    :: Despliegue del archivo JAR
    call :deployJarApache
)

:stopServer
echo.
echo   »  Deteniendo Apache...
echo   »  Deteniendo Apache... >> "!LOG_FILE!"
:: detiene apache2 para ejecutar el archivo Java sin problemas en el puerto 8080
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "echo %SUDOPASS% | sudo -S systemctl stop apache2" > nul 2>&1
if !errorlevel! neq 0 (
    echo   □  Error al detener Apache.
    echo   □  Error al detener Apache. >> "!LOG_FILE!"
    pause
    exit /b !errorlevel!
) else (
    echo   ■  Apache detenido exitosamente.
    echo   ■  Apache detenido exitosamente. >> "!LOG_FILE!"
    echo.
    exit /b
)

:checkJar
echo   »  Buscando el archivo Jar...
echo   »  Buscando el archivo Jar más nuevo... >> "!LOG_FILE!"
:: Busca el archivo JAR más reciente
for /f "delims=" %%i in ('dir "!JAR_DIR!\*.jar" /b /od /a-d') do set "JARFILE=%%i"

if not "!JARFILE!"=="" (
    echo   ■  Archivo Jar encontrado:
    echo   ·  !JARFILE!
    echo   ■  Último archivo Jar encontrado: !JARFILE! >> "!LOG_FILE!"
    echo.
    exit /b
) else (
    echo   □  Hubo un problema con el archivo Jar.
    echo   □  Hubo un problema con el archivo Jar. >> "!LOG_FILE!"
    exit
    pause
)

echo !JARFILE!
echo   »  Subiendo el archivo al servidor...
echo   »  Subiendo el archivo al servidor... >> "!LOG_FILE!"
:: Sube el archivo al servidor usando pscp
pscp -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" "!JAR_DIR!\!JARFILE!" %SERVER%:%REMOTEDIR% >> "!LOG_FILE!"
if !errorlevel! neq 0 (
    echo   □  Error al subir el archivo al servidor.
    echo   □  Error al subir el archivo al servidor. >> "!LOG_FILE!"
    pause
    exit /b !errorlevel!
) else (
    echo   ■  Archivo subido exitosamente.
    echo   ■  Archivo subido exitosamente. >> "!LOG_FILE!"
    echo.
    exit /b
)

:deployJarApache
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "echo %SUDOPASS% | sudo -S systemctl start apache2"  > nul 2>&1
if !errorlevel! neq 0 (
    echo   □  Error al arrancar Apache.
    echo   □  Error al arrancar Apache. >> "!LOG_FILE!"
    pause
    exit /b !errorlevel!
) else (
    echo   ■  Apache arrancado exitosamente.
    echo   ■  Apache arrancado exitosamente. >> "!LOG_FILE!"
    echo.
    :: Finalización
    call :logFooter
)

:: Crontab (para que se inicie automáticamente en el servidor cuando se inicia) ~ mejorable con otras alternativas
:configureCronJob
echo   »  Configurando crontab...
echo   »  Configurando tarea cron para ejecución automática al inicio... >> "!LOG_FILE!"
:: Añadir una nueva línea a crontab si no existe
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "crontab -l | { cat; echo '@reboot nohup java -jar %REMOTEDIR%!JARFILE! > /dev/null 2>&1 &'; } | crontab -"
if !errorlevel! neq 0 (
    echo   □  Error al configurar crontab.
    echo   □  Error al configurar la tarea cron. >> "!LOG_FILE!"
    pause
    exit /b !errorlevel!
) else (
    echo   ■  Crontab configurado exitosamente.
    echo   ■  Tarea cron configurada exitosamente. >> "!LOG_FILE!"
    echo.
)
exit /b

:executeJar
echo   »  Ejecutando el archivo en el servidor...
echo   »  Ejecutando el archivo en el servidor... >> "!LOG_FILE!"
:: Ejecuta el archivo en el servidor en segundo plano usando Plink
plink -batch -pw %SSHPASS% -hostkey "%HOSTKEY%" %SERVER% "nohup java -jar %REMOTEDIR%!JARFILE! > /dev/null 2>&1 &"
if !errorlevel! neq 0 (
    echo   □  Error al ejecutar el archivo en el servidor.
    echo   □  Error al ejecutar el archivo en el servidor. >> "!LOG_FILE!"
    pause
    exit /b !errorlevel!
) else (
    echo   ■  Archivo ejecutado exitosamente.
    echo   ■  Archivo ejecutado exitosamente. >> "!LOG_FILE!"
    echo.
    echo ╔════════════════════════════════════════════════╗
    echo ║              Accede mediante IP:               ║
    echo ║              %IP%              ║
    echo ╚════════════════════════════════════════════════╝
    echo.
    echo   ·  ¿Quieres que la web se 
    echo      despliegue automáticamente
    echo      al iniciar el servidor?  s/n
    set /p userResp="»»»  "
    echo.
    call :configureCronJob

    echo   ·  ¿Quieres ejecutarlo en Apache? s/n
    set /p userResp="»»»  "
    echo.
    if /i "!userResp!"=="s" (
        call :checkPort8080
        echo   »  Arrancando el servicio Apache...
        echo   »  Arrancando el servicio Apache2... >> "!LOG_FILE!"
    ) else (
        echo   ·  Script finalizado sin ejecutar Apache.
        echo   ·  Script finalizado sin ejecutar Apache. >> "!LOG_FILE!"
        pause
        exit
    )
)

:logFooter
echo ╔════════════════════════════════════════════════╗
echo ║                Accede mediante:                ║
echo ║         %URL%         ║
echo ╚════════════════════════════════════════════════╝
echo.
echo   ·  El script se completó exitosamente. >> "!LOG_FILE!"
pause
exit

:downloadTools
where %1 >nul 2>nul
if !errorlevel! neq 0 (
    echo   »  %1 no encontrado, descargando...
    if not defined %2 (
        echo   □  La URL de %1 no está definida.
        exit /b 1
    )
    curl -L "!%2!" -o "%DOWNLOAD_DIR%%1.exe"
    if !errorlevel! neq 0 (
        echo   □  Falló la descarga de %1.
        exit /b 1
    )
    echo   ■  Descarga de %1 completada.
    echo.
)
exit /b 0