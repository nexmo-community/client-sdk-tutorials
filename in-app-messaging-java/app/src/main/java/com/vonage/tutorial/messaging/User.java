package com.vonage.tutorial.messaging;

public class User {

    public String jwt;
    String name;

    public User(String name, String jwt) {
        this.name = name;
        this.jwt = jwt;
    }

    public String getName() {
        return name;
    }

    public String getId() {
        return jwt;
    }
}
