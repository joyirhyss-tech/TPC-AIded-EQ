// ======================================================
// TPC Board: Minutes Processing Edge Function
// Transforms Zoom transcript + secretary notes into
// structured, Indiana-compliant board meeting minutes.
// ======================================================
// Deploy: supabase functions deploy process-minutes
// Secret: supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { transcript, secretary_notes, meeting_date, attendees, additional_notes } = await req.json()

    const apiKey = Deno.env.get('ANTHROPIC_API_KEY')
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: 'ANTHROPIC_API_KEY not configured. Set it with: supabase secrets set ANTHROPIC_API_KEY=your-key' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const systemPrompt = `You are a nonprofit board meeting minutes processor for The Practice Center, an Indiana nonprofit corporation governed by IC 23-17.

Your job is to transform raw meeting notes and Zoom transcripts into structured, official board meeting minutes.

REQUIRED FORMAT (Indiana IC 23-17 compliant):
1. Header: Organization name, "Official Board Meeting Minutes", date, time, location
2. Attendance: List all board members as Present or Absent. Note quorum status (4 of 6 = quorum).
3. Call to Order: Who called the meeting to order and when.
4. For each agenda topic discussed:
   - Section heading with presenter name
   - Key points discussed (concise, factual)
   - Any decisions made
5. Motions & Votes: For each motion record:
   - Motion description
   - Who made the motion
   - Who seconded
   - Vote result (e.g., "Approved 5-1", "Approved unanimously")
6. Action Items: List each with owner and due date if mentioned
7. Adjournment: When the meeting adjourned

OUTPUT: Return valid JSON with this exact structure:
{
  "minutes_html": "<full HTML formatted minutes>",
  "attendees": ["name1", "name2"],
  "quorum_verified": true/false,
  "motions": [{"description": "...", "made_by": "...", "seconded_by": "...", "vote": "..."}],
  "action_items": [{"task": "...", "owner": "...", "due_date": "..."}],
  "summary": "One paragraph summary of the meeting"
}

Board Members: JoYi (ED & Board President), Alison (Board Chair), Kailani (Secretary), Gabby, Jay, Kobe
Do NOT use the title "CEO" - use "Executive Director" or "ED".
Use colons and bullets. No em dashes. No emojis.`

    const userMessage = `Process these meeting materials into official board meeting minutes:

MEETING DATE: ${meeting_date || 'February 28, 2026'}
ATTENDEES: ${attendees?.join(', ') || 'All board members'}

ZOOM TRANSCRIPT / MEETING NOTES:
${transcript || '(No transcript provided)'}

SECRETARY NOTES:
${secretary_notes || '(No secretary notes provided)'}

ADDITIONAL NOTES:
${additional_notes || '(None)'}

Return the structured JSON as specified.`

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'content-type': 'application/json',
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 4096,
        system: systemPrompt,
        messages: [{ role: 'user', content: userMessage }]
      })
    })

    if (!response.ok) {
      const errText = await response.text()
      return new Response(
        JSON.stringify({ error: `Claude API error: ${response.status} - ${errText}` }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const result = await response.json()
    const content = result.content?.[0]?.text || ''

    // Try to parse JSON from Claude's response
    let parsed
    try {
      // Extract JSON if wrapped in markdown code blocks
      const jsonMatch = content.match(/\{[\s\S]*\}/)
      parsed = JSON.parse(jsonMatch ? jsonMatch[0] : content)
    } catch {
      // If parsing fails, return raw text as minutes_html
      parsed = {
        minutes_html: content,
        attendees: attendees || [],
        quorum_verified: true,
        motions: [],
        action_items: [],
        summary: 'Minutes generated from meeting notes.'
      }
    }

    return new Response(
      JSON.stringify(parsed),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
