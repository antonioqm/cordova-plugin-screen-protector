// Type definitions for cordova-plugin-screen-protector
// Project: https://github.com/antonioqm/cordova-plugin-screen-protector
// Definitions by: Antonio Mesquita

/**
 * Tipos de eventos que podem ativar a proteção
 */
export type ProtectionReason = 'screenshot' | 'screen_recording' | 'screen_sharing';

/**
 * Estrutura do evento de proteção
 */
export interface ProtectionEvent {
    event: 'protectionStarted' | 'protectionStopped';
    reason?: ProtectionReason;
    isRecording?: boolean;
}

/**
 * Interface do plugin ScreenProtector
 */
export interface ScreenProtectorPlugin {
    /**
     * Ativa a proteção de tela
     */
    enable(): void;

    /**
     * Registra um listener para eventos de proteção
     * @param event Nome do evento ('protectionStarted' | 'protectionStopped')
     * @param callback Função de callback que recebe o evento
     */
    on(event: 'protectionStarted' | 'protectionStopped', callback: (data: ProtectionEvent) => void): void;

    /**
     * Testa a proteção de tela
     * @param reason Motivo do teste
     * @param successCallback Callback de sucesso
     * @param errorCallback Callback de erro
     */
    test(
        reason: ProtectionReason,
        successCallback?: () => void,
        errorCallback?: (error: any) => void
    ): void;
}

declare global {
    interface Window {
        cordova?: {
            plugins?: {
                ScreenProtector: ScreenProtectorPlugin;
            };
        };
    }
}

/**
 * Declaração global do plugin
 */
declare const ScreenProtector: ScreenProtectorPlugin;

export default ScreenProtector;
