package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer

class OnCallFragment : Fragment(R.layout.fragment_on_call),
    BackPressHandler {

    private lateinit var endCall: Button

    private val viewModel by viewModels<OnCallViewModel>()

    private val toastObserver = Observer<String> {
        Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show();
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(viewLifecycleOwner, toastObserver)

        endCall = view.findViewById(R.id.endCall)

        endCall.setOnClickListener {
            viewModel.hangup()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
