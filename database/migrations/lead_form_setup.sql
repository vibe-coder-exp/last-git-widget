-- ================================================================
-- MIGRATION: LEAD FORM SETUP
-- ================================================================

-- 1. Create LEADS table
CREATE TABLE IF NOT EXISTS public.leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id TEXT NOT NULL,
    session_id UUID NOT NULL,
    name TEXT,
    email TEXT,
    phone TEXT,
    metadata JSONB DEFAULT '{}', -- For custom fields
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leads_bot_id ON public.leads(bot_id);
CREATE INDEX IF NOT EXISTS idx_leads_session_id ON public.leads(session_id);

-- 2. Update BOT_CONFIGURATIONS table
ALTER TABLE public.bot_configurations 
ADD COLUMN IF NOT EXISTS lead_collection JSONB DEFAULT '{"enabled": false, "title": "Contact Info", "fields": []}';

-- 3. RLS Policies for LEADS
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Allow public insert (User submitting form)
CREATE POLICY "Allow public insert leads"
    ON public.leads FOR INSERT
    WITH CHECK (true);

-- Allow public select (User checking their own submission - strictly speaking usually we might restrict this, 
-- but for this simple widget session-based approach, we might not strictly need it if we trust localStorage.
-- However, let's allow it for consistency if we want to check backend status).
-- For now, we only really need INSERT. Agents/Admins read via Dashboard.

-- 4. Sample Update for Demo Bot (Optional, user can run this manually to enable)
-- UPDATE public.bot_configurations
-- SET lead_collection = '{"enabled": true, "title": "Let''s get introduced", "fields": [{"name": "name", "label": "Full Name", "type": "text", "required": true}, {"name": "email", "label": "Email", "type": "email", "required": true}]}'
-- WHERE bot_id = 'demo-bot';
