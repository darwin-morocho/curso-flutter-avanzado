package com.example.flutter_gelocation_tracking;

import android.content.pm.PackageManager;
import android.util.Log;


import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterGelocationTrackingPlugin
 */
public class FlutterGelocationTrackingPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, Geolocation.OnGeolocationListener {


    private Geolocation geolocation;
    private MethodChannel channel;


    private void setChannel(MethodChannel channel) {
        this.channel = channel;
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ec.dina/geolocation");
        this.setChannel(channel);
        channel.setMethodCallHandler(this);
    }



    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        switch (call.method) {
            case "permission":
                geolocation.checkPermission(result);
                break;
            case "startTracking":
                geolocation.start();
                result.success(null);
                break;

            case "stopTracking":
                geolocation.stopTracking();
                result.success(null);
                break;


            default:
                result.notImplemented();

        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }


    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {

        Log.i("myplugin", "onAttachedToActivity");

        geolocation = new Geolocation(binding.getActivity());

        geolocation.onGeolocationListener = this;
        binding.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
            @Override
            public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                if (requestCode == Geolocation.REQUEST_ACCESS_FINE_LOCATION) {
                    if (grantResults.length > 0
                            && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                        // permission was granted, yay! Do the
                        geolocation.sendResult("GRANTED");

                    } else {
                        // permission denied, boo! Disable the
                        // functionality that depends on this permission.
                        geolocation.sendResult("DENIED");
                    }
                }
                return false;
            }
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        geolocation.unregister();
        geolocation.stopTracking();
    }

    @Override
    public void onGpsChanged(boolean isEnabled) {
        channel.invokeMethod("onGpsEnabled", isEnabled);
    }

    @Override
    public void onLocationUpdate(HashMap<String, Double> position) {
        channel.invokeMethod(
                "onLocation", position);
    }
}
