package com.vonage.tutorial.voice;

import android.Manifest;
import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import com.nexmo.client.NexmoCall;
import com.nexmo.client.NexmoCallEventListener;
import com.nexmo.client.NexmoCallHandler;
import com.nexmo.client.NexmoCallMember;
import com.nexmo.client.NexmoCallMemberStatus;
import com.nexmo.client.NexmoClient;
import com.nexmo.client.NexmoMediaActionState;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus;
import com.nexmo.client.request_listener.NexmoRequestListener;

public class MainActivity extends AppCompatActivity {

    private NexmoClient client;
    @Nullable
    private NexmoCall onGoingCall;

    private Button makeCallButton;
    private Button endCallButton;
    private TextView connectionStatusTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // request permissions
        String[] callsPermissions = {Manifest.permission.RECORD_AUDIO};
        ActivityCompat.requestPermissions(this, callsPermissions, 123);

        // init views
        makeCallButton = findViewById(R.id.makeCallButton);
        endCallButton = findViewById(R.id.endCallButton);
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView);

        makeCallButton.setOnClickListener(v -> makeCall());
        endCallButton.setOnClickListener(v -> hangup());

        // init client
        client = new NexmoClient.Builder().build(this);

        client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
            runOnUiThread(() -> {
                connectionStatusTextView.setText(connectionStatus.toString());
            });

            if (connectionStatus == ConnectionStatus.CONNECTED) {
                runOnUiThread(() -> {
                    makeCallButton.setVisibility(View.VISIBLE);
                });
            }
        });

        client.login("ALICE_JWT");
    }

    @SuppressLint("MissingPermission")
    private void makeCall() {
        // Callee number is ignored because it is specified in NCCO config
        client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall call) {
                runOnUiThread(() -> {
                    endCallButton.setVisibility(View.VISIBLE);
                    makeCallButton.setVisibility(View.INVISIBLE);
                });

                onGoingCall = call;
                onGoingCall.addCallEventListener(new NexmoCallEventListener() {
                    @Override
                    public void onMemberStatusUpdated(NexmoCallMemberStatus callStatus, NexmoCallMember nexmoCallMember) {
                        if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null;

                            runOnUiThread(() -> {
                                endCallButton.setVisibility(View.INVISIBLE);
                                makeCallButton.setVisibility(View.VISIBLE);
                            });
                        }
                    }

                    @Override
                    public void onMuteChanged(NexmoMediaActionState nexmoMediaActionState, NexmoCallMember nexmoCallMember) {

                    }

                    @Override
                    public void onEarmuffChanged(NexmoMediaActionState nexmoMediaActionState, NexmoCallMember nexmoCallMember) {

                    }

                    @Override
                    public void onDTMF(String s, NexmoCallMember nexmoCallMember) {

                    }
                });
            }
        });
    }

    private void hangup() {
        onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {
                onGoingCall = null;
            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {

            }
        });
    }
}
