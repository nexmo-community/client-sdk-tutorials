package com.vonage.inappmessaging

import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener
import com.nexmo.client.request_listener.NexmoRequestListener

class MainActivity : AppCompatActivity() {
    private val ALICE_JWT = "ALICE_JWT"
    private val BOB_JWT = "BOB_JWT"
    private val CONVERSATION_ID = "CONVERSATION_ID"

    private lateinit var chatContainer: ConstraintLayout
    private lateinit var loginContainer: LinearLayout
    private lateinit var messageEditText: EditText
    private lateinit var conversationTextView: TextView

    private lateinit var client: NexmoClient
    private var conversation: NexmoConversation? = null

    private val conversationEvents = mutableListOf<NexmoEvent>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        chatContainer = findViewById(R.id.chatContainer)
        loginContainer = findViewById(R.id.loginContainer)
        messageEditText = findViewById(R.id.messageEditText)
        conversationTextView = findViewById(R.id.conversationTextView)

        client = NexmoClient.Builder().build(this)

        client.setConnectionListener(NexmoConnectionListener { connectionStatus: NexmoConnectionListener.ConnectionStatus, connectionStatusReason: NexmoConnectionListener.ConnectionStatusReason? ->
            if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                getConversation()

            } else if (connectionStatus == NexmoConnectionListener.ConnectionStatus.DISCONNECTED) {
                conversationEvents.clear()

                runOnUiThread {
                    chatContainer.visibility = View.GONE
                    loginContainer.visibility = View.VISIBLE
                }
            }
        })

        findViewById<View>(R.id.loginAsAliceButton).setOnClickListener {
            findViewById<TextView>(R.id.userNameTextView).text = "Alice: "
            client.login(ALICE_JWT)

            runOnUiThread {
                loginContainer.visibility = View.INVISIBLE
            }
        }

        findViewById<View>(R.id.loginAsBobButton).setOnClickListener {
            findViewById<TextView>(R.id.userNameTextView).text = "Bob: "
            client.login(BOB_JWT)

            runOnUiThread {
                loginContainer.visibility = View.INVISIBLE
            }
        }

        findViewById<View>(R.id.logoutButton).setOnClickListener { client.logout() }

        findViewById<View>(R.id.sendMessageButton).setOnClickListener { sendMessage() }
    }

    private fun getConversation() {
        client.getConversation(CONVERSATION_ID, object : NexmoRequestListener<NexmoConversation?> {
            override fun onSuccess(conversation: NexmoConversation?) {
                this@MainActivity.conversation = conversation

                conversation?.let {
                    getConversationEvents(it)
                    it.addMessageEventListener(object : NexmoMessageEventListener {
                        override fun onMessageEvent(messageEvent: NexmoMessageEvent) {
                            conversationEvents.add(messageEvent)
                            updateConversationView()
                        }
                        override fun onTextEvent(textEvent: NexmoTextEvent) {}
                        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}
                        override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}
                        override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}
                        override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
                        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}
                    })
                }
            }

            override fun onError(apiError: NexmoApiError) {
                conversation = null
                Toast.makeText(this@MainActivity, "Error: Unable to load conversation", Toast.LENGTH_SHORT)
            }
        })
    }

    private fun getConversationEvents(conversation: NexmoConversation) {
        conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
            object : NexmoRequestListener<NexmoEventsPage?> {
                override fun onSuccess(nexmoEventsPage: NexmoEventsPage?) {
                    nexmoEventsPage?.pageResponse?.data?.let { conversationEvents.addAll(it) }
                    updateConversationView()

                    runOnUiThread {
                        chatContainer.visibility = View.VISIBLE
                        loginContainer.visibility = View.GONE
                    }
                }

                override fun onError(apiError: NexmoApiError) {
                    Toast.makeText(this@MainActivity, "Error: Unable to load conversation events", Toast.LENGTH_SHORT)
                }
            })
    }

    private fun updateConversationView() {
        val lines = ArrayList<String>()

        for (event in conversationEvents) {
            var line = ""

            when (event) {
                is NexmoMemberEvent -> {
                    val userName = ""
                    if (event.embeddedInfo != null) {
                        val userName = event.embeddedInfo.user.name
                    }

                    line = when (event.state) {
                        NexmoMemberState.JOINED -> "$userName joined"
                        NexmoMemberState.INVITED -> "$userName invited"
                        NexmoMemberState.LEFT -> "$userName left"
                        NexmoMemberState.UNKNOWN -> "Error: Unknown member event state"
                    }
                }
                is NexmoMessageEvent -> {
                    line = "${event.embeddedInfo.user.name} said: ${event.message.text}"
                }
            }
            lines.add(line)
        }

        // Production application should utilise RecyclerView to provide better UX
        conversationTextView.text = if (lines.isNullOrEmpty()) {
            "Conversation has No messages"
        } else {
            lines.joinToString(separator = "\n")
        }
    }

    private fun sendMessage() {
        val message = messageEditText.text.toString()

        if (message.trim { it <= ' ' }.isEmpty()) {
            Toast.makeText(this, "Message is blank", Toast.LENGTH_SHORT).show()
            return
        }

        messageEditText.setText("")
        hideKeyboard()

        conversation?.sendMessage(NexmoMessage.fromText(message), object: NexmoRequestListener<Void?> {
            override fun onError(apiError: NexmoApiError) {
                Toast.makeText(this@MainActivity, "Error sending message", Toast.LENGTH_SHORT).show()
            }

            override fun onSuccess(aVoid: Void?) {}
        })
    }

    private fun hideKeyboard() {
        val inputMethodManager = ContextCompat.getSystemService(this, InputMethodManager::class.java)

        val view = currentFocus ?: View(this)
        inputMethodManager?.hideSoftInputFromWindow(view.windowToken, 0)
    }
}