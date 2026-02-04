# Pre-Chat Leads Form Implementation

We have added a customizable pre-chat form that allows you to collect user details (Name, Email, Phone) before they start a conversation.

## 1. Database Setup (Required)

You must run the migration script to create the `leads` table and update the configuration schema.

1.  Open your **Supabase SQL Editor**.
2.  Copy the contents of `deployment/last-git-widget/database/migrations/lead_form_setup.sql`.
3.  Run the script.

## 2. Enabling the Form

The form is **disabled by default**. To enable it:

### Option A: Use the Admin Generator (Recommended)
1.  Open `deployment/last-git-widget/tools/admin-generator.html` in your browser.
2.  Fill in your bot details.
3.  Scroll to **Lead Collection (Pre-Chat Form)**.
4.  Check **Enable Pre-chat Form**.
5.  Select the fields you want to collect.
6.  Generate the SQL and run it in Supabase.

### Option B: Manual SQL Update
Run this query for your specific bot:

```sql
UPDATE public.bot_configurations 
SET lead_collection = '{
    "enabled": true, 
    "title": "Share your contact details", 
    "fields": [
        {"name": "name", "label": "Full Name", "type": "text", "required": true},
        {"name": "email", "label": "Email Address", "type": "email", "required": true}
    ]
}'
WHERE bot_id = 'your-bot-id';
```

## 3. How it Works

1.  When a user opens the chat, the widget checks if `lead_collection.enabled` is true.
2.  It checks `localStorage` to see if the user has already submitted the form for this bot.
3.  If not submitted, it displays the Form instead of the Chat Interface.
4.  On submit:
    *   Data is saved to the `leads` table in Supabase.
    *   Data is saved to `localStorage`.
    *   The Chat Interface opens.

## 4. Verification

1.  Update your `demo-bot` configuration using Option B above.
2.  Open `index.html`.
3.  Click the chat bubble. You should see the form.
4.  Fill it out and submit.
5.  Check the `leads` table in Supabase to see the new entry.
