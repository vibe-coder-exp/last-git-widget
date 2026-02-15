# 🎯 Quick N8N Setup Cheat Sheet

## THE SIMPLE VERSION (What You Need to Know)

### **1. What the Widget Sends:**
```json
{
  "chatInput": "User's message here"
}
```

### **2. What N8N Must Return:**
```json
{
  "output": "Bot's response here"
}
```

### **That's literally it!** 🎉

---

## 📋 **3-Step N8N Workflow Setup**

```
┌─────────────┐
│  Webhook    │  ← Receives message from widget
│  (POST)     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Process    │  ← Your AI/Logic here
│  (OpenAI)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Respond    │  ← Sends response to widget
│  to Webhook │
└─────────────┘
```

---

## 🚀 **Copy-Paste N8N Workflow**

### **Node 1: Webhook**
- **Method:** POST
- **Path:** /chat
- **Response Mode:** When Last Node Finishes ⚠️ IMPORTANT!

### **Node 2: Set** (or your AI node)
- **Name:** output
- **Value:** `You said: {{ $json.chatInput }}`

### **Node 3: Respond to Webhook**
- (Just add it, connect it, done!)

---

## 🧪 **Test Your Webhook**

### **Method 1: Quick Test with cURL**
```bash
curl -X POST YOUR_WEBHOOK_URL_HERE \
  -H "Content-Type: application/json" \
  -d '{"chatInput":"test"}'
```

**Should return:**
```json
{"output":"You said: test"}
```

---

### **Method 2: Test with Widget**

1. Update webhook URL in database:
```sql
UPDATE bot_configurations 
SET webhook_url = 'YOUR_N8N_WEBHOOK_URL'
WHERE bot_id = 'your-bot-id';
```

2. Open widget
3. Send message
4. See response!

---

## ⚡ **Common Mistakes (Avoid These!)**

### ❌ **WRONG Response Format:**
```json
{ "response": "text" }  ← Won't work
{ "message": "text" }   ← Won't work
{ "text": "text" }      ← Won't work
```

### ✅ **CORRECT Response Format:**
```json
{ "output": "text" }    ← This works!
```

---

### ❌ **WRONG Webhook Mode:**
Response Mode: "Immediately" ← CORS errors, timeouts

### ✅ **CORRECT Webhook Mode:**
Response Mode: "When Last Node Finishes" ← Works perfectly

---

## 🎨 **Example: Real Estate Bot**

### **User says:** "Show me 3 bedroom houses"

### **N8N Code Node:**
```javascript
const message = $input.item.json.chatInput;

return [{
  output: "Great! I found 5 three-bedroom houses:\n\n" +
          "1. Modern Villa - $450K\n" +
          "2. Suburban Home - $380K\n" +
          "3. Downtown Loft - $520K\n\n" +
          "Which one interests you?"
}];
```

### **Widget displays:** Exactly that message!

---

## 🔄 **The Complete Flow**

```
USER TYPES: "Hello"
    ↓
WIDGET SENDS TO N8N:
{
  "chatInput": "Hello",
  "sessionId": "abc-123",
  "botId": "my-bot"
}
    ↓
N8N RECEIVES IT
    ↓
N8N PROCESSES (AI, Logic, etc.)
    ↓
N8N RETURNS:
{
  "output": "Hi! How can I help?"
}
    ↓
WIDGET RECEIVES IT
    ↓
USER SEES: "Hi! How can I help?"
```

---

## 🆘 **Troubleshooting in 30 Seconds**

### **Problem: No response appears**

**Check 1:** Test webhook with cURL
```bash
curl -X POST YOUR_URL -H "Content-Type: application/json" -d '{"chatInput":"test"}'
```

**Check 2:** Does it return `{"output":"something"}`?
- ✅ Yes → Webhook works! Check database URL
- ❌ No → Fix N8N workflow

**Check 3:** Check database:
```sql
SELECT webhook_url FROM bot_configurations WHERE bot_id = 'your-bot';
```
Does it match your N8N webhook URL?

---

## 💡 **Pro Tips**

### **1. Use OpenAI Node for AI Responses:**
```
Webhook → OpenAI Chat → Set → Respond to Webhook
```
Set node: `output = {{ $json.message.content }}`

### **2. Access User Message:**
Use: `{{ $json.chatInput }}`

### **3. Access Session ID (for context):**
Use: `{{ $json.sessionId }}`

### **4. Test in N8N First:**
Click "Execute Workflow" with test data before connecting widget

---

## ✅ **Quick Checklist**

Before going live:

- [ ] Webhook Response Mode = "When Last Node Finishes"
- [ ] Response format = `{"output": "text"}`
- [ ] Tested with cURL (returns proper JSON)
- [ ] Updated webhook_url in database
- [ ] Widget shows responses correctly

---

## 🎯 **Remember:**

**Widget sends:** `chatInput` (the message)  
**N8N returns:** `output` (the response)

**That's all you need to know!** 🚀

---

**Need the detailed guide?** See: `N8N_WEBHOOK_COMPLETE_GUIDE.md`
