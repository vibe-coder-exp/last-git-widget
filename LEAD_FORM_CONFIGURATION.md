# Lead Form Configuration Guide

This guide explains how to **add, remove, or update** the pre-chat lead collection form in your chat widget.

---

## Table of Contents
1. [Understanding the Lead Form](#understanding-the-lead-form)
2. [Enabling/Disabling the Form](#enablingdisabling-the-form)
3. [Adding Custom Fields](#adding-custom-fields)
4. [Removing Fields](#removing-fields)
5. [Updating Existing Fields](#updating-existing-fields)
6. [Changing the Form Title](#changing-the-form-title)
7. [Configuration Examples](#configuration-examples)

---

## Understanding the Lead Form

The lead form collects user information before they start chatting. The configuration is stored in the `bot_configurations` table under the `lead_collection` column (JSONB format).

### Structure:
```json
{
  "enabled": true,
  "title": "Your form title",
  "fields": [
    {
      "name": "field_name",
      "label": "Display Label",
      "type": "text|email|tel|number",
      "required": true,
      "placeholder": "Optional placeholder text"
    }
  ]
}
```

---

## Enabling/Disabling the Form

### Method 1: Using Admin Generator (Easiest)
1. Open `tools/admin-generator.html` in your browser
2. Fill in your bot configuration
3. Scroll to **"Lead Collection (Pre-Chat Form)"**
4. Check/uncheck **"Enable Pre-chat Form"**
5. Copy and run the generated SQL in Supabase

### Method 2: Direct SQL Update

**To ENABLE the form:**
```sql
UPDATE public.bot_configurations 
SET lead_collection = jsonb_set(
    COALESCE(lead_collection, '{}'),
    '{enabled}',
    'true'
)
WHERE bot_id = 'your-bot-id';
```

**To DISABLE the form:**
```sql
UPDATE public.bot_configurations 
SET lead_collection = jsonb_set(
    COALESCE(lead_collection, '{}'),
    '{enabled}',
    'false'
)
WHERE bot_id = 'your-bot-id';
```

---

## Adding Custom Fields

### Method 1: Using Admin Generator
1. Open `tools/admin-generator.html`
2. Go to **Lead Collection** section
3. Check **Enable Pre-chat Form**
4. Check the fields you want to include (Name, Email, Phone)
5. Currently, custom fields must be added manually via SQL (see Method 2)

### Method 2: Direct SQL Update

**Example: Adding a "Company" field**
```sql
UPDATE public.bot_configurations 
SET lead_collection = '{
    "enabled": true,
    "title": "Contact Information",
    "fields": [
        {"name": "name", "label": "Full Name", "type": "text", "required": true},
        {"name": "email", "label": "Email", "type": "email", "required": true},
        {"name": "phone", "label": "Phone Number", "type": "tel", "required": false},
        {"name": "company", "label": "Company Name", "type": "text", "required": false, "placeholder": "Optional"}
    ]
}'
WHERE bot_id = 'your-bot-id';
```

### Supported Field Types:
- `text` - Plain text input
- `email` - Email validation
- `tel` - Phone number
- `number` - Numeric input only

### Field Properties:
- `name` *(required)* - Database column name (use lowercase, underscores for spaces)
- `label` *(required)* - Display text shown to the user
- `type` *(required)* - Input type (text, email, tel, number)
- `required` *(optional)* - Boolean, defaults to `false`
- `placeholder` *(optional)* - Hint text inside the input field

---

## Removing Fields

### Using SQL:

**Example: Removing the "phone" field**
```sql
UPDATE public.bot_configurations 
SET lead_collection = '{
    "enabled": true,
    "title": "Contact Information",
    "fields": [
        {"name": "name", "label": "Full Name", "type": "text", "required": true},
        {"name": "email", "label": "Email", "type": "email", "required": true}
    ]
}'
WHERE bot_id = 'your-bot-id';
```

Simply **remove the entire field object** from the `fields` array.

---

## Updating Existing Fields

### Using SQL:

**Example: Making email optional instead of required**
```sql
UPDATE public.bot_configurations 
SET lead_collection = '{
    "enabled": true,
    "title": "Contact Information",
    "fields": [
        {"name": "name", "label": "Full Name", "type": "text", "required": true},
        {"name": "email", "label": "Email (Optional)", "type": "email", "required": false}
    ]
}'
WHERE bot_id = 'your-bot-id';
```

**Example: Changing field labels**
```sql
UPDATE public.bot_configurations 
SET lead_collection = '{
    "enabled": true,
    "title": "Get Started",
    "fields": [
        {"name": "name", "label": "Your Name", "type": "text", "required": true},
        {"name": "email", "label": "Your Email", "type": "email", "required": true},
        {"name": "phone", "label": "Contact Number", "type": "tel", "required": false}
    ]
}'
WHERE bot_id = 'your-bot-id';
```

---

## Changing the Form Title

The `title` field controls the heading displayed at the top of the lead form.

### Using SQL:
```sql
UPDATE public.bot_configurations 
SET lead_collection = jsonb_set(
    lead_collection,
    '{title}',
    '"Let us know how to reach you"'
)
WHERE bot_id = 'your-bot-id';
```

---

## Configuration Examples

### Example 1: Minimal Form (Name + Email Only)
```json
{
  "enabled": true,
  "title": "Quick Start",
  "fields": [
    {"name": "name", "label": "Name", "type": "text", "required": true},
    {"name": "email", "label": "Email", "type": "email", "required": true}
  ]
}
```

### Example 2: Complete Contact Form
```json
{
  "enabled": true,
  "title": "Contact Details",
  "fields": [
    {"name": "name", "label": "Full Name", "type": "text", "required": true},
    {"name": "email", "label": "Email Address", "type": "email", "required": true},
    {"name": "phone", "label": "Phone Number", "type": "tel", "required": false},
    {"name": "company", "label": "Company", "type": "text", "required": false}
  ]
}
```

### Example 3: Real Estate Lead Form
```json
{
  "enabled": true,
  "title": "Find Your Dream Home",
  "fields": [
    {"name": "name", "label": "Your Name", "type": "text", "required": true},
    {"name": "email", "label": "Email", "type": "email", "required": true},
    {"name": "phone", "label": "Phone", "type": "tel", "required": true},
    {"name": "budget", "label": "Max Budget", "type": "number", "required": false, "placeholder": "e.g., 500000"}
  ]
}
```

### Example 4: Support Form (No Phone)
```json
{
  "enabled": true,
  "title": "How can we help?",
  "fields": [
    {"name": "name", "label": "Name", "type": "text", "required": true},
    {"name": "email", "label": "Email", "type": "email", "required": true}
  ]
}
```

---

## Testing Your Changes

After updating the configuration:

1. **Clear browser cache** or open an **incognito window**
2. **Clear localStorage** for your site:
   - Open browser console (F12)
   - Run: `localStorage.clear()`
   - Refresh the page
3. Open the chat widget
4. You should see your updated form

---

## Viewing Submitted Leads

All submitted lead data is stored in the `leads` table in Supabase.

### Query to view all leads:
```sql
SELECT * FROM public.leads 
ORDER BY created_at DESC;
```

### Query leads for a specific bot:
```sql
SELECT * FROM public.leads 
WHERE bot_id = 'your-bot-id'
ORDER BY created_at DESC;
```

### Query recent leads (last 24 hours):
```sql
SELECT * FROM public.leads 
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

---

## Troubleshooting

### Form doesn't appear
- Check that `enabled` is set to `true`
- Clear localStorage: `localStorage.removeItem('n8n_chat_lead_your-bot-id')`
- Verify the SQL was executed successfully

### Form keeps appearing after submission
- Check browser console for JavaScript errors
- Verify the `leads` table exists and has proper RLS policies
- Ensure Supabase URL and API key are correct in `chat-widget.js`

### Custom fields not saving
- Custom fields are stored in the `metadata` JSONB column of the `leads` table
- Standard fields (name, email, phone) have dedicated columns
- Check the browser console for errors during form submission

---

## Need Help?

- Review `README_LEADS.md` for initial setup instructions
- Check `database/migrations/lead_form_setup.sql` for database schema
- Open browser console (F12) to see any JavaScript errors
