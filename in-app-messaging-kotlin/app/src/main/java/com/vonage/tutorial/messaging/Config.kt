package com.vonage.tutorial.messaging

object Config {

    const val CONVERSATION_ID: String = "" // TODO: set conversation Id

    val alice = User(
        "Alice",
        "" // TODO: "set Alice's JWT token"
    )
    val bob = User(
        "Bob",
        "BOB_TOKEN" // TODO: "set Bob's JWT token"
    )
}

data class User(
    val name: String,
    val jwt: String
)
