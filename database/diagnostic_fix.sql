-- ================================================================
-- DIAGNOSTIC & FIX SCRIPT FOR MESSAGE SAVING ISSUES
-- Run this in Supabase SQL Editor
-- ================================================================

-- STEP 1: Check if chat_messages table exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages'
) AS chat_messages_exists;

-- Expected: chat_messages_exists = true
-- If false: Run the init.sql script first

-- ================================================================
-- STEP 2: Check table structure
-- ================================================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- Expected columns:
-- id (uuid)
-- session_id (uuid)
-- bot_id (text)
-- sender_type (text)
-- content (text)
-- metadata (jsonb)
-- created_at (timestamp with time zone)

-- ================================================================
-- STEP 3: Check RLS status
-- ================================================================
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'chat_messages';

-- Expected: rowsecurity = true
-- If false, RLS is disabled (which is actually OK for testing)

-- ================================================================
-- STEP 4: Check existing policies
-- ================================================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'chat_messages';

-- Expected: 2 policies
-- 1. "Allow public insert messages" - cmd = INSERT
-- 2. "Allow public select messages" - cmd = SELECT

-- ================================================================
-- STEP 5: Drop and recreate policies (FIX)
-- ================================================================
-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public insert messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Allow public select messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.chat_messages;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.chat_messages;

-- Enable RLS
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Create permissive policies that allow public access
CREATE POLICY "Allow public insert messages"
    ON public.chat_messages
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow public select messages"
    ON public.chat_messages
    FOR SELECT
    USING (true);

-- Verify policies were created
SELECT policyname, cmd, with_check, qual
FROM pg_policies
WHERE tablename = 'chat_messages';

-- ================================================================
-- STEP 6: Test manual insert
-- ================================================================
INSERT INTO public.chat_messages (
    session_id, 
    bot_id, 
    sender_type, 
    content,
    metadata
)
VALUES (
    gen_random_uuid(),
    'realestate-assistant',
    'user',
    'Test message from SQL',
    '{}'::jsonb
);

-- If this fails, copy the error message!

-- ================================================================
-- STEP 7: Verify insert worked
-- ================================================================
SELECT 
    id,
    bot_id,
    sender_type,
    content,
    created_at
FROM public.chat_messages
ORDER BY created_at DESC
LIMIT 5;

-- You should see your test message
-- If not, there's a deeper issue

-- ================================================================
-- STEP 8: Check realtime publication
-- ================================================================
SELECT pubname, tablename 
FROM pg_publication_tables 
WHERE tablename = 'chat_messages';

-- Expected: pubname = 'supabase_realtime'
-- If missing, run:
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- ================================================================
-- STEP 9: Grant permissions to anon role
-- ================================================================
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON public.chat_messages TO anon;

-- This ensures the anon key can access the table

-- ================================================================
-- STEP 10: Clean up test data (optional)
-- ================================================================
-- DELETE FROM public.chat_messages 
-- WHERE content = 'Test message from SQL';

-- ================================================================
-- FINAL VERIFICATION
-- ================================================================
SELECT 
    'Table exists: ' || EXISTS(SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'chat_messages')::text AS check_1,
    'RLS enabled: ' || (SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'chat_messages')::text AS check_2,
    'Policies count: ' || (SELECT COUNT(*)::text FROM pg_policies WHERE tablename = 'chat_messages') AS check_3,
    'Row count: ' || (SELECT COUNT(*)::text FROM public.chat_messages) AS check_4;

-- Expected output:
-- check_1: Table exists: true
-- check_2: RLS enabled: true
-- check_3: Policies count: 2
-- check_4: Row count: 1 (or more if you have existing data)

-- ================================================================
-- EMERGENCY FIX: Disable RLS temporarily (TESTING ONLY!)
-- ================================================================
-- Only use this if you need to test if RLS is the issue
-- NEVER leave this disabled in production!

-- ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- Test your app, then immediately re-enable:
-- ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- NOTES
-- ================================================================
-- If messages still don't save after running this:
-- 1. Check browser console for errors
-- 2. Check Network tab for failed requests
-- 3. Verify SUPABASE_URL and SUPABASE_ANON_KEY in chat-widget.js
-- 4. Make sure Supabase client initializes: "✅ Supabase client initialized successfully"
