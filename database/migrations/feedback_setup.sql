-- ================================================================
-- MIGRATION: FEEDBACK SYSTEM SETUP
-- ================================================================

-- 1. Create FEEDBACK table
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id TEXT NOT NULL,
    session_id TEXT NOT NULL,
    lead_id UUID, -- Links to leads table for user identification
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feedback_bot_id ON public.feedback(bot_id);
CREATE INDEX IF NOT EXISTS idx_feedback_lead_id ON public.feedback(lead_id);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON public.feedback(created_at);

-- 2. Update BOT_CONFIGURATIONS table
ALTER TABLE public.bot_configurations 
ADD COLUMN IF NOT EXISTS feedback_settings JSONB DEFAULT '{
    "enabled": true, 
    "title": "Rate your experience", 
    "frequency_hours": 24
}';

-- 3. RLS Policies for FEEDBACK
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Allow public insert (User submitting feedback)
CREATE POLICY "Allow public insert feedback"
    ON public.feedback FOR INSERT
    WITH CHECK (true);

-- Allow authenticated select (For admins/dashboard to view feedback)
-- For now, we allow public select too for simplicity
CREATE POLICY "Allow public select feedback"
    ON public.feedback FOR SELECT
    USING (true);

-- 4. Foreign Key Constraint (Optional, for referential integrity)
-- This ensures lead_id points to a valid lead IF it exists
ALTER TABLE public.feedback 
ADD CONSTRAINT fk_feedback_lead 
FOREIGN KEY (lead_id) REFERENCES public.leads(id) 
ON DELETE SET NULL;

-- 5. Sample Update for Demo Bot (Optional)
-- UPDATE public.bot_configurations
-- SET feedback_settings = '{"enabled": true, "title": "How was your experience?", "frequency_hours": 24}'
-- WHERE bot_id = 'demo-bot';
