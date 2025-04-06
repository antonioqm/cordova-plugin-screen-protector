package com.antonioqm.screenprotector

import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.view.WindowManager
import android.util.Log

class ScreenProtector : CordovaPlugin() {
    companion object {
        private const val TAG = "ScreenProtector"
    }

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
        Log.d(TAG, "Plugin ScreenProtector inicializado")

        // Registra o callback para monitorar todas as activities
        cordova.activity.application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                Log.d(TAG, "FLAG_SECURE aplicada na activity: ${activity.javaClass.simpleName}")
            }

            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        })
    }
}
