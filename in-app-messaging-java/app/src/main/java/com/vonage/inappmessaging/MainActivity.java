package com.vonage.inappmessaging;

import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import com.nexmo.client.*;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoConnectionListener;
import com.nexmo.client.request_listener.NexmoRequestListener;
import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {
    private ConstraintLayout chatContainer;
    private LinearLayout loginContainer;
    private EditText messageEditText;
    private TextView conversationTextView;

    private NexmoConversation conversation;
    private NexmoClient client;

    private String ALICE_JWT  = "ALICE_JWT";
    private String BOB_JWT  = "BOB_JWT";
    private String CONVERSATION_ID = "CONVERSATION_ID";

    private ArrayList<NexmoEvent> conversationEvents = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        chatContainer = findViewById(R.id.chatContainer);
        loginContainer = findViewById(R.id.loginContainer);
        messageEditText = findViewById(R.id.messageEditText);
        conversationTextView = findViewById(R.id.conversationTextView);

        chatContainer = findViewById(R.id.chatContainer);
        loginContainer = findViewById(R.id.loginContainer);
        messageEditText = findViewById(R.id.messageEditText);
        conversationTextView = findViewById(R.id.conversationTextView);

        client = new NexmoClient.Builder().build(this);

        client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
            if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {

                getConversation();
            } else if (connectionStatus == NexmoConnectionListener.ConnectionStatus.DISCONNECTED) {

                runOnUiThread(() -> {
                    chatContainer.setVisibility(View.GONE);
                    loginContainer.setVisibility(View.VISIBLE);
                });

                conversationEvents.clear();
            }
        });

        findViewById(R.id.loginAsAliceButton).setOnClickListener(it -> {
            client.login(ALICE_JWT);

            runOnUiThread(() -> loginContainer.setVisibility(View.GONE));
        });

        findViewById(R.id.loginAsBobButton).setOnClickListener(it -> {
            client.login(BOB_JWT);

            runOnUiThread(() -> loginContainer.setVisibility(View.GONE));
        });

        findViewById(R.id.logoutButton).setOnClickListener(it -> client.logout());

        findViewById(R.id.sendMessageButton).setOnClickListener(it -> sendMessage());
    }

    private  void sendMessage() {
        String message = messageEditText.getText().toString();

        if (message.trim().isEmpty()) {
            Toast.makeText(this, "Message is blank", Toast.LENGTH_SHORT).show();
            return;
        }

        messageEditText.setText("");
        hideKeyboard();

        conversation.sendText(message, new NexmoRequestListener<Void>() {
            @Override
            public void onError(@NonNull NexmoApiError apiError) {
                Toast.makeText(MainActivity.this, "Error sending message", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onSuccess(@Nullable Void aVoid) {

            }
        });
    }

    private void hideKeyboard() {
        InputMethodManager inputMethodManager = ContextCompat.getSystemService(this, InputMethodManager.class);

        View view = getCurrentFocus();

        if (view == null) {
            view = new View(this);
        }

        inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    private void getConversation() {
        client.getConversation(CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
            @Override
            public void onSuccess(@Nullable NexmoConversation conversation) {
                MainActivity.this.conversation = conversation;
                getConversationEvents(conversation);

                conversation.addMessageEventListener(new NexmoMessageEventListener() {
                    @Override
                    public void onTextEvent(@NonNull NexmoTextEvent textEvent) {
                        conversationEvents.add(textEvent);
                        updateConversationView();
                    }

                    @Override
                    public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {}

                    @Override
                    public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {}

                    @Override
                    public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {}

                    @Override
                    public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {}

                    @Override
                    public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {}
                });

                conversation.addMediaEventListener(new NexmoMediaEventListener() {
                    @Override
                    public void onMediaEnabled(@NonNull NexmoMediaEvent nexmoMediaEvent) {
                        conversationEvents.add(nexmoMediaEvent);
                        updateConversationView();
                    }

                    @Override
                    public void onMediaDisabled(@NonNull NexmoMediaEvent nexmoMediaEvent) {
                        conversationEvents.add(nexmoMediaEvent);
                        updateConversationView();
                    }
                });
            }

            @Override
            public void onError(@NonNull NexmoApiError apiError) {
                MainActivity.this.conversation = null;
                Toast.makeText(MainActivity.this, "Error: Unable to load conversation", Toast.LENGTH_SHORT);
            }
        });
    }

    private void getConversationEvents(NexmoConversation conversation) {
        conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
                new NexmoRequestListener<NexmoEventsPage>() {
                    @Override
                    public void onSuccess(@Nullable NexmoEventsPage nexmoEventsPage) {
                        conversationEvents.addAll(nexmoEventsPage.getPageResponse().getData());
                        updateConversationView();

                        runOnUiThread(() -> {
                            chatContainer.setVisibility(View.VISIBLE);
                            loginContainer.setVisibility(View.GONE);
                        });
                    }

                    @Override
                    public void onError(@NonNull NexmoApiError apiError) {
                        Toast.makeText(MainActivity.this, "Error: Unable to load conversation events", Toast.LENGTH_SHORT);
                    }
                });
    }

    private void updateConversationView() {
        ArrayList<String> lines = new ArrayList<>();

        for (NexmoEvent event : conversationEvents) {
            if (event == null) {
                continue;
            }

            String line = "";

            if (event instanceof NexmoMemberEvent) {
                NexmoMemberEvent memberEvent = (NexmoMemberEvent) event;
                String userName = memberEvent.getEmbeddedInfo().getUser().getName();

                switch (memberEvent.getState()) {
                    case JOINED:
                        line = userName + " joined";
                        break;
                    case INVITED:
                        line = userName + " invited";
                        break;
                    case LEFT:
                        line = userName + " left";
                        break;
                    case UNKNOWN:
                        line = "Error: Unknown member event state";
                        break;
                }
            } else if (event instanceof NexmoTextEvent) {
                NexmoTextEvent textEvent = (NexmoTextEvent) event;
                String userName = textEvent.getEmbeddedInfo().getUser().getName();
                line = userName + " said: " + textEvent.getText();
            }  else if (event instanceof NexmoMediaEvent) {
                NexmoMediaEvent nexmoMediaEvent = (NexmoMediaEvent) event;
                String userName = nexmoMediaEvent.getEmbeddedInfo().getUser().getName();
                line = userName + "media state: " + nexmoMediaEvent.getMediaState();
            }

            lines.add(line);
        }

        // Production application should utilise RecyclerView to provide better UX
        if (lines.isEmpty()) {
            conversationTextView.setText("Conversation has no events");
        } else {

            String conversation = "";

            for (String line : lines) {
                conversation += line + "\n";
            }

            conversationTextView.setText(conversation);
        }
    }
}