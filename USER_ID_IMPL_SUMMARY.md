# ✅ User ID Implementation Complete

## 🎉 Features Added

1.  **Persistent User Tracking**:
    -   A unique `userId` is now generated for every visitor.
    -   It is saved in the browser (`localStorage`) so it persists even if they close the tab and come back later.

2.  **Linked to Leads**:
    -   When a user submits the Lead Form (Name/Email), their `userId` is saved in the lead's metadata.
    -   **Result:** You now know that "User ID 12345" is "John Doe".

3.  **Spam Prevention Ready**:
    -   The `userId` is sent with **every message** to your N8N webhook.
    -   **N8N Workflow:** You can now add logic to block specific User IDs if they send too many messages.

4.  **Database History**:
    -   Every chat message in the database now includes the `userId` in the `metadata` column.
    -   You can query "Show me all messages from User 12345" across all their sessions.

---

## 🧪 How to Verify

### **Step 1: check Local Storage**
1.  Open your chat widget.
2.  Open DevTools (F12) -> **Application** tab -> **Local Storage**.
3.  Look for `n8n_chat_user_id`.
4.  Value should be a UUID (e.g., `a1b2c3d4-...`).

### **Step 2: Check Webhook (N8N)**
1.  Send a message: "Test User ID".
2.  Check your N8N execution data.
3.  The payload will now look like:
    ```json
    {
      "action": "sendMessage",
      "chatInput": "Test User ID",
      "metadata": {
        "userId": "a1b2c3d4-..."  <-- IT IS HERE!
      }
    }
    ```

### **Step 3: Check Database**
1.  Go to Supabase -> **Table Editor** -> `chat_messages`.
2.  Look at the latest message.
3.  Check the `metadata` column.
4.  It should contain `{"userId": "..."}`.

### **Step 4: Check Leads**
1.  Submit the contact form.
2.  Go to Supabase -> **leads** table.
3.  Check the `metadata` column.
4.  It should contain the form data PLUS `userId`.

---

## 🛡️ How to Block Spammers (N8N logic)

In your N8N workflow, you can now add an **IF Node** at the start:

-   **Condition:** If `$json.metadata.userId` matches `[List of Banned IDs]`
-   **True:** Return `{"output": "You are banned."}`
-   **False:** Continue to AI.

---

**Changes were made silently inside `chat-widget.js` without breaking any existing functionality.** 🚀
