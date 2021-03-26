package com.vonage.tutorial.phonetoapp;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.nexmo.client.NexmoCall;
import com.nexmo.client.NexmoClient;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoRequestListener;

@SuppressLint("MissingPermission")
public class MainActivity extends AppCompatActivity {

    private NexmoCall call;

    private TextView connectionStatusTextView;
    private Button answerCallButton;
    private Button rejectCallButton;
    private Button endCallButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // request permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 123);
        }

        // init views
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView);
        answerCallButton = findViewById(R.id.answerCallButton);
        rejectCallButton = findViewById(R.id.rejectCallButton);
        endCallButton = findViewById(R.id.endCallButton);

        answerCallButton.setOnClickListener(view -> { answerCall();});
        rejectCallButton.setOnClickListener(view -> { rejectCall();});
        endCallButton.setOnClickListener(view -> { endCall();});

        // Init Nexmo client
        NexmoClient client = new NexmoClient.Builder().build(this);

        client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
            runOnUiThread(() -> connectionStatusTextView.setText(connectionStatus.toString()));
        });

        client.addIncomingCallListener(it -> {
            call = it;

            answerCallButton.setVisibility(View.VISIBLE);
            rejectCallButton.setVisibility(View.VISIBLE);
            endCallButton.setVisibility(View.GONE);
        });

        client.login("ALICE_JWT");
    }

    private void answerCall() {
        call.answer(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                answerCallButton.setVisibility(View.GONE);
                rejectCallButton.setVisibility(View.GONE);
                endCallButton.setVisibility(View.VISIBLE);
            }
        });
    }

    private void rejectCall() {
        call.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                answerCallButton.setVisibility(View.GONE);
                rejectCallButton.setVisibility(View.GONE);
                endCallButton.setVisibility(View.GONE);
            }
        });
        call = null;
    }

    private void endCall() {
        call.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                answerCallButton.setVisibility(View.GONE);
                rejectCallButton.setVisibility(View.GONE);
                endCallButton.setVisibility(View.GONE);
            }
        });
        call = null;
    }
}