package com.vonage.tutorial.messaging;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.nexmo.client.*;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoRequestListener;

import java.util.ArrayList;

public class ChatViewModel extends ViewModel {

    private NexmoClient client = NexmoClient.get();

    private NexmoConversation conversation;

    private MutableLiveData<String> _errorMessage = new MutableLiveData<>();
    LiveData<String> errorMessage = _errorMessage;

    private MutableLiveData<String> _userName = new MutableLiveData<>();
    LiveData<String> userName = _userName;

    private MutableLiveData<ArrayList<NexmoEvent>> _conversationEvents = new MutableLiveData<>();
    
    LiveData<ArrayList<NexmoEvent>> conversationEvents = _conversationEvents;

    private NexmoMessageEventListener messageListener = new NexmoMessageEventListener() {
        @Override
        public void onTextEvent(@NonNull NexmoTextEvent textEvent) {
            updateConversation(textEvent);
        }

        @Override
        public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {

        }

        @Override
        public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {

        }

        @Override
        public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {

        }

        @Override
        public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {

        }

        @Override
        public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {

        }
    };

    public void onInit() {
        getConversation();
        _userName.postValue(client.getUser().getName());
    }

    private void getConversation() {
        client.getConversation(Config.CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
            @Override
            public void onSuccess(@Nullable NexmoConversation conversation) {
                ChatViewModel.this.conversation = conversation;

                if (ChatViewModel.this.conversation != null) {
                    getConversationEvents(ChatViewModel.this.conversation);
                    ChatViewModel.this.conversation.addMessageEventListener(messageListener);
                }
            }

            @Override
            public void onError(@NonNull NexmoApiError apiError) {
                ChatViewModel.this.conversation = null;
                _errorMessage.postValue("Error: Unable to load conversation " + apiError.getMessage());
            }
        });
    }

    private void getConversationEvents(NexmoConversation conversation) {
        conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
                new NexmoRequestListener<NexmoEventsPage>() {
                    @Override
                    public void onSuccess(@Nullable NexmoEventsPage nexmoEventsPage) {
                        _conversationEvents.postValue(new ArrayList<>(nexmoEventsPage.getPageResponse().getData()));
                    }

                    @Override
                    public void onError(@NonNull NexmoApiError apiError) {
                        _errorMessage.postValue("Error: Unable to load conversation events " + apiError.getMessage());
                    }
                });
    }


    private void updateConversation(NexmoTextEvent textEvent) {
        ArrayList<NexmoEvent> events = _conversationEvents.getValue();

        if (events == null) {
            events = new ArrayList<>();
        }

        events.add(textEvent);
        _conversationEvents.postValue(events);
    }

    public void onSendMessage(String message) {
        if (conversation == null) {
            _errorMessage.postValue("Error: Conversation does not exist");
            return;
        }

        conversation.sendText(message, new NexmoRequestListener<Void>() {
            @Override
            public void onError(@NonNull NexmoApiError apiError) {

            }

            @Override
            public void onSuccess(@Nullable Void aVoid) {

            }
        });
    }


    public void onBackPressed() {
        client.logout();
    }

    public void onLogout() {
        client.logout();
    }

    @Override
    protected void onCleared() {
        //TODO: Unregister message listener"
    }
}
