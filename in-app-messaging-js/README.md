# In-App Messaging Chat Application

This is the sample code for the In-App messaging use case on [Nexmo Developer](https://developer.nexmo.com).

## Initial Setup

### Install the Vonage CLI
```
$ npm install -g @vonage/cli
$ vonage config:set --apiKey=API_KEY --apiSecret=API_SECRET
```

### Install the Vonage CLI Conversations Plugin
```
$ vonage plugins:install @vonage/cli-plugin-conversations
```

### Create Vonage Application

Run this command in the project directory:
```
$ vonage apps:create
```

## Create the Conversation and Users

### Create Conversation
```
$ vonage apps:conversations:create "CONVERSATION_NAME"
Conversation created: CONVERSATION_ID
```

### Create Two Users 
```
$ vonage apps:users:create USER1_NAME
User created: USER1_USER_ID

$ vonage apps:users:create USER2_NAME
User created: USER2_USER_ID
```

### Add Users to the Conversation’s Members
```
$ vonage apps:conversations:members:add CONVERSATION_ID USER1_USER_ID
Member added: USER1_MEMBER_ID

$ vonage apps:conversations:members:add CONVERSATION_ID USER2_USER_ID
Member added: USER2_MEMBER_ID
```

List the members:

```
$ vonage apps:conversations:members CONVERSATION_ID
name    | user_id               | user_name | state 
-----------------------------------------------------------------------
USER1    | USER1_USER_ID          | user1      | JOINED
USER2 | USER2_USER_ID       | user2   | JOINED
```

### Generate User JWTs
You need to use `APP_ID` and the actual name of the user
```sh
$ vonage jwt --key_file=./private.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' --subject=USER1_NAME --app_id=APP_ID

eyJhbGciOiJSUzI1NiIsInR5cCI...

$ vonage jwt --key_file=./private.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' --subject=USER2_NAME --app_id=APP_ID

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

