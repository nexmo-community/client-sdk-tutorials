package com.vonage.tutorial.voice.app_to_phone

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import com.nexmo.client.request_listener.NexmoRequestListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var client: NexmoClient
    private var onGoingCall: NexmoCall? = null

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(callMemberStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
            if (callMemberStatus == NexmoCallMemberStatus.COMPLETED || callMemberStatus == NexmoCallMemberStatus.CANCELLED) {
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }
        }

        override fun onMuteChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onEarmuffChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
        override fun onLegTransfer(event: NexmoLegTransferEvent?, member: NexmoMember?) {}
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initClient()
        addFlutterChannelListener()
    }

    private fun initClient() {
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            when (connectionStatus) {
                ConnectionStatus.CONNECTED -> notifyFlutter(SdkState.LOGGED_IN)
                ConnectionStatus.DISCONNECTED -> notifyFlutter(SdkState.LOGGED_OUT)
                ConnectionStatus.CONNECTING -> notifyFlutter(SdkState.WAIT)
                ConnectionStatus.UNKNOWN -> notifyFlutter(SdkState.ERROR)
            }
        }
    }

    private fun addFlutterChannelListener() {
        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, "com.vonage").setMethodCallHandler { call, result ->

                when (call.method) {
                    "loginUser" -> {
                        val token = requireNotNull(call.argument<String>("token"))
                        loginUser(token)
                        result.success("")
                    }
                    "makeCall" -> {
                        makeCall()
                        result.success("")
                    }
                    "endCall" -> {
                        endCall()
                        result.success("")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    private fun loginUser(token: String) {
        client.login(token)
    }

    @SuppressLint("MissingPermission")
    private fun makeCall() {
        notifyFlutter(SdkState.WAIT)

        client.serverCall("PHONE_NUMBER", null, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = call
                onGoingCall?.addCallEventListener(callEventListener)
                notifyFlutter(SdkState.ON_CALL)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun endCall() {
        notifyFlutter(SdkState.WAIT)

        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall?.removeCallEventListener(callEventListener)
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun notifyFlutter(state: SdkState) {
        Handler(Looper.getMainLooper()).post {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, "com.vonage")
                    .invokeMethod("updateState", state.toString())
            }
        }
    }
}

enum class SdkState {
    LOGGED_OUT,
    LOGGED_IN,
    WAIT,
    ON_CALL,
    ERROR
}