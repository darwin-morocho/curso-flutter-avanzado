package com.example.flutter_gelocation_tracking;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;


import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;


import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

public class Geolocation {

    final static int REQUEST_ACCESS_FINE_LOCATION = 50101;
    final static int REQUEST_CHECK_SETTINGS = 50102;

    private Activity activity;
    OnGeolocationListener onGeolocationListener;

    private LocationRequest locationRequest;


    private FusedLocationProviderClient fusedLocationProviderClient;


    Geolocation(Activity activity) {
        this.activity = activity;
        this.activity.registerReceiver(gpsBroadcastReceiver, new IntentFilter(LocationManager.PROVIDERS_CHANGED_ACTION));
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this.activity);
        locationRequest = new LocationRequest();
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(5000);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

    }


    BroadcastReceiver gpsBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().matches("android.location.PROVIDERS_CHANGED")) {
                LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
                boolean isEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
                onGeolocationListener.onGpsChanged(isEnabled);
            }
        }
    };


    MethodChannel.Result result;

    private boolean setResult(MethodChannel.Result result) {
        if (this.result != null) {
            this.result.error("PENDING_RESULT_ERROR", "error you have a pending task", "");
            this.result = null;
            return false;
        }
        this.result = result;
        return true;
    }


    void sendResult(String response) {
        this.result.success(response);
        this.result = null;
    }


    private void requestPermission() {
        ActivityCompat.requestPermissions(this.activity,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_ACCESS_FINE_LOCATION);
    }


    void checkPermission(MethodChannel.Result result) {
        if (setResult(result)) {
            if (ContextCompat.checkSelfPermission(this.activity, Manifest.permission.ACCESS_FINE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                // Permission is not granted
                requestPermission();
            } else {
                sendResult("GRANTED");
            }

        }
    }


    public void unregister() {
        this.activity.unregisterReceiver(gpsBroadcastReceiver);
    }


    LocationCallback locationCallback= new LocationCallback() {
        @Override
        public void onLocationResult(LocationResult locationResult) {
            super.onLocationResult(locationResult);
            if (locationResult != null) {
                Location location = locationResult.getLastLocation();
                if (onGeolocationListener != null) {
                    HashMap<String, Double> position = new HashMap<>();
                    position.put("lat", location.getLatitude());
                    position.put("lng", location.getLongitude());
                    onGeolocationListener.onLocationUpdate(position);
                }
            }
        }
    };

    private void startTracking() {
        fusedLocationProviderClient.requestLocationUpdates(locationRequest,locationCallback, null);
    }


    public void start() {
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(locationRequest);
        builder.setAlwaysShow(true);
        SettingsClient client = LocationServices.getSettingsClient(this.activity);
        Task<LocationSettingsResponse> task = client.checkLocationSettings(builder.build());
        task.addOnSuccessListener(new OnSuccessListener<LocationSettingsResponse>() {
            @Override
            public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                // All location settings are satisfied. The client can initialize
                // location requests here.
                // ...
                Geolocation.this.startTracking();

            }
        });


        task.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                if (e instanceof ResolvableApiException) {
                    // Location settings are not satisfied, but this can be fixed
                    // by showing the user a dialog.
                    try {
                        // Show the dialog by calling startResolutionForResult(),
                        // and check the result in onActivityResult().
                        ResolvableApiException resolvable = (ResolvableApiException) e;
                        resolvable.startResolutionForResult(activity,
                                REQUEST_CHECK_SETTINGS);
                    } catch (IntentSender.SendIntentException sendEx) {
                        // Ignore the error.
                    }
                }
            }
        });
    }


    public void stopTracking(){
        fusedLocationProviderClient.removeLocationUpdates(locationCallback);
    }


    public interface OnGeolocationListener {
        void onGpsChanged(boolean isEnabled);
        void onLocationUpdate(HashMap<String, Double> position);
    }

}