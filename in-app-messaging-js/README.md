# In-App Messaging Chat Application

This is the sample code for the In-App messaging use case on [Nexmo Developer](https://developer.nexmo.com).

## Initial Setup

### Install the CLI Beta

```
$ npm install -g nexmo-cli@beta
$ nexmo setup api_key api_secret
```

### Create Nexmo Application

Run this command in the project directory:
```
$ nexmo app:create "My Messaging App" https://example.com/answer https://example.com/event --type rtc --keyfile private.key
Application created: APPLICATION_ID
Credentials written to ./.nexmo-app
Private Key saved to: private.key
```

## Create the Conversation and Users

### Create Conversation
```
$ nexmo conversation:create display_name="Messaging Demo"
Conversation created: CONVERSATION_ID
```

### Create Two Users 
```
$ nexmo user:create name="USER1"
User created: USER1_USER_ID

$ nexmo user:create name="USER2"
User created: USER2_USER_ID
```

### Add Users to the Conversation’s Members
```
$ nexmo member:add CONVERSATION_ID action=join channel='{"type":"app"}' user_id=USER1_USER_ID
Member added: USER1_MEMBER_ID

$ nexmo member:add CONVERSATION_ID action=join channel='{"type":"app"}' user_id=USER2_MEMBER_ID
Member added: USER2_MEMBER_ID
```

List the members:

```
$ nexmo member:list CONVERSATION_ID -v
name    | user_id               | user_name | state 
-----------------------------------------------------------------------
USER1    | USER1_USER_ID          | user1      | JOINED
USER2 | USER2_USER_ID       | user2   | JOINED
```

### Generate User JWTs
You need to use `APPLICATION_ID` and the actual name of the user
```sh
$ USER1_JWT="$(nexmo jwt:generate ./private.key sub=user1 exp=$(($(date +%s)+86400)) acl='{"paths":{"/v1/users/**":{},"/v1/conversations/**":{},"/v1/sessions/**":{},"/v1/devices/**":{},"/v1/image/**":{},"/v3/media/**":{},"/v1/applications/**":{},"/v1/push/**":{},"/v1/knocking/**":{}}}' application_id=APPLICATION_ID)"

$ echo $USER1_JWT
eyJhbGciOiJSUzI1NiIsInR5cCI...

$ USER2_JWT="$(nexmo jwt:generate ./private.key sub=user2 exp=$(($(date +%s)+86400)) acl='{"paths":{"/v1/users/**":{},"/v1/conversations/**":{},"/v1/sessions/**":{},"/v1/devices/**":{},"/v1/image/**":{},"/v3/media/**":{},"/v1/applications/**":{},"/v1/push/**":{},"/v1/knocking/**":{}}}' application_id=APPLICATION_ID)"

$ echo $USER2_JWT
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Build the Application

### Create Node app

Although this is a vanilla JavaScript application, you need to initialize it as a Node.js app so that you can refer to the installed dependencies in `node_modules`. Run the following command in the root directory of the application:

```$ npm init```

### Install dependencies

This installs `nexmo-client`, `moment` (for date/time manipulation) and `http-server` (see below).

```$ npm install```

## Configuration

Paste `USER1_JWT`, `USER2_JWT` and `CONVERSATION_ID` into the appropriate `const` variables at the top of the `index.html` page.

### Testing

Run a web server (for example, the `http-server` node module). Open the `index.html` page in two separate tabs, which you can position side-by-side:

The following commands show you how to install and run `http-server`. In this instance, the page will be available at `http://localhost:3000`.

```sh
$ npm install http-server -g
$ http-server -p 3000
```

