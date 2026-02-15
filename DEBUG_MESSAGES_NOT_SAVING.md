# 🔍 Debug Guide: Messages Not Appearing in Database

## Step 1: Verify Table Name
The correct table name is: `public.chat_messages` (NOT `public.message`)

---

## Step 2: Open Browser Console (CRITICAL)

1. Open http://localhost:8080/fullscreen.html?botId=realestate-assistant
2. Press **F12** to open Developer Tools
3. Go to **Console** tab
4. Clear the console (click the 🚫 icon)

---

## Step 3: Check Initialization Logs

Look for these messages in order:

### ✅ Expected Success Messages:
```
✅ Supabase client initialized successfully
```

### ⚠️ If You See Retry Messages (Normal):
```
⏳ Supabase library not loaded yet. Retrying in 1000ms... (Attempt 1/5)
⏳ Supabase library not loaded yet. Retrying in 2000ms... (Attempt 2/5)
✅ Supabase client initialized successfully  <- Should eventually succeed
```

### ❌ If You See This Error:
```
❌ Supabase JS client not found after multiple retries
```
**Problem:** Supabase library not loading
**Fix:** Check if `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2">` is in your HTML

---

## Step 4: Test Message Sending

1. Click "Start Chat" button
2. Send a test message: "Hello"
3. Watch the console

### ✅ Expected Console Output:
```
📝 Saving message to database: {senderType: 'user', contentLength: 5}
✅ Message saved successfully to database
```

### ❌ If You See This Warning:
```
⚠️ Cannot save message to database: Supabase client not initialized
```
**Problem:** Client didn't initialize
**Next Step:** Go back to Step 3, check initialization

### ❌ If You See This Error:
```
❌ Error saving message to DB: {code: "42501", message: "new row violates row-level security policy"}
```
**Problem:** RLS policies are blocking inserts
**Fix:** Run the RLS fix (see Step 7 below)

### ❌ If You See This Error:
```
❌ Error saving message to DB: {code: "42P01", message: "relation 'chat_messages' does not exist"}
```
**Problem:** Table doesn't exist
**Fix:** Run the database initialization script (see Step 6 below)

---

## Step 5: Copy ALL Console Logs

**DO THIS NOW:**
1. Right-click in the console
2. Click "Save as..."
3. Or copy all text and paste to a file

Share these logs - they contain the exact error!

---

## Step 6: Verify Database Tables Exist

### In Supabase Dashboard:

1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **Table Editor** (left sidebar)
4. Check if these tables exist:
   - ✅ `bot_configurations`
   - ✅ `chat_messages` <- THIS ONE IS CRITICAL
   - ✅ `feedback`

### If `chat_messages` Table is Missing:

1. Go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Paste the contents of `deployment/last-git-widget/database/init.sql`
4. Click **Run**
5. Verify tables appear in Table Editor

---

## Step 7: Check Row Level Security (RLS) Policies

### Check Policies:

1. Go to **Authentication** → **Policies** (left sidebar)
2. Find `chat_messages` table
3. You should see 2 policies:
   - **"Allow public insert messages"** - FOR INSERT
   - **"Allow public select messages"** - FOR SELECT

### If Policies Are Missing:

Run this SQL in **SQL Editor**:

```sql
-- Enable RLS
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert messages
CREATE POLICY "Allow public insert messages"
    ON public.chat_messages FOR INSERT
    WITH CHECK (true);

-- Allow anyone to select messages
CREATE POLICY "Allow public select messages"
    ON public.chat_messages FOR SELECT
    USING (true);
```

### If Policies Exist But Still Not Working:

Check if the policies are **ENABLED**:
```sql
-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'chat_messages';
```

Should return 2 rows showing INSERT and SELECT policies.

---

## Step 8: Verify Supabase URL and Key

### In `chat-widget.js` (lines 20-21):

```javascript
const SUPABASE_URL = 'https://uwuizytnrmjkwscagapj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGci...'; // Long string
```

### Check These Are Correct:

1. Go to Supabase Dashboard
2. Click **Settings** → **API**
3. Compare:
   - **Project URL** should match SUPABASE_URL
   - **anon/public** key should match SUPABASE_ANON_KEY

### If They Don't Match:

Update `chat-widget.js` lines 20-21 with correct values.

---

## Step 9: Manual Database Insert Test

### Test if you can insert manually:

1. Go to Supabase **SQL Editor**
2. Run this query:

```sql
INSERT INTO public.chat_messages (session_id, bot_id, sender_type, content)
VALUES (
    'test-session-123',
    'realestate-assistant',
    'user',
    'Manual test message'
);
```

### If This Fails:
- Error message will show the exact problem
- Likely RLS policy issue or table structure mismatch

### If This Works:
- Database is working fine
- Problem is in the JavaScript code or initialization
- Check console logs again (Step 3)

---

## Step 10: Check Network Tab

1. Open **Network** tab in Developer Tools
2. Clear network log
3. Send a message
4. Look for requests to Supabase

### You Should See:
- **Request URL**: `https://...supabase.co/rest/v1/chat_messages`
- **Method**: POST
- **Status**: 201 (Created) ✅

### If Status is 400/401/403:
- Click on the request
- Go to **Response** tab
- Copy the error message
- This shows the exact issue

### If No Request Appears:
- Supabase client is not initialized
- Check Step 3 initialization logs

---

## Step 11: Common Issues Checklist

Check each item:

- [ ] Table is named `chat_messages` not `message`
- [ ] Supabase script loads before widget script
- [ ] Browser console shows "✅ Supabase client initialized"
- [ ] SUPABASE_URL matches project URL
- [ ] SUPABASE_ANON_KEY matches anon key
- [ ] RLS policies exist and use `WITH CHECK (true)` and `USING (true)`
- [ ] Network tab shows POST to chat_messages
- [ ] No CORS errors in console
- [ ] Internet connection is working

---

## Step 12: Quick Network Test

### Test if Supabase is reachable:

Open a new tab and visit:
```
https://uwuizytnrmjkwscagapj.supabase.co/rest/v1/
```

Should return:
```json
{"message":"Welcome to PostgREST"}
```

If you get a connection error:
- Check firewall
- Check internet connection
- Verify Supabase project is active

---

## 📊 What to Share for Help

If still not working, share:

1. **Console logs** (all of them, from page load to message send)
2. **Network tab screenshot** (showing the POST request or lack thereof)
3. **SQL query result** from Step 9 (manual insert test)
4. **Screenshot of RLS policies** from Supabase dashboard
5. **Table structure** - click on chat_messages table in Supabase, screenshot columns

---

## 🎯 Most Common Causes (in order):

1. **RLS policies blocking inserts** (60% of cases)
2. **Supabase client not initializing** (25% of cases)
3. **Wrong table name** (10% of cases)
4. **Wrong Supabase URL/Key** (5% of cases)

---

## Quick Fix Attempt

If you want to try a quick nuclear option:

### Disable RLS Temporarily (FOR TESTING ONLY):

```sql
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;
```

Then test. If messages appear:
- Problem is RLS policies
- Re-enable RLS and fix policies properly
- Never leave RLS disabled in production!

```sql
-- Re-enable after testing
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
```
