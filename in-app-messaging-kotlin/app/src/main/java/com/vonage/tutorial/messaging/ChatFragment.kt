package com.vonage.tutorial.messaging

import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import com.nexmo.client.NexmoEvent
import com.nexmo.client.NexmoMemberEvent
import com.nexmo.client.NexmoMemberState
import com.nexmo.client.NexmoTextEvent

class ChatFragment : Fragment(R.layout.fragment_chat), BackPressHandler {

    private val viewModel by viewModels<ChatViewModel>()

    private lateinit var progressBar: ProgressBar
    private lateinit var errorTextView: TextView
    private lateinit var chatContainer: ConstraintLayout
    private lateinit var logoutButton: Button
    private lateinit var sendMessageButton: Button
    private lateinit var userNameTextView: TextView
    private lateinit var messageEditText: EditText
    private lateinit var conversationEventsTextView: TextView

    private var errorMessageObserver = Observer<String> {
        progressBar.isVisible = false
        errorTextView.text = it
        errorTextView.isVisible = it.isNotEmpty()
        chatContainer.isVisible = it.isEmpty()
    }

    private var userNameObserver = Observer<String> {
        userNameTextView.text = "$it says:"
        logoutButton.text = "Logout $it"
    }

    private var conversationEvents = Observer<List<NexmoEvent>?> { events ->
        val messages = events?.mapNotNull {
            when (it) {
                is NexmoMemberEvent -> getConversationLine(it)
                is NexmoTextEvent -> getConversationLine(it)
                else -> null
            }
        }

        conversationEventsTextView.text = if (messages.isNullOrEmpty()) {
            "Conversation has No messages"
        } else {
            messages.joinToString(separator = "\n")
        }

        progressBar.isVisible = false
        chatContainer.isVisible = true
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        if (Config.CONVERSATION_ID.isBlank()) {

            Toast.makeText(context, "Please set Config.CONVERSATION_ID", Toast.LENGTH_SHORT).show()
            activity?.onBackPressed()
            return
        }

        viewModel.onInit()

        viewModel.errorMessage.observe(viewLifecycleOwner, errorMessageObserver)
        viewModel.conversationEvents.observe(viewLifecycleOwner, conversationEvents)
        viewModel.userName.observe(viewLifecycleOwner, userNameObserver)

        progressBar = view.findViewById(R.id.progressBar)
        errorTextView = view.findViewById(R.id.errorTextView)
        chatContainer = view.findViewById(R.id.chatContainer)
        logoutButton = view.findViewById(R.id.logoutButton)
        sendMessageButton = view.findViewById(R.id.sendMessageButton)
        userNameTextView = view.findViewById(R.id.userNameTextView)
        messageEditText = view.findViewById(R.id.messageEditText)
        conversationEventsTextView = view.findViewById(R.id.conversationEventsTextView)

        sendMessageButton.setOnClickListener {
            val message = messageEditText.text.toString()

            if (message.isNotBlank()) {
                viewModel.onSendMessage(messageEditText.text.toString())
                messageEditText.setText("")
                hideKeyboard()
            } else {
                Toast.makeText(context, "Message is blank", Toast.LENGTH_SHORT).show()
            }
        }

        logoutButton.setOnClickListener {
            viewModel.onLogout()
            findNavController().popBackStack()
        }
    }

    private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
        val user = memberEvent.embeddedInfo.user.name

        return when (memberEvent.state) {
            NexmoMemberState.JOINED -> "$user joined"
            NexmoMemberState.INVITED -> "$user invited"
            NexmoMemberState.LEFT -> "$user left"
            else -> "Error: Unknown member event state"
        }
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        val user = textEvent.embeddedInfo.user.name
        return "$user said: ${textEvent.text}"
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }

    private fun hideKeyboard() {
        val context = context ?: return

        val inputMethodManager = ContextCompat.getSystemService(context, InputMethodManager::class.java)
        var view = activity?.currentFocus
        if (view == null) {
            view = View(activity)
        }

        inputMethodManager?.hideSoftInputFromWindow(view.windowToken, 0)
    }
}
