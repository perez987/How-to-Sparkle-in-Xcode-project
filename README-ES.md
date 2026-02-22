# Actualizaciones con Sparkle en Xcode

<a href="README.md">
    <img src="https://img.shields.io/badge/English-README-blue" alt="English README Docs"></a><br><br>

Este documento describe cómo configurar el sistema de actualización automática Sparkle en un repositorio de GitHub que contiene un proyecto Xcode. Se asume que el paquete Sparkle y la lógica para comprobar actualizaciones ya han sido añadidos al proyecto Xcode, y que lo que queda por configurar es la forma de subir una versión a GitHub para que el usuario pueda saber si tiene la última versión de la aplicación.

## Nomenclatura

- `Xcodeproject` -> nombre del proyecto Xcode
- `Xcodeproject_app` -> nombre del producto Xcode
- `GitHub_user` -> propietario del repositorio de GitHub
- `GitHub_repo` -> nombre del repositorio de GitHub

## Generar claves

- Obtén una distribución de Sparkle desde la página de [versiones](https://github.com/sparkle-project/Sparkle/releases)
- Ejecuta `./generate_keys` (disponible en la carpeta `bin` en la raíz de la distribución de Sparkle; esto sólo es necesario hacerlo una vez):
	- genera una clave privada que se guarda en el Llavero de inicio del Mac
	- imprime una clave pública para ser incluida en las aplicaciones; anota esta clave para su uso posterior en el archivo Info.plist de Xcode
	- ejecuta `./generate_keys` cada vez que necesites ver la clave pública de nuevo.

## Configuración

### Ajustes de Info.plist

Añade las siguientes claves en `Xcodeproject-Info.plist` para configurar Sparkle:

- SUFeedURL: Apunta al archivo XML del appcast
  - Valor actual: `https://raw.githubusercontent.com/GitHub_user/GitHub_repo/main/appcast.xml`
  - Nota: este enlace debe apuntar a `https://raw.githubusercontent.com`, no a `https://github.com`
- SUPublicEDKey: Clave EdDSA pública (anotada anteriormente) para verificar las firmas de las actualizaciones

```xml
	<key>SUFeedURL</key>
	<string>https://raw.githubusercontent.com/GitHub_user/GitHub_repo/main/appcast.xml</string>
	<key>SUPublicEDKey</key>
	<string>TYAEerTXwSU8wHwYzot2VEzwcPNeKLNQaTVSHkXV3vI=</string>
```

### Archivo Appcast

El archivo `appcast.xml` sigue el formato RSS de Sparkle:

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <link>https://github.com/GitHub_user/GitHub_repo</link>
        <language>en</language>
        <item>
            <title>Version 1.0.1</title>
            <description><![CDATA[
                <ul>
                    <li>Test Sparkle updater with Appcast.xml and SUPublicEDKey to get updates notifications</li>
                    <li>Fix Sparkle updater version comparison: use build number in sparkle:version</li>
                    <li>Another new feature with 2 sub-comments</li>
                    <ul>
                        <li>A comment about the feature</li>
                        <li>Another comment about the feature</li>
                    </ul>
            </ul>
            ]]></description>
            <pubDate>Mon, 17 Feb 2026 19:00:00 +0000</pubDate>
            <enclosure url="https://github.com/GitHub_user/GitHub_repo/releases/download/3.0.1/Xcodeproject_app.zip"
                       sparkle:version="100"
                       sparkle:shortVersionString="1.0.1"
                       length="1234567"
                       sparkle:edSignature="long_base64-encoded_string"
                       type="application/octet-stream" />
            <sparkle:minimumSystemVersion>11.5</sparkle:minimumSystemVersion>
        </item>
    </channel>
</rss>
```
#### Componentes de appcast.xml:

- link: dirección web del repositorio
- language: idioma predefinido
- item: para establecer más de una versión
- title: puedes indicar el número de versión
- description vacío: Sparkle muestra un diálogo de actualización más pequeño, sin notas de versión
- description con texto HTML entre etiquetas CDATA: Sparkle muestra un diálogo de actualización más grande donde podemos ver las notas de la versión
- enclosure: datos específicos de la versión
	- url -> enlace al archivo ZIP de la aplicación
	- sparkle:version -> número de compilación (`CURRENT_PROJECT_VERSION` = `CFBundleVersion`)
	- sparkle:shortVersionString -> versión de la app (`MARKETING_VERSION`)
	- length -> archivo ZIP de la aplicación en bytes
	- sparkle:edSignature -> clave EdDSA pública para verificar las firmas de las actualizaciones
	- type -> "application/octet-stream"
	- minimumSystemVersion -> versión mínima del destino Xcode.

#### Localización de appcast.xml

Se copia en la raíz del repositorio.

## Publicar una Nueva Versión

Al publicar una nueva versión, sigue estos pasos:

1. **Compilar la Aplicación**
   
   - Compila la aplicación en Xcode usando la configuración Release
   - Guarda la aplicación.

2. **Crear un Archivo ZIP**
   
   - Comprime el paquete `.app` `Xcodeproject_app`
   - Anota el tamaño del archivo en bytes: `ls -l Xcodeproject_app.zip`.

3. **Firmar la Actualización (Necesario por Seguridad)**
   
   - Sparkle requiere firmas EdDSA para verificar la autenticidad de las actualizaciones
   - Ejecuta `./sign_update Xcodeproject_app.zip` (`sign_update` está disponible en la carpeta `bin` en la raíz de la distribución de Sparkle)
   - Obtienes 2 datos, anótalos para uso posterior:
      - sparkle:edSignature -> una cadena codificada en base64 que se añadirá al archivo appcast.xml
      - length -> tamaño del archivo ZIP en bytes.

4. **Crear una Versión en GitHub**
   
   - Crea una nueva versión en GitHub con la etiqueta de versión (p. ej., `1.0.1`)
   - Sube el archivo `Xcodeproject_app.zip` como activo de la versión
   - Añade notas de versión describiendo los cambios (en la página de versión y en appcast.xml).

5. **Actualizar appcast.xml**
   
   - Añade un nuevo `<item>` debajo de la sección `<language>`
   - Actualiza el número de versión, la fecha y la URL de descarga
   - Actualiza el atributo `length` con el tamaño del archivo ZIP en bytes
   - Añade la firma EdDSA a la etiqueta `<enclosure>`.

6. **Confirmar y Enviar**
  
   - Confirma el archivo `appcast.xml` actualizado
   - Envía a la rama principal
   - La aplicación ahora buscará actualizaciones y encontrará la nueva versión.

### Pruebas con verificación de firma desactivada (para desarrollo)

Solo para pruebas, puedes deshabilitar temporalmente la verificación de firma eliminando la clave `SUPublicDSAKeyFile` de `Xcodeproject-Info.plist`. Sin embargo, esto **no se recomienda** para versiones de producción, ya que permite que cualquiera publique actualizaciones falsas.

Para probar actualizaciones sin verificación de firma EdDSA:

1. **Eliminar SUPublicEDKey de Info.plist**:
  
   - Elimina la línea `<key>SUPublicEDKey</key>` y su correspondiente valor `<string>...</string>`
   - O comenta la línea para poder restaurarla fácilmente más adelante.

2. **Comprobar que SUFeedURL usa raw.githubusercontent.com**:
  
   - Correcto: `https://raw.githubusercontent.com/GitHub_user/GitHub_repo/main/appcast.xml`
   - Incorrecto: `https://github.com/GitHub_user/GitHub_repo/blob/main/appcast.xml`
   - La URL blob devuelve HTML, no XML, lo que provoca errores de análisis.

3. **Eliminar la firma EdDSA de appcast.xml**:
   
   - El atributo `sparkle:edSignature` en la etiqueta `<enclosure>` puede omitirse cuando la verificación de firma está desactivada.

4. **Probar la configuración**:
   
   - Compila y ejecuta la aplicación en Xcode
   - Selecciona `Xcodeproject_app` > `Buscar actualizaciones...`
   - La aplicación debería obtener y analizar el *feed* correctamente (aunque puede que no muestre una actualización si las versiones coinciden).

**Importante**: Recuerda volver a habilitar la verificación de firma antes de publicar en producción añadiendo de nuevo la clave `SUPublicEDKey` e incluyendo firmas EdDSA en el appcast.

### Pruebas con archivo local (para desarrollo)

1. **Obtén la ruta completa a tu appcast.xml:**
   
   ```bash
   cd /ruta_local_a_GitHub_repo
   pwd
   # Copia el resultado, p. ej., /Users/yo/GitHub_repo
   ```

2. **Edita temporalmente Info.plist:**
   
   ```xml
   <key>SUFeedURL</key>
   <string>file:///Users/yo/GitHub_repo/appcast.xml</string>
   ```

3. **Compila y prueba:**
   
   - Abre Xcodeproject.xcodeproj en Xcode
   - Compila (⌘B)
   - Ejecuta (⌘R)
   - Selecciona `Xcodeproject_app` > `Buscar actualizaciones...`

4. **Resultado esperado:**
   
   - Verás una advertencia de seguridad (esperada con file:///) sobre "Actualización automática no configurada"
   - Haz clic en OK
   - Deberías ver:
     - "¡Estás al día!" (si la versión de compilación coincide con la del appcast)
     - "Hay una nueva versión disponible" (si la versión del appcast es superior)
     - "Error de actualización" con fallo de verificación de firma (si la firma no es válida).

5. **Recuerda revertir SUFeedURL** antes de confirmar.

## Notas Importantes

- Se pueden listar múltiples versiones en el archivo appcast (la más reciente primero)
- Sparkle determinará automáticamente si hay una actualización disponible
- La comparación de versiones usa versionado semántico.

## Solución de Problemas

### Diálogo "¡Error de actualización!"

Si los usuarios ven "Se ha producido un error al recuperar la información de actualización", comprueba:

1. El archivo `appcast.xml` es accesible en la URL especificada en `SUFeedURL`
   - Error frecuente: Usar `https://github.com/.../blob/main/appcast.xml` en lugar de `https://raw.githubusercontent.com/.../main/appcast.xml`
   - La URL blob devuelve HTML (lo que provoca errores de "atributo crossorigin"), no el contenido XML sin procesar
   - Usa siempre la URL `raw.githubusercontent.com` para el feed
2. El XML está bien formado (sin errores de sintaxis)
3. La URL de descarga en la etiqueta `<enclosure>` es válida y accesible
4. El archivo de la versión existe en GitHub.

### Fallos en la Verificación de Firma EdDSA

Si la verificación de firma falla:

1. Asegúrate de que el valor de `SUPublicEDKey` en Info.plist coincide con la clave pública de tu par de claves
2. Comprueba que `sparkle:edSignature` en el appcast coincide con la firma del archivo ZIP
3. Verifica que estás usando el nombre de atributo correcto: `sparkle:edSignature` (no `sparkle:dsaSignature`)
4. Asegúrate de que la firma fue generada con la clave privada correspondiente
5. Considera deshabilitar la verificación de firma durante las pruebas (no recomendado para producción).

## Referencias

- [Proyecto Sparkle](https://sparkle-project.org/)
- [Documentación de Sparkle](https://sparkle-project.org/documentation/)
- [Crear un Appcast](https://sparkle-project.org/documentation/publishing/)
