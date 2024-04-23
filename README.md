<h1 align="center"> 🚀 Maven Deployer</h1>

<p align="center">
Despliegue automático remoto Maven con gestión de servicios.
</p>

<div align="center">
    <img src="https://i.imgur.com/ypEf6cu.jpeg" alt="Inicio de script" width="300"/>&nbsp;
    <img src="https://i.imgur.com/Lzr0B57.jpeg" alt="Script en ejecución" width="300"/>
</div>
&nbsp;
<p align="center">
    <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
    <img src="https://img.shields.io/badge/cmd-4D4D4D?style=for-the-badge&logo=windows%20terminal&logoColor=white" alt="CMD">
    <a href="https://twitter.com/ImPavloh" target="_blank"><img src="https://img.shields.io/badge/sigueme-%231DA1F2.svg?style=for-the-badge&logo=twitter&logoColor=white"></a>
</p>

## 🌟 Características

🧹 <strong>Limpieza del proyecto</strong>: elimina artefactos de compilaciones anteriores.

📦 <strong>Instalación de dependencias</strong>: utiliza Maven para gestionar y descargar dependencias.

🔨 <strong>Compilación de proyectos</strong>: genera archivos ejecutables JAR.

🔍 <strong>Verificación de servicios</strong>: comprueba que los servicios Apache y Tomcat estén funcionando antes del despliegue.

📤 <strong>Transferencia y despliegue</strong>: sube y despliega el JAR en el servidor mediante SSH.

🔄 <strong>Automatización del inicio</strong>: configura crontab para iniciar la aplicación al reiniciar el servidor.

## 📋 Requisitos

- <strong>Windows 10/11 64 bits</strong>.

- Maven y Curl instalados en el sistema local.

- Proyecto Maven (Java - Jar) y base de datos (en caso de tener alguna) preparada.

- Acceso SSH configurado y permisos adecuados en el servidor destino.

## ⚙️ Configuración

Antes de ejecutar el script, asegúrate de completar correctamente la información en las variables de configuración en la parte superior del script:

```bat
set "SERVER=usuario@servidor"
set "REMOTEDIR=/ruta/"
set "HOSTKEY=ssh-ed25519 255 SHA256:clave"
```

## 🚀 Uso

Para ejecutar el script, mueve el script al directorio del proyecto, muévete al directorio y ejecuta:

```bash
maven-deployer.bat
```

#### Sigue las instrucciones en pantalla para ingresar contraseñas cuando se soliciten.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](https://github.com/ImPavloh/MavenDeployer/blob/main/LICENSE) para más detalles.

### 🤝 Contribuciones

No dudes en abrir una [Issue](https://github.com/ImPavloh/MavenDeployer/issues/new) si tienes algún problema o hacer [Pull Request](https://github.com/ImPavloh/MavenDeployer/pulls) si quieres contribuir :)
