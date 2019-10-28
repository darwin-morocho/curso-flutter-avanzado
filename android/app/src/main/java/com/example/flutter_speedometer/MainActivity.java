package com.example.flutter_speedometer;

import android.content.pm.PackageManager;
import android.os.Bundle;


import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements Geolocation.OnGeolocationListener {


    Geolocation geolocation;
    MethodChannel channel;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);


        geolocation = new Geolocation(this);
        geolocation.onGeolocationListener = this;


        channel = new MethodChannel(getFlutterView(), "ec.dina/geolocation");

        channel.setMethodCallHandler((call, result) -> {


//            switch (call.method) {
//                case "permission":
//                    String text = call.argument("text");
//                    int age = call.argument("age");
//                    result.success("android is here: " + text + " " + age);
//                    break;
//
//                case "add":
//                    result.success("android addd is here");
//                    break;
//                default:
//                    result.notImplemented();
//
//            }


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
        });


    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

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


    }

    @Override
    protected void onDestroy() {
        geolocation.unregister();
        geolocation.stopTracking();
        super.onDestroy();
    }

    @Override
    public void onGpsChanged(boolean isEnabled) {
        channel.invokeMethod("onGpsEnabled", isEnabled);
    }

    @Override
    public void onLocationUpdate(HashMap<String, Double> position) {
        channel.invokeMethod(
                "onLocation",position);
    }
}
