package com.vonage.tutorial.voice

object Config {

    val alice = User(
        "Alice",
        "" // TODO: "set Alice's JWT token"
    )
}

data class User(
    val name: String,
    val jwt: String
)
