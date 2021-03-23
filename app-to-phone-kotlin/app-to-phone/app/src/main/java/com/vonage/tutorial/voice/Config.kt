package com.vonage.tutorial.voice

object Config {

    val alice = User(
        "Alice",
        "ALICE_TOKEN" // TODO: "set Alice's JWT token"
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
