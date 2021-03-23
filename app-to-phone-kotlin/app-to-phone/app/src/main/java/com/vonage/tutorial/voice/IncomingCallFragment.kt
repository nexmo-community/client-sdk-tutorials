package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider

class IncomingCallFragment : Fragment(R.layout.fragment_incoming_call), BackPressHandler {

    private lateinit var viewModel: IncomingCallViewModel

    private lateinit var hangupButton: Button
    private lateinit var answerButton: Button

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(requireActivity()).get(IncomingCallViewModel::class.java)

        hangupButton = view.findViewById(R.id.hangupButton)
        answerButton = view.findViewById(R.id.answerButton)

        viewModel.toast.observe(viewLifecycleOwner, { Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show() })

        hangupButton.setOnClickListener { viewModel.hangup() }
        answerButton.setOnClickListener { viewModel.answer() }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}