package com.vonage.tutorial.voice.apptophone

import android.Manifest
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoCallMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoMediaActionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.tutorial.voice.apptophone.R

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient
    var onGoingCall: NexmoCall? = null

    private lateinit var makeCallButton: Button
    private lateinit var endCallButton: Button
    private lateinit var connectionStatusTextView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permissions
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)

        // init views
        makeCallButton = findViewById(R.id.makeCallButton)
        endCallButton = findViewById(R.id.endCallButton)
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView)

        makeCallButton.setOnClickListener {
            makeCall()
        }

        endCallButton.setOnClickListener {
            hangup()
        }

        // init client
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

            if (connectionStatus == ConnectionStatus.CONNECTED) {
                runOnUiThread { makeCallButton.visibility = View.VISIBLE }

                return@setConnectionListener
            }
        }

        client.login("ALICE_JWT")
    }

    @SuppressLint("MissingPermission")
    fun makeCall() {
        client.call("PHONE_NUMBER", NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                runOnUiThread {
                    endCallButton.visibility = View.VISIBLE
                    makeCallButton.visibility = View.INVISIBLE
                }

                onGoingCall = call
                onGoingCall?.addCallEventListener(object : NexmoCallEventListener {
                    override fun onMemberStatusUpdated(callStatus: NexmoCallMemberStatus, callMember: NexmoCallMember) {
                        if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null

                            runOnUiThread {
                                endCallButton.visibility = View.INVISIBLE
                                makeCallButton.visibility = View.VISIBLE
                            }
                        }
                    }

                    override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

                    override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

                    override fun onDTMF(dtmf: String, callMember: NexmoCallMember) {}
                })
            }

            override fun onError(apiError: NexmoApiError) {
            }
        })
    }

    private fun hangup() {
        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = null
            }

            override fun onError(apiError: NexmoApiError) {
            }
        })
    }
}