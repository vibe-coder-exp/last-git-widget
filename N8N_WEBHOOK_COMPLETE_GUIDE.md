# 🔄 Complete N8N Webhook Integration Guide

## How the Chat Widget Communicates with N8N

### **Understanding the Flow:**

```
User sends message → Widget → N8N Webhook → AI/Logic → Response → Widget → User sees reply
```

---

## 📤 **What the Widget Sends to Your N8N Webhook**

When a user sends a message, the widget makes a **POST request** to your webhook URL:

### **Request Format:**
```json
{
  "action": "sendMessage",
  "sessionId": "abc-123-uuid-456",
  "botId": "shoe-wala",
  "route": "realestate",
  "chatInput": "Hello, I need help with something",
  "metadata": {
    "userId": ""
  }
}
```

### **Important Fields:**
- **`chatInput`** - The user's message
- **`sessionId`** - Unique conversation ID (use for context)
- **`botId`** - Which bot configuration is being used
- **`route`** - Routing key from bot configuration

---

## 📥 **What N8N Must Return (Response Format)**

### **Method 1: Simple Object (Recommended)**
```json
{
  "output": "Hello! I can help you with that. What do you need?"
}
```

### **Method 2: Array Format**
```json
[
  {
    "output": "Hello! I can help you with that."
  }
]
```

