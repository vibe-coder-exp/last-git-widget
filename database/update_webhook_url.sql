-- ================================================================
-- UPDATE WEBHOOK URL SCRIPT
-- ================================================================

-- 1. Replace 'YOUR_WEBHOOK_URL_HERE' with your actual N8N Production URL.
-- 2. Run this script in the Supabase SQL Editor.

UPDATE bot_configurations
SET webhook_url = 'YOUR_WEBHOOK_URL_HERE'
WHERE bot_id = 'shoe-wala'; -- Make sure this matches your botId in the URL

-- ================================================================
-- VERIFICATION
-- ================================================================
SELECT name, bot_id, webhook_url 
FROM bot_configurations 
WHERE bot_id = 'shoe-wala';
