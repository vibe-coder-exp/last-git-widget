# 🛍️ Shopify Integration Guide

This guide explains how to add your **Enterprise Realtime Chat Widget** to any Shopify store.

## The Vercel Method (Easiest) 🚀

Since you have already deployed on Vercel, you can simply use your Vercel URL. This is the **cleanest** and **easiest** method.

1.  Log in to your **Shopify Admin**.
2.  Go to **Online Store** > **Themes**.
3.  Click the **three dots (...)** next to your current theme and select **Edit code**.
4.  In the left sidebar, verify under **Layout**, click on `theme.liquid`.
5.  Scroll to the very bottom, just before the closing `</body>` tag.
6.  Paste the following code snippet:

```html
<!-- Enterprise Chat Widget -->
<!-- 1. Supabase SDK (Required) -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

<!-- 2. Your Chat Widget -->
<!-- REPLACE 'your-app-name.vercel.app' WITH YOUR ACTUAL VERCEL DOMAIN -->
<script src="https://your-app-name.vercel.app/chat-widget.js?botId=your-bot-id"></script>
```

---

### 📝 Configuration Checklist

1.  **Vercel Domain**: Ensure you use your real domain (e.g., `https://my-awesome-chat.vercel.app`).
2.  **Bot ID**: Change `botId=your-bot-id` to the ID of the bot you want to show (e.g., `botId=support-bot`).
3.  **Supabase**: Do **not** remove the Supabase SDK line; the widget needs it to talk to the database.

---

### ❓ Troubleshooting

**Widget not appearing?**
1.  Open your store in a new tab.
2.  Right-click > **Inspect** (or F12).
3.  Go to the **Console** tab.
4.  If you see "404 Not Found" for `chat-widget.js`:
    *   Check your Vercel URL.
    *   Make sure `chat-widget.js` is in the `public` or root folder of your Vercel deployment.
    *   *If your project structure has `deployment/chat-widget.js`, your URL might be `.../deployment/chat-widget.js` or you may need to adjust your Vercel Root Directory settings.*

**"Bot ID not provided"?**
*   Check that you added `?botId=...` to the end of your script URL.