### **⚠️ CRITICAL:**
- Response MUST have an `"output"` field
- Value must be a string (the bot's reply message)
- Widget extracts: `data.output` or `data[0].output`

---

## 🏗️ **N8N Workflow Setup (Step-by-Step)**

### **Step 1: Create Webhook Trigger**

**Add Webhook Node:**
- **HTTP Method:** `POST`
- **Path:** `/chat` (or any path you like)
- **Response Mode:** ⚠️ **"When Last Node Finishes"** (IMPORTANT!)
- **Response Data:** `First Entry JSON`

**Why "When Last Node Finishes"?**
- Allows your workflow to process data before responding
- Prevents timeout errors
- Enables AI/database calls

---

### **Step 2: Extract User Message**

**Add Code Node or Set Node:**

**Option A: Code Node (JavaScript)**
```javascript
return [{
  userMessage: $input.item.json.chatInput,
  sessionId: $input.item.json.sessionId,
  botId: $input.item.json.botId
}];
```

**Option B: Set Node**
- Click "+ Add Value"
- **Name:** `userMessage`
- **Value:** `{{ $json.chatInput }}`

---

### **Step 3: Process with AI/Logic**

**Example: OpenAI Chat Node**
- **Model:** `gpt-4` or `gpt-3.5-turbo`
- **Messages:**
  - **System Role:** `You are a helpful assistant`
  - **User Message:** `{{ $json.userMessage }}` or `{{ $json.chatInput }}`

**Example: Simple IF/Switch Logic**
```javascript
// Code node
const message = $input.item.json.chatInput.toLowerCase();

if (message.includes('hello') || message.includes('hi')) {
  return [{
    output: "Hello! How can I help you today?"
  }];
} else if (message.includes('price') || message.includes('cost')) {
  return [{
    output: "Our pricing starts at $99/month. Would you like more details?"
  }];
} else {
  return [{
    output: "I understand you said: " + $input.item.json.chatInput
  }];
}
```

---

### **Step 4: Format Response**

**Add Set Node (if needed):**
- **Name:** `output`
- **Value:** `{{ $json.message.content }}` (for AI responses)
- **OR Value:** Your custom text

**Result should be:**
```json
{
  "output": "The bot's response message here"
}
```

---

### **Step 5: Return Response**

**Add "Respond to Webhook" Node:**
- Connect from your last processing node
- **Response Code:** `200`
- **Response Data:** `First Entry JSON`

**This sends the response back to the chat widget!**

---

## 🚀 **Quick Start: Minimal Echo Bot (5 Minutes)**

### **Workflow Nodes:**

```
1. Webhook (POST /chat)
   ↓
2. Set Node
   - output: "Echo: {{ $json.chatInput }}"
   ↓
3. Respond to Webhook
```

### **Detailed Setup:**

**Node 1: Webhook**
- Method: POST
- Path: /chat
- Response Mode: "When Last Node Finishes"

**Node 2: Set** 
- Click "+ Add Value"
- Name: `output`
- Value: `You said: {{ $json.chatInput }}`

**Node 3: Respond to Webhook**
- (Just add it, no config needed)

**Test it:**
```bash
curl -X POST https://your-n8n-url.app.n8n.cloud/webhook/xxx/chat \
  -H "Content-Type: application/json" \
  -d '{"chatInput":"Hello"}'
```

**Expected Response:**
```json
{
  "output": "You said: Hello"
}
```

---

## 🤖 **Real-World Example: AI Real Estate Assistant**

### **Complete N8N Workflow:**

```
1. Webhook (POST /chat)
   ↓
2. Set - Extract data
   - sessionId: {{ $json.sessionId }}
   - userMessage: {{ $json.chatInput }}
   ↓
3. OpenAI Chat
   - System: "You are a real estate assistant..."
   - User: {{ $json.userMessage }}
   ↓
4. Set - Format response
   - output: {{ $json.message.content }}
   ↓
5. Respond to Webhook
```

---

## 🔄 **Two Ways to Send Responses**

### **Method 1: Synchronous (Current Setup)**

**How it works:**
1. User sends message
2. Widget waits for webhook response
3. N8N processes and returns immediately
4. Widget displays response

**Pros:**
- ✅ Simple to implement
- ✅ Instant feedback
- ✅ No additional setup needed

**Cons:**
- ⚠️ Limited to ~30 second timeout
- ⚠️ User sees "typing..." while waiting

**Best for:**
- Quick AI responses (< 10 seconds)
- Simple logic/database lookups
- Chat GPT responses

---

### **Method 2: Asynchronous (via Supabase Realtime)**

**How it works:**
1. User sends message
2. Widget saves to database immediately
3. N8N processes in background
4. N8N inserts response to `chat_messages` table
5. Widget receives via Supabase Realtime
6. Response appears automatically

**Pros:**
- ✅ No timeout limits
- ✅ Can take minutes to respond
- ✅ Multiple responses possible
- ✅ Works for long-running processes

**Cons:**
- ⚠️ Requires Supabase client
- ⚠️ More complex setup

**N8N Setup for Async:**

```
1. Webhook (POST /chat)
   ↓
2. Respond to Webhook (acknowledge receipt)
   - output: "Processing your request..."
   ↓
3. [Background Processing]
   - AI calls, database lookups, etc.
   ↓
4. Supabase Node (Insert)
   - Table: chat_messages
   - Fields:
     * session_id: {{ $json.sessionId }}
     * bot_id: {{ $json.botId }}
     * sender_type: "bot"
     * content: {{ $json.aiResponse }}
     * metadata: { is_webhook_response: false }
```

**Widget automatically receives via realtime subscription!**

---

## 🧪 **Testing Your Webhook**

### **Test 1: Using cURL**

```bash
curl -X POST https://hussyaiexp.app.n8n.cloud/webhook-test/shoe-assistant \
  -H "Content-Type: application/json" \
  -d '{
    "action": "sendMessage",
    "sessionId": "test-session-123",
    "chatInput": "Hello, what services do you offer?",
    "route": "general"
  }'
```

**Expected response:**
```json
{
  "output": "Hello! I can help you with..."
}
```

---

### **Test 2: Using Postman**

**Request:**
- **Method:** POST
- **URL:** Your webhook URL
- **Headers:** `Content-Type: application/json`
- **Body (raw JSON):**
```json
{
  "action": "sendMessage",
  "sessionId": "postman-test-123",
  "chatInput": "Test message from Postman",
  "route": "test"
}
```

**Response should contain:**
```json
{
  "output": "Your bot's response"
}
```

---

### **Test 3: Using the Widget**

1. Open `http://localhost:8080/fullscreen.html?botId=your-bot-id`
2. Send a message
3. Check console (F12):
   - Should see: `POST https://your-webhook-url`
   - Should receive: `{output: "..."}`
4. Response should appear in chat

---

## 🔧 **Updating Webhook URL in Database**

### **Set Your Webhook URL:**

```sql
UPDATE bot_configurations 
SET webhook_url = 'https://hussyaiexp.app.n8n.cloud/webhook-test/shoe-assistant'
WHERE bot_id = 'shoe-wala';
```

### **Verify:**

```sql
SELECT bot_id, name, webhook_url 
FROM bot_configurations 
WHERE bot_id = 'shoe-wala';
```

---

## ❌ **Common Errors & Solutions**

### **Error 1: CORS Policy Error**

```
Access to fetch at '...' has been blocked by CORS policy
```

**Solution:** Add to n8n Webhook node → Options → Response Headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

### **Error 2: "No response received"**

**Widget shows:** "No response received."

**Cause:** N8N didn't return proper format

**Solution:** Ensure response has `output` field:
```json
{
  "output": "Your message here"
}
```

---

### **Error 3: Webhook Timeout**

**Widget shows:** Typing indicator forever

**Causes:**
- N8N workflow taking too long (> 30s)
- Webhook node set to wrong response mode

**Solutions:**
1. Change Webhook Response Mode to "When Last Node Finishes"
2. Optimize your workflow
3. Use async method for long processes

---

### **Error 4: Invalid JSON Response**

```
❌ JSON parse error
```

**Cause:** N8N returned HTML or non-JSON

**Solution:** 
- Check n8n execution logs
- Ensure "Respond to Webhook" returns JSON
- Don't add extra text nodes after response

---

## 📊 **N8N Workflow Examples**

### **Example 1: Simple Keywords Bot**

```javascript
// Code Node
const message = $input.item.json.chatInput.toLowerCase();
let response;

if (message.includes('price') || message.includes('cost')) {
  response = "Our prices start at $99/month. Visit our pricing page for details!";
} else if (message.includes('support') || message.includes('help')) {
  response = "I'm here to help! What do you need assistance with?";
} else if (message.includes('hours') || message.includes('open')) {
  response = "We're open Monday-Friday, 9 AM - 5 PM EST.";
} else {
  response = "Thanks for your message! How can I assist you today?";
}

return [{ output: response }];
```

---

### **Example 2: AI with Context (Using Session)**

```javascript
// Code Node - Store conversation history
const sessionId = $input.item.json.sessionId;
const userMessage = $input.item.json.chatInput;

// In real workflow, fetch from database using sessionId
const conversationHistory = [
  { role: "system", content: "You are a helpful assistant" },
  { role: "user", content: userMessage }
];

// Pass to OpenAI node, then format response:
return [{
  output: $input.item.json.choices[0].message.content
}];
```

---

## 🎯 **Best Practices**

### **1. Always Return Proper Format**
```json
{ "output": "message" }  ✅
{ "response": "message" } ❌
{ "text": "message" }     ❌
```

### **2. Set Webhook Response Mode Correctly**
- Use: "When Last Node Finishes"
- Not: "Immediately"

### **3. Handle Errors Gracefully**
```javascript
try {
  // Your logic
  return [{ output: response }];
} catch (error) {
  return [{ output: "Sorry, I encountered an error. Please try again." }];
}
```

### **4. Use Session ID for Context**
- Store conversation history in database
- Retrieve based on `sessionId`
- Pass to AI for contextual responses

### **5. Test Thoroughly**
- Test with cURL first
- Then test with widget
- Check n8n execution logs

---

## 📝 **Summary**

**To send responses back to the widget:**

1. **N8N receives:** `{"chatInput": "user message", "sessionId": "..."}`
2. **N8N processes:** AI, logic, database, etc.
3. **N8N returns:** `{"output": "bot response"}`
4. **Widget displays:** Response in chat

**That's it!** The widget handles everything else automatically.

---

**Your webhook is ready when:**
- ✅ Returns JSON with `output` field
- ✅ Response mode set to "When Last Node Finishes"
- ✅ CORS headers configured (if needed)
- ✅ Tested with cURL and returns proper response

Happy chatting! 🚀
