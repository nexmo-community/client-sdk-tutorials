const ALICE_JWT = '';
const BOB_JWT = '';
const CONVERSATION_ID = '';

const messageTextarea = document.getElementById("messageTextarea");
const messageFeed = document.getElementById("messageFeed");
const sendButton = document.getElementById("send");
const loginForm = document.getElementById("login");
const status = document.getElementById("status");

const loadMessagesButton = document.getElementById("loadMessages");
const messagesCountSpan = document.getElementById("messagesCount");
const messageDateSpan = document.getElementById("messageDate");

let conversation;
let listedEvents;
let messagesCount = 0;
let messageDate;

function authenticate(username) {
  if (username == "Alice") {
    return ALICE_JWT;
  }
  if (username == "Bob") {
    return BOB_JWT;
  }
  alert("User not recognized");
}

loginForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const userToken = authenticate(document.getElementById("username").value);
  if (userToken) {
    document.getElementById("messages").style.display = "block";
    document.getElementById("login").style.display = "none";
    run(userToken);
  }
});

loadMessagesButton.addEventListener("click", async (event) => {
  // Get next page of events
  let nextEvents = await listedEvents.getNext();
  listMessages(nextEvents);
});

async function run(userToken) {
  let client = new NexmoClient({ debug: true });
  let app = await client.createSession(userToken);
  conversation = await app.getConversation(CONVERSATION_ID);

  // Update the UI to show which user we are
  document.getElementById("sessionName").textContent = conversation.me.user.name + "'s messages";

  // Load events that happened before the page loaded
  let initialEvents = await conversation.getEvents({ event_type: "message", page_size: 10, order:"desc" });

  listMessages(initialEvents);

  // Any time there's a new message event, add it as a message
  conversation.on('message', (sender, event) => {
    const formattedMessage = formatMessage(sender, event, conversation.me);
    messageFeed.innerHTML = messageFeed.innerHTML +  formattedMessage;
    messagesCountSpan.textContent = messagesCount;
  });

  // Listen for clicks on the submit button and send the existing text value
  sendButton.addEventListener("click", () => {
    conversation.sendMessage({ "message_type": "text", "text": messageTextarea.value }).then((event) => {
      console.log("message was sent", event);
      messageTextarea.value = '';
    }).catch((error)=>{
      console.error("error sending the message ", error);
    });
  });

  // Listen for key presses and send start typing event
  messageTextarea.addEventListener("keypress", (event) => {
    conversation.startTyping();
  });

  // Listen for when typing stops and send an event
  let timeout = null;
  messageTextarea.addEventListener("keyup", (event) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      conversation.stopTyping();
    }, 500);
  });

  // When there is a typing event, display an indicator
  conversation.on("text:typing:on", (data, event) => {
    if (conversation.me.id !== data.memberId) {
      status.innerText = data.userName + " is typing...";
    }
  });

  // When typing stops, clear typing indicator
  conversation.on("text:typing:off", (data) => {
    status.innerText = '';
  });
}

function listMessages(events) {
  let messages = '';

  // If there is a next page, display the Load Previous Messages button
  if (events.hasNext()){
    loadMessagesButton.style.display = "block";
  } else {
    loadMessagesButton.style.display = "none";
  }

  // Replace current with new page of events
  listedEvents = events;

  events.items.forEach(event => {
    const sender = { displayName: event._embedded.from_user.display_name, memberId: event.from, userName: event._embedded.from_user.name, userId: event._embedded.from_user.id };
    const formattedMessage = formatMessage(sender, event, conversation.me);
    messages = formattedMessage + messages;
  });

  // Update UI
  messageFeed.innerHTML = messages + messageFeed.innerHTML;
  messagesCountSpan.textContent = messagesCount;
  messageDateSpan.textContent = messageDate;
}

function formatMessage(sender, message, me) {
  const rawDate = new Date(Date.parse(message.timestamp));
  const options = { weekday: "long", year: "numeric", month: "long", day: "numeric", hour: "numeric", minute: "numeric", second: "numeric" };
  const formattedDate = rawDate.toLocaleDateString(undefined, options);
  let text = '';
  messagesCount++;
  messageDate = formattedDate;

  if (message.from !== me.id) {
    text = `<span style="color:red">${sender.userName.replace(/</g,"&lt;")} (${formattedDate}): <b>${message.body.text.replace(/</g,"&lt;")}</b></span>`;
  } else {
    text = `me (${formattedDate}): <b>${message.body.text.replace(/</g,"&lt;")}</b>`;
  }

  return text + '<br />';

}
