package com.vonage.tutorial.messaging;

public class Config {

    public static String CONVERSATION_ID = ""; // TODO: set conversation Id

    public static User getAlice() {
        return new User(
                "Alice",
                "" // TODO: "set Alice JWT token"
        );
    }

    public static User getBob() {
        return new User(
                "Bob",
                "" // TODO: "set Bob JWT token"
        );
    }
}
