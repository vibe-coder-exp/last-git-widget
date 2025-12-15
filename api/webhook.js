export default async function handler(req, res) {
    // CORS headers - Sabse pehle set karo
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // OPTIONS request handle karo (preflight)
    if (req.method === 'OPTIONS') {
        console.log('✅ Preflight request handled');
        return res.status(200).end();
    }

    // Sirf POST requests allow hain
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed. Use POST.' });
    }

    try {
        // Request body se data nikalo
        const { botId, message, ...otherData } = req.body;

        // Validation
        if (!botId) {
            return res.status(400).json({
                error: 'botId is required',
                received: req.body
            });
        }

        if (!message) {
            return res.status(400).json({
                error: 'message is required',
                received: req.body
            });
        }

        console.log('📥 Received request for botId:', botId);

        // Supabase se webhook URL fetch karo
        const supabaseUrl = 'https://uwuizytnrmjkwscagapj.supabase.co';
        const supabaseKey = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dWl6eXRucm1qa3dzY2FnYXBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxNzg5OTksImV4cCI6MjA4MDc1NDk5OX0.siCpeFl3GGnXcrTfjmC10mjO0pNoj9L7e9zn4lCSCPY;

        if (!supabaseUrl || !supabaseKey) {
            console.error('❌ Missing Supabase credentials');
            return res.status(500).json({
                error: 'Server configuration error',
                details: 'Supabase credentials not configured'
            });
        }

        // Supabase query - TABLE NAME UPDATED
        const supabaseResponse = await fetch(
            `${supabaseUrl}/rest/v1/bot_configurations?bot_id=eq.${botId}&select=webhook_url,is_active`,
            {
                headers: {
                    'apikey': supabaseKey,
                    'Authorization': `Bearer ${supabaseKey}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        if (!supabaseResponse.ok) {
            console.error('❌ Supabase error:', supabaseResponse.status);
            return res.status(500).json({
                error: 'Database query failed',
                status: supabaseResponse.status
            });
        }

        const bots = await supabaseResponse.json();

        // Check if bot exists
        if (!bots || bots.length === 0) {
            console.error('❌ Bot not found:', botId);
            return res.status(404).json({
                error: 'Bot not found',
                botId: botId,
                hint: 'Check if bot_id exists in bot_configurations table'
            });
        }

        const bot = bots[0];

        // Check if bot is active
        if (!bot.is_active) {
            console.warn('⚠️ Bot is inactive:', botId);
            return res.status(403).json({
                error: 'Bot is inactive',
                botId: botId
            });
        }

        const webhookUrl = bot.webhook_url;
        console.log('🔗 Webhook URL:', webhookUrl);

        // n8n webhook ko request bhejo
        const n8nResponse = await fetch(webhookUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message: message,
                botId: botId,
                timestamp: new Date().toISOString(),
                ...otherData
            }),
        });

        if (!n8nResponse.ok) {
            console.error('❌ N8N webhook error:', n8nResponse.status);
            return res.status(502).json({
                error: 'Webhook call failed',
                status: n8nResponse.status,
                webhookUrl: webhookUrl
            });
        }

        const responseData = await n8nResponse.json();
        console.log('✅ Webhook response received');

        // Success response
        return res.status(200).json({
            success: true,
            data: responseData,
            botId: botId
        });

    } catch (error) {
        console.error('❌ Server error:', error);
        return res.status(500).json({
            error: 'Internal server error',
            details: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
}