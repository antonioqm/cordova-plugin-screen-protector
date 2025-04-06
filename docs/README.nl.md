# Cordova Plugin Screen Protector

Een Cordova plugin om de inhoud van je app te beschermen tegen schermafbeeldingen en schermopnames op iOS en Android.

## Functies

- Blokkeert schermafbeeldingen en schermopnames op iOS en Android
- Werkt met alle activities, inclusief WebViews en third-party activities
- Automatische bescherming - geen handmatige activering/deactivatie nodig
- Compatibel met Cordova, Ionic en andere hybride frameworks

## Installatie

### Via npm

```bash
cordova plugin add cordova-plugin-screen-protector
```

### Via GitHub

```bash
cordova plugin add https://github.com/antonioqm/cordova-plugin-screen-protector.git
```

## Gebruik

De plugin beschermt automatisch alle activities in je app. Er is geen extra code nodig - installeer de plugin en hij werkt.

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
      console.log('Platform gereed');
      // De plugin beschermt automatisch alle activities
    });
  }
}
```

### JavaScript

```javascript
document.addEventListener('deviceready', function() {
    console.log('Apparaat gereed');
    // De plugin beschermt automatisch alle activities
}, false);
```

## Hoe het Werkt

De plugin gebruikt:
- `FLAG_SECURE` op Android om schermafbeeldingen en opnames te voorkomen
- `UIScreen.isCaptured` op iOS om schermopnames te detecteren en een beschermingslaag te tonen

## Beperkingen

### Systeembeperkingen Android
- Op Android 10 en eerdere versies kan `FLAG_SECURE` niet worden uitgeschakeld nadat deze is geactiveerd voor een activity
- Sommige Android-fabrikanten kunnen aangepaste implementaties hebben die het gedrag van `FLAG_SECURE` beïnvloeden
- Systeemniveau schermopnames (zoals de ingebouwde schermrecorder van Android) kunnen in sommige gevallen nog steeds inhoud vastleggen

### Systeembeperkingen iOS
- Schermopnamedetectie is alleen beschikbaar op iOS 13 en hoger
- De beschermingslaag wordt getoond wanneer een schermopname wordt gedetecteerd, omdat dit de enige manier is waarop iOS apps toestaat te reageren op schermopnames
- Systeemniveau schermopnames kunnen in sommige gevallen nog steeds inhoud vastleggen

## Probleemoplossing

Als je problemen ervaart:
1. Controleer of de plugin correct is geïnstalleerd
2. Controleer de apparaatlogs op foutmeldingen
3. Verifieer of je app de benodigde rechten heeft

## Licentie

Dit project is gelicenseerd onder de MIT-licentie - zie het [LICENSE](LICENSE) bestand voor details. 
