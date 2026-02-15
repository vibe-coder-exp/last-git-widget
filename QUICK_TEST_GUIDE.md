# Quick Diagnostic Checklist

## 🚀 Test Your Fix in 3 Steps

### Step 1: Open Browser Console
1. Open your chat widget page
2. Press `F12` (or right-click → Inspect)
3. Go to **Console** tab

### Step 2: Check Initialization
Look for this message:
```
✅ Supabase client initialized successfully
```

✅ **GOOD** - Supabase is connected  
❌ **BAD** - See retry messages or errors

### Step 3: Test Message & Feedback
1. Send a message → Should see: `✅ Message saved successfully to database`
2. Close widget → Feedback modal appears
3. Submit feedback → Should see: `✅ Feedback submitted successfully`

---

## 🔧 If Still Not Working

### Quick Fixes:

**1. Clear Browser Cache**
- Press `Ctrl + Shift + Delete`
- Clear cached files
- Reload page

**2. Hard Refresh**
- Press `Ctrl + F5` (Windows)
- Press `Cmd + Shift + R` (Mac)

**3. Check Supabase URL & Key**
In `chat-widget.js` lines 20-21, verify:
```javascript
const SUPABASE_URL = 'https://uwuizytnrmjkwscagapj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGci...'; // Should be a long string
```

**4. Verify HTML Script Order**
In your HTML file, scripts should be in this order:
```html
<!-- 1. Supabase SDK FIRST -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

<!-- 2. Chat Widget SECOND -->
<script src="chat-widget.js?botId=your-bot-id"></script>
```

---

## 📊 Check Database Tables

### In Supabase Dashboard:

1. Go to **Table Editor**
2. Verify these tables exist:
   - ✅ `bot_configurations`
   - ✅ `chat_messages`  
   - ✅ `feedback`

3. Check **Policies** (Authentication tab):
   - `chat_messages` → Should have "Allow public insert" & "Allow public select"
   - `feedback` → Should have "Allow public insert" & "Allow public select"

---

## 🐛 Common Console Errors

| Error Message | Solution |
|---------------|----------|
| `Supabase library not loaded yet. Retrying...` | Normal on first load, wait for success message |
| `Cannot save message: Supabase client not initialized` | Check if Supabase CDN script is in HTML |
| `new row violates row-level security policy` | RLS policies too strict, check policies in Supabase |
| `relation 'chat_messages' does not exist` | Run `init.sql` in Supabase SQL Editor |
| `Failed to fetch` | Network issue, check internet connection |

---

## ✅ Success Indicators

**Initialization:**
- Console shows: `✅ Supabase client initialized successfully`

**Messages:**
- Console shows: `✅ Message saved successfully to database` (for each message)
- Supabase Table Editor → `chat_messages` → See new rows

**Feedback:**
- Console shows: `✅ Feedback submitted successfully`
- Supabase Table Editor → `feedback` → See new rows

**History:**
- Refresh page → Previous messages load automatically

---

## 🆘 Still Need Help?

Share these details:
1. Browser console logs (copy/paste full output)
2. Which step fails (initialization, messages, or feedback)
3. Screenshot of Supabase table policies
4. Screenshot of browser Network tab (to check for failed requests)
