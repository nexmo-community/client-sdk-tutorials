package com.vonage.tutorial.apptoapp;

import android.Manifest;
import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import com.nexmo.client.NexmoCall;
import com.nexmo.client.NexmoCallEventListener;
import com.nexmo.client.NexmoCallHandler;
import com.nexmo.client.NexmoMember;
import com.nexmo.client.NexmoCallMemberStatus;
import com.nexmo.client.NexmoClient;
import com.nexmo.client.NexmoMediaActionState;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoConnectionListener;
import com.nexmo.client.request_listener.NexmoRequestListener;

public class MainActivity extends AppCompatActivity {

    private NexmoClient client;
    private String otherUser = "";
    private NexmoCall onGoingCall;

    private TextView connectionStatusTextView;
    private TextView waitingForIncomingCallTextView;
    private Button loginAsAlice;
    private Button loginAsBob;
    private Button startCallButton;
    private Button answerCallButton;
    private Button rejectCallButton;
    private Button endCallButton;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // init views
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView);
        waitingForIncomingCallTextView = findViewById(R.id.waitingForIncomingCallTextView);
        loginAsAlice = findViewById(R.id.loginAsAlice);
        loginAsBob = findViewById(R.id.loginAsBob);
        startCallButton = findViewById(R.id.startCallButton);
        answerCallButton = findViewById(R.id.answerCallButton);
        rejectCallButton = findViewById(R.id.rejectCallButton);
        endCallButton = findViewById(R.id.endCallButton);

        loginAsAlice.setOnClickListener(v -> loginAsAlice());
        loginAsBob.setOnClickListener(v -> loginAsBob());
        answerCallButton.setOnClickListener(view -> answerCall());
        rejectCallButton.setOnClickListener(view -> rejectCall());
        endCallButton.setOnClickListener(view -> endCall());
        startCallButton.setOnClickListener(v -> startCall());

        // request permissions
        String[] callsPermissions = {Manifest.permission.RECORD_AUDIO};
        ActivityCompat.requestPermissions(this, callsPermissions, 123);

        client = new NexmoClient.Builder().build(this);

        client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
            runOnUiThread(() -> connectionStatusTextView.setText(connectionStatus.toString()));

            if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                runOnUiThread(() -> {
                    hideUI();
                    connectionStatusTextView.setVisibility(View.VISIBLE);
                    startCallButton.setVisibility(View.VISIBLE);
                    waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
                });
            }
        });

        client.addIncomingCallListener(it -> {
            onGoingCall = it;

            runOnUiThread(() -> {
                hideUI();
                answerCallButton.setVisibility(View.VISIBLE);
                rejectCallButton.setVisibility(View.VISIBLE);
            });
        });

    }

    private void hideUI() {
        LinearLayout content = findViewById(R.id.content);

        for (int i = 0; i < content.getChildCount(); i++) {
            View view = content.getChildAt(i);
            view.setVisibility(View.GONE);
        }
    }

    private void loginAsAlice() {
        otherUser = "Bob";

        client.login("ALICE_JWT");
    }

    private void loginAsBob() {
        otherUser = "Alice";

        client.login("BOB_JWT");
    }

    @SuppressLint("MissingPermission")
    private void startCall() {
        client.call(otherUser, NexmoCallHandler.SERVER, new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall call) {
                runOnUiThread(() -> {
                    hideUI();
                    endCallButton.setVisibility(View.VISIBLE);
                    waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
                });

                onGoingCall = call;

                onGoingCall.addCallEventListener(new NexmoCallEventListener() {
                    @Override
                    public void onMemberStatusUpdated(NexmoCallMemberStatus callStatus, NexmoMember NexmoMember) {
                        if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null;

                            runOnUiThread(() -> {
                                    hideUI();
                                    startCallButton.setVisibility(View.VISIBLE);
                                }
                            );
                        }
                    }

                    @Override
                    public void onMuteChanged(NexmoMediaActionState nexmoMediaActionState, NexmoMember NexmoMember) {

                    }

                    @Override
                    public void onEarmuffChanged(NexmoMediaActionState nexmoMediaActionState, NexmoMember NexmoMember) {

                    }

                    @Override
                    public void onDTMF(String s, NexmoMember NexmoMember) {

                    }
                });
            }
        });
    }

    @SuppressLint("MissingPermission")
    private void answerCall() {
        onGoingCall.answer(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                runOnUiThread(() -> {
                    hideUI();
                    endCallButton.setVisibility(View.VISIBLE);
                });
            }
        });
    }

    private void rejectCall() {
        onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                runOnUiThread(() -> {
                    hideUI();
                    startCallButton.setVisibility(View.VISIBLE);
                    waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
                });
            }
        });
        onGoingCall = null;
    }

    private void endCall() {
        onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onError(@NonNull NexmoApiError nexmoApiError) {

            }

            @Override
            public void onSuccess(@Nullable NexmoCall nexmoCall) {
                runOnUiThread(() -> {
                    hideUI();
                    startCallButton.setVisibility(View.VISIBLE);
                    waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
                });
            }
        });

        onGoingCall = null;
    }
}