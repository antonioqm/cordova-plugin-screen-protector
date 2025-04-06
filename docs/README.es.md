# Cordova Plugin Screen Protector

Un plugin de Cordova para proteger el contenido de tu aplicación contra capturas de pantalla y grabaciones de pantalla en iOS y Android.

## Características

- Bloquea capturas de pantalla y grabaciones de pantalla en iOS y Android
- Funciona con todas las activities, incluyendo WebViews y activities de terceros
- Protección automática - no es necesario habilitar/deshabilitar manualmente
- Compatible con Cordova, Ionic y otros frameworks híbridos

## Instalación

### Usando npm

```bash
cordova plugin add cordova-plugin-screen-protector
```

### Usando GitHub

```bash
cordova plugin add https://github.com/antonioqm/cordova-plugin-screen-protector.git
```

## Uso

El plugin protege automáticamente todas las activities de tu aplicación. No se necesita código adicional - solo instala el plugin y funcionará.

### TypeScript/Angular

```typescript
import { Component } from '@angular/core';
import { Platform } from '@ionic/angular';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
})
export class AppComponent {
  constructor(private platform: Platform) {
    this.initializeApp();
  }

  private initializeApp() {
    this.platform.ready().then(() => {
      console.log('Plataforma lista');
      // El plugin está protegiendo automáticamente todas las activities
    });
  }
}
```

### JavaScript

```javascript
document.addEventListener('deviceready', function() {
    console.log('Dispositivo listo');
    // El plugin está protegiendo automáticamente todas las activities
}, false);
```

## Cómo Funciona

El plugin utiliza:
- `FLAG_SECURE` en Android para prevenir capturas de pantalla y grabaciones
- `UIScreen.isCaptured` en iOS para detectar grabación de pantalla y mostrar una superposición de protección

## Limitaciones

### Limitaciones del Sistema Android
- En Android 10 y versiones anteriores, `FLAG_SECURE` no se puede deshabilitar una vez activada para una activity
- Algunos fabricantes de Android pueden tener implementaciones personalizadas que afectan el comportamiento de `FLAG_SECURE`
- Las grabaciones de pantalla a nivel de sistema (como el grabador de pantalla integrado de Android) aún pueden capturar contenido en algunos casos

### Limitaciones del Sistema iOS
- La detección de grabación de pantalla solo está disponible en iOS 13 y versiones superiores
- La superposición de protección se mostrará cuando se detecte la grabación de pantalla, ya que esta es la única forma en que iOS permite que las aplicaciones respondan a la grabación de pantalla
- Las grabaciones de pantalla a nivel de sistema aún pueden capturar contenido en algunos casos

## Solución de Problemas

Si experimentas algún problema:
1. Asegúrate de que el plugin está instalado correctamente
2. Revisa los logs del dispositivo para mensajes de error
3. Verifica que tu aplicación tenga los permisos necesarios

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles. 
