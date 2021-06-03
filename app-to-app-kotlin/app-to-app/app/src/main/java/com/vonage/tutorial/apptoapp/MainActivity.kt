package com.vonage.tutorial.apptoapp

import android.Manifest
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.view.forEach
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoMediaActionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener
import com.nexmo.client.request_listener.NexmoRequestListener

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient
    private var otherUser: String = ""
    private var onGoingCall: NexmoCall? = null


    private lateinit var connectionStatusTextView: TextView
    private lateinit var waitingForIncomingCallTextView: TextView
    private lateinit var loginAsAlice: Button
    private lateinit var loginAsBob: Button
    private lateinit var startCallButton: Button
    private lateinit var answerCallButton: Button
    private lateinit var rejectCallButton: Button
    private lateinit var endCallButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permissions
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)

        // init views
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView)
        waitingForIncomingCallTextView = findViewById(R.id.waitingForIncomingCallTextView)
        loginAsAlice = findViewById(R.id.loginAsAlice)
        loginAsBob = findViewById(R.id.loginAsBob)
        startCallButton = findViewById(R.id.startCallButton)
        answerCallButton = findViewById(R.id.answerCallButton)
        rejectCallButton = findViewById(R.id.rejectCallButton)
        endCallButton = findViewById(R.id.endCallButton)

        loginAsAlice.setOnClickListener { loginAsAlice() }
        loginAsBob.setOnClickListener { loginAsBob() }
        answerCallButton.setOnClickListener { answerCall() }
        rejectCallButton.setOnClickListener { rejectCall() }
        endCallButton.setOnClickListener { endCall() }
        startCallButton.setOnClickListener { startCall() }

        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

            if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                runOnUiThread {
                    hideUI()
                    connectionStatusTextView.visibility = View.VISIBLE
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }

                return@setConnectionListener
            }
        }

        client.addIncomingCallListener { it ->
            onGoingCall = it

            runOnUiThread {
                hideUI()
                answerCallButton.visibility = View.VISIBLE
                rejectCallButton.visibility = View.VISIBLE
            }
        }

    }

    private fun hideUI() {
        val content = findViewById<LinearLayout>(R.id.content)
        content.forEach { it.visibility = View.GONE }
    }

    private fun loginAsAlice() {
        otherUser = "Bob"
        client.login("ALICE_JWT")
    }

    private fun loginAsBob() {
        otherUser = "Alice"
        client.login("BOB_JWT")
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        client.call(otherUser, NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                runOnUiThread {
                    hideUI()
                    endCallButton.visibility = View.VISIBLE
                }

                onGoingCall = call

                onGoingCall?.addCallEventListener(object : NexmoCallEventListener {
                    override fun onMemberStatusUpdated(callStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
                        if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null

                            runOnUiThread {
                                hideUI()
                                startCallButton.visibility = View.VISIBLE
                                waitingForIncomingCallTextView.visibility = View.VISIBLE
                            }
                        }
                    }

                    override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

                    override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

                    override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
                })
            }

            override fun onError(apiError: NexmoApiError) {
            }
        })
    }


    @SuppressLint("MissingPermission")
    private fun answerCall() {
        onGoingCall?.answer(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                runOnUiThread {
                    hideUI()
                    endCallButton.visibility = View.VISIBLE
                }
            }
        })
    }

    private fun rejectCall() {
        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                runOnUiThread {
                    hideUI()
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        })

        onGoingCall = null
    }

    private fun endCall() {
        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                runOnUiThread {
                    hideUI()
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        })

        onGoingCall = null
    }
}
