# Usando o Plugin com TypeScript/Angular/Ionic

## Instalação

```bash
npm install cordova-plugin-screen-protector
```

## Configuração do TypeScript

O plugin já inclui definições de tipos TypeScript. Para usá-las, você pode criar um serviço Angular:

```typescript
// screen-protector.service.ts
import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { BehaviorSubject, Observable } from 'rxjs';
import type { 
  ProtectionEvent, 
  ProtectionReason, 
  ScreenProtectorPlugin 
} from 'cordova-plugin-screen-protector';

@Injectable({
  providedIn: 'root'
})
export class ScreenProtectorService {
  private protectionState = new BehaviorSubject<ProtectionEvent>({ 
    event: 'protectionStopped' 
  });
  private isCordova = false;

  constructor(private platform: Platform) {
    this.initializeProtection();
  }

  private initializeProtection() {
    this.isCordova = this.platform.is('cordova');
    
    if (!this.isCordova) {
      console.warn('[ScreenProtector] Not running in Cordova');
      return;
    }

    this.platform.ready().then(() => {
      const screenProtector = this.getPlugin();
      if (screenProtector) {
        // Registra os listeners de eventos
        screenProtector.on('protectionStarted', (data: ProtectionEvent) => {
          this.protectionState.next(data);
        });

        screenProtector.on('protectionStopped', (data: ProtectionEvent) => {
          this.protectionState.next(data);
        });

        // Ativa o plugin
        screenProtector.enable();
      }
    });
  }

  private getPlugin(): ScreenProtectorPlugin | null {
    return window.cordova?.plugins?.ScreenProtector || null;
  }

  getProtectionState(): Observable<ProtectionEvent> {
    return this.protectionState.asObservable();
  }

  isAvailable(): boolean {
    return this.isCordova && !!this.getPlugin();
  }

  testProtection(reason: ProtectionReason): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.isAvailable()) {
        reject(new Error('Plugin not available'));
        return;
      }

      const screenProtector = this.getPlugin();
      screenProtector?.test(
        reason,
        () => resolve(),
        (error: any) => reject(error)
      );
    });
  }
}
```

## Uso em Componentes

```typescript
// home.page.ts
import { Component } from '@angular/core';
import { ScreenProtectorService } from './services/screen-protector.service';
import type { ProtectionEvent } from 'cordova-plugin-screen-protector';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-home',
  template: `
    <ion-content>
      <ion-list>
        <ion-item>
          <ion-label>Plugin Status</ion-label>
          <ion-note slot="end" [color]="isAvailable ? 'success' : 'danger'">
            {{ isAvailable ? 'Available' : 'Not Available' }}
          </ion-note>
        </ion-item>

        <ion-item *ngIf="protectionState$ | async as state">
          <ion-label>Protection Status</ion-label>
          <ion-note slot="end" [color]="state.event === 'protectionStarted' ? 'warning' : 'success'">
            {{ state.event === 'protectionStarted' ? 'Active' : 'Inactive' }}
            {{ state.reason ? '(' + state.reason + ')' : '' }}
          </ion-note>
        </ion-item>
      </ion-list>

      <ion-button expand="block" (click)="testScreenshot()" [disabled]="!isAvailable">
        Test Screenshot Protection
      </ion-button>

      <ion-button expand="block" (click)="testRecording()" [disabled]="!isAvailable">
        Test Recording Protection
      </ion-button>
    </ion-content>
  `
})
export class HomePage {
  protectionState$: Observable<ProtectionEvent>;
  isAvailable: boolean;

  constructor(private screenProtector: ScreenProtectorService) {
    this.protectionState$ = this.screenProtector.getProtectionState();
    this.isAvailable = this.screenProtector.isAvailable();
  }

  async testScreenshot() {
    try {
      await this.screenProtector.testProtection('screenshot');
    } catch (error) {
      console.error('Test failed:', error);
    }
  }

  async testRecording() {
    try {
      await this.screenProtector.testProtection('screen_recording');
    } catch (error) {
      console.error('Test failed:', error);
    }
  }
}
```

## Recursos Adicionais

### Tipos Disponíveis

Os tipos estão disponíveis diretamente do pacote:

```typescript
import type { 
  ProtectionReason, 
  ProtectionEvent, 
  ScreenProtectorPlugin 
} from 'cordova-plugin-screen-protector';
```

### Observando Eventos

Você pode observar mudanças no estado da proteção usando o Observable retornado por `getProtectionState()`:

```typescript
import type { ProtectionEvent } from 'cordova-plugin-screen-protector';

this.screenProtector.getProtectionState().subscribe((state: ProtectionEvent) => {
  if (state.event === 'protectionStarted') {
    console.log(`Protection activated due to: ${state.reason}`);
  } else {
    console.log('Protection deactivated');
  }
});
```

### Testando no Simulador/Emulador

O plugin inclui um método `test()` que permite simular a ativação da proteção no simulador/emulador:

```typescript
import type { ProtectionReason } from 'cordova-plugin-screen-protector';

// Testar proteção contra screenshot
await this.screenProtector.testProtection('screenshot' as ProtectionReason);

// Testar proteção contra gravação
await this.screenProtector.testProtection('screen_recording' as ProtectionReason);
```

## Notas Importantes

1. O plugin requer iOS 13+ para funcionalidade completa
2. Em Android, usa `FLAG_SECURE` para proteção
3. Teste sempre em dispositivos físicos para validação completa
4. A detecção de gravação de tela é em tempo real no iOS
5. A proteção contra screenshots é instantânea em ambas plataformas 
