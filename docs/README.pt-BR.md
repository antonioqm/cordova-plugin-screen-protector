# Cordova Plugin Screen Protector

Um plugin Cordova para proteger o conteúdo do seu aplicativo contra capturas de tela e gravações de tela no iOS e Android.

## Funcionalidades

- Bloqueia capturas de tela e gravações de tela no iOS e Android
- Funciona com todas as activities, incluindo WebViews e activities de terceiros
- Proteção automática - não é necessário habilitar/desabilitar manualmente
- Compatível com Cordova, Ionic e outros frameworks híbridos

## Instalação

### Usando npm

```bash
cordova plugin add cordova-plugin-screen-protector
```

### Usando GitHub

```bash
cordova plugin add https://github.com/antonioqm/cordova-plugin-screen-protector.git
```

## Uso

O plugin protege automaticamente todas as activities do seu aplicativo. Não é necessário código adicional - basta instalar o plugin e ele funcionará.

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
      console.log('Plataforma pronta');
      // O plugin está automaticamente protegendo todas as activities
    });
  }
}
```

### JavaScript

```javascript
document.addEventListener('deviceready', function() {
    console.log('Dispositivo pronto');
    // O plugin está automaticamente protegendo todas as activities
}, false);
```

## Como Funciona

O plugin utiliza:
- `FLAG_SECURE` no Android para prevenir capturas de tela e gravações
- `UIScreen.isCaptured` no iOS para detectar gravação de tela e mostrar uma sobreposição de proteção

## Limitações

### Limitações do Sistema Android
- No Android 10 e versões anteriores, a `FLAG_SECURE` não pode ser desabilitada uma vez ativada para uma activity
- Alguns fabricantes de Android podem ter implementações personalizadas que afetam o comportamento da `FLAG_SECURE`
- Gravações de tela em nível de sistema (como o gravador de tela integrado do Android) ainda podem ser capazes de capturar conteúdo em alguns casos

### Limitações do Sistema iOS
- A detecção de gravação de tela está disponível apenas no iOS 13 e versões superiores
- A sobreposição de proteção será mostrada quando a gravação de tela for detectada, pois esta é a única forma que o iOS permite que os aplicativos respondam à gravação de tela
- Gravações de tela em nível de sistema ainda podem ser capazes de capturar conteúdo em alguns casos

## Solução de Problemas

Se você encontrar algum problema:
1. Verifique se o plugin está instalado corretamente
2. Verifique os logs do dispositivo para mensagens de erro
3. Confirme se seu aplicativo tem as permissões necessárias

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
