var exec = require('cordova/exec');

var PLUGIN_NAME = 'ScreenProtector';
var listeners = {
    protectionStarted: [],
    protectionStopped: []
};

var ScreenProtector = {
    enable: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, PLUGIN_NAME, 'enable', []);
    },

    disable: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, PLUGIN_NAME, 'disable', []);
    },

    on: function(eventName, callback) {
        if (!listeners[eventName]) {
            listeners[eventName] = [];
        }
        listeners[eventName].push(callback);

        // Se for o primeiro listener, registra o callback nativo
        if (listeners[eventName].length === 1) {
            exec(
                function(event) {
                    console.log('Evento recebido do nativo:', event);
                    if (event && event.event === eventName) {
                        listeners[eventName].forEach(function(cb) {
                            cb(event);
                        });
                    }
                },
                function(error) {
                    console.error('Erro no evento:', error);
                },
                PLUGIN_NAME,
                'addEventListener',
                [eventName]
            );
        }
    },

    off: function(eventName, callback) {
        if (listeners[eventName]) {
            if (callback) {
                var index = listeners[eventName].indexOf(callback);
                if (index !== -1) {
                    listeners[eventName].splice(index, 1);
                }
            } else {
                listeners[eventName] = [];
            }
        }
    },

    // Método para testar a proteção no simulador
    test: function(reason, successCallback, errorCallback) {
        var validReasons = ['screenshot', 'screen_recording', 'screen_sharing'];
        if (!reason || !validReasons.includes(reason)) {
            if (errorCallback) {
                errorCallback('Razão inválida. Use: ' + validReasons.join(', '));
            }
            return;
        }
        exec(successCallback, errorCallback, PLUGIN_NAME, 'testProtection', [reason]);
    }
};

module.exports = ScreenProtector;
