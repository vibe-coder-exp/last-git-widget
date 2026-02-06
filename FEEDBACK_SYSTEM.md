# Feedback System Documentation

This document explains how the **5-Star Rating Feedback System** works and how to analyze the collected data.

---

## How It Works

### User Experience

1. **Normal Flow**: User chats with the bot and clicks the "X" (Close) button.
2. **Feedback Check**: The widget checks:
   - Is feedback enabled?
   - Has the user rated within the last 24 hours?
3. **Show Rating**: If eligible, a modal appears with 5 stars.
4. **Submit or Skip**:
   - User selects 1-5 stars and clicks **Submit**
   - OR clicks **Skip** to close without rating
5. **Frequency Limit**: The same user won't see the modal again for 24 hours (configurable).

---

## Database Setup

### Step 1: Run Migration

Execute the SQL script in your Supabase SQL Editor:

```sql
-- Located at: database/migrations/feedback_setup.sql
```

This creates:
- `feedback` table (stores ratings)
- `feedback_settings` column in `bot_configurations`

### Step 2: Verify Tables

```sql
SELECT * FROM public.feedback LIMIT 10;
SELECT feedback_settings FROM public.bot_configurations WHERE bot_id = 'your-bot-id';
```

---

## Configuration

### Enable/Disable Feedback

**Default**: Enabled for all bots (24-hour frequency)

To **customize**:

```sql
UPDATE public.bot_configurations
SET feedback_settings = '{
    "enabled": true,
    "title": "How was your experience?",
    "frequency_hours": 24
}'
WHERE bot_id = 'your-bot-id';
```

To **disable** for a specific bot:

```sql
UPDATE public.bot_configurations
SET feedback_settings = '{"enabled": false}'
WHERE bot_id = 'your-bot-id';
```

### Configuration Options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | Boolean | `true` | Show/hide feedback modal |
| `title` | String | `"Rate your experience"` | Modal heading text |
| `frequency_hours` | Integer | `24` | Hours between prompts for same user |

---

## Data Analysis

### View All Feedback

```sql
SELECT 
    f.id,
    f.bot_id,
    f.rating,
    f.created_at,
    l.name AS user_name,
    l.email AS user_email
FROM public.feedback f
LEFT JOIN public.leads l ON f.lead_id = l.id
ORDER BY f.created_at DESC;
```

### Average Rating Per Bot

```sql
SELECT 
    bot_id,
    COUNT(*) AS total_ratings,
    AVG(rating) AS average_rating,
    MIN(rating) AS lowest_rating,
    MAX(rating) AS highest_rating
FROM public.feedback
GROUP BY bot_id;
```

### Track Individual User Across Sessions

This query shows how a specific user rated your bot on different days:

```sql
SELECT 
    l.name,
    l.email,
    f.session_id,
    f.rating,
    f.created_at
FROM public.feedback f
JOIN public.leads l ON f.lead_id = l.id
WHERE l.email = 'user@example.com'
ORDER BY f.created_at DESC;
```

**Example Result:**

| name | email | session_id | rating | created_at |
|------|-------|------------|--------|------------|
| John Doe | john@example.com | abc123 | 5 | 2026-02-06 12:00 |
| John Doe | john@example.com | def456 | 4 | 2026-02-05 10:30 |

### Ratings in Last 7 Days

```sql
SELECT 
    DATE(created_at) AS date,
    COUNT(*) AS total_ratings,
    AVG(rating) AS avg_rating
FROM public.feedback
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Identify Unhappy Users (1-2 Star Ratings)

```sql
SELECT 
    l.name,
    l.email,
    f.rating,
    f.created_at,
    f.session_id
FROM public.feedback f
LEFT JOIN public.leads l ON f.lead_id = l.id
WHERE f.rating <= 2
ORDER BY f.created_at DESC;
```

### Users Who Rated Multiple Times

```sql
SELECT 
    l.name,
    l.email,
    COUNT(f.id) AS num_ratings,
    AVG(f.rating) AS avg_rating
FROM public.feedback f
JOIN public.leads l ON f.lead_id = l.id
GROUP BY l.id, l.name, l.email
HAVING COUNT(f.id) > 1
ORDER BY num_ratings DESC;
```

---

## How User Tracking Works

### Cross-Session Identification

When a user first submits the **Lead Form**:
1. Their details are saved to the `leads` table
2. The `lead_id` (UUID) is saved to their **browser** (`localStorage`)
3. All future activity is tagged with this `lead_id`:
   - Chat messages ✅
   - Feedback ratings ✅

### Example Flow

**Day 1 - First Visit:**
- User fills: Name = "Jane", Email = "jane@example.com"
- Database creates: `lead_id = "550e8400-e29b-41d4-a716-446655440000"`
- Browser saves: `localStorage['n8n_chat_lead_id_demo-bot'] = "550e84..."`
- User chats, then closes -> Rates **5 stars**
- Feedback saved with `lead_id = "550e84..."`

**Day 2 - Return Visit:**
- User opens chat (browser detects stored `lead_id`)
- User chats, then closes -> Rates **4 stars**
- Feedback saved with **same** `lead_id = "550e84..."`

**Result:**
You can query Jane's feedback history and see she rated 5★ yesterday and 4★ today.

---

## Troubleshooting

### Feedback modal doesn't appear
1. Check if it's enabled:
   ```sql
   SELECT feedback_settings FROM bot_configurations WHERE bot_id = 'your-bot-id';
   ```
2. Clear browser localStorage to reset the 24-hour timer:
   ```javascript
   localStorage.removeItem('n8n_feedback_last_your-bot-id');
   ```

### Feedback appears too often
Increase the frequency:
```sql
UPDATE bot_configurations
SET feedback_settings = jsonb_set(
    feedback_settings,
    '{frequency_hours}',
    '48'  -- 48 hours = 2 days
)
WHERE bot_id = 'your-bot-id';
```

### lead_id is always NULL
This happens if users skip the Lead Form. They can still leave feedback, but won't be personally identified. You can still see their `session_id` to review the chat history.

---

## Privacy & Data Retention

### Optional: Auto-Delete Old Feedback

To comply with GDPR or reduce storage, you can delete feedback older than 90 days:

```sql
DELETE FROM public.feedback
WHERE created_at < NOW() - INTERVAL '90 days';
```

**Recommended**: Set up a Supabase Edge Function to run this monthly.

---

## Summary

✅ **Enabled by default** - No action required  
✅ **Non-intrusive** - Only shows once every 24 hours  
✅ **User tracking** - Links ratings to lead data  
✅ **Easy queries** - Analyze satisfaction trends  

For more help, see `LEAD_FORM_CONFIGURATION.md` and `README_LEADS.md`.
