<h1 align="center"> 🚀 Maven Deployer</h1>

<p align="center">
Despliegue automático remoto Maven con gestión de servicios.
</p>

<div style="display: flex; justify-content: space-between; margin-bottom:15px;">
    <img src="https://i.imgur.com/ypEf6cu.jpeg" style="max-width: 45%; height: auto; margin-right: 10px;">
    <img src="https://i.imgur.com/Lzr0B57.jpeg" style="max-width: 45%; height: auto; margin-left: 10px;">
</div>

<p align="center">
    <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
    <img src="https://img.shields.io/badge/cmd-4D4D4D?style=for-the-badge&logo=windows%20terminal&logoColor=white" alt="CMD">
    <a href="https://twitter.com/ImPavloh" target="_blank"><img src="https://img.shields.io/badge/sigueme-%231DA1F2.svg?style=for-the-badge&logo=twitter&logoColor=white"></a>
</p>

## 🌟 Características

🧹 Limpieza del proyecto: elimina artefactos de compilaciones anteriores.

📦 Instalación de dependencias: utiliza Maven para gestionar y descargar dependencias.

🔨 Compilación de proyectos: genera archivos ejecutables JAR.

🔍 Verificación de servicios: comprueba que los servicios Apache y Tomcat estén funcionando antes del despliegue.

📤 Transferencia y despliegue: sube y despliega el JAR en el servidor mediante SSH.

🔄 Automatización del inicio: configura crontab para iniciar la aplicación al reiniciar el servidor.

## 📋 Requisitos

- Windows 10/11 64 bits.

- Maven y Curl instalados en el sistema local.

- Proyecto Maven (Java - Jar) y base de datos preparada.

- Acceso SSH configurado y permisos adecuados en el servidor destino.

## ⚙️ Configuración

Antes de ejecutar el script, asegúrate de completar correctamente la información en las variables de configuración en la parte superior del script:

```bat
set "SERVER=usuario@servidor"
set "REMOTEDIR=/ruta/"
set "URL=http://ejemplo.com"
set "IP=127.0.0.1:8080"
set "HOSTKEY=ssh-ed25519 255 SHA256:clave"
```

## 🚀 Uso

Para ejecutar el script, simplemente navega al directorio del proyecto y ejecuta:

```bash
maven-deployer.bat
```

Sigue las instrucciones en pantalla para ingresar contraseñas cuando se soliciten.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](https://github.com/ImPavloh/MavenDeployer/blob/main/LICENSE) para más detalles.

### 🤝 Contribuciones

Las contribuciones son bienvenidas, acepto  Pull Requests :)