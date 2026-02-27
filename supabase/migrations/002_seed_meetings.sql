-- ======================================================
-- TPC Board App: Seed Data for Feb 28 + Feb 7 Meetings
-- ======================================================
-- Run this in Supabase SQL Editor after 001_schema.sql
-- Replace profile UUIDs with actual values after board members create accounts
-- JoYi's UUID: 90d84ab7-fe9d-4d97-be7e-555f81feadf3

-- ======================================================
-- 1. MEETINGS
-- ======================================================

-- Feb 28, 2026: Special Board Meeting (upcoming)
INSERT INTO meetings (id, date, time, location, zoom_link, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  '2026-02-28',
  '11:00',
  'Zoom',
  'https://us02web.zoom.us/j/87830852593',
  'scheduled',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
)
ON CONFLICT (id) DO UPDATE SET
  time = '11:00',
  zoom_link = 'https://us02web.zoom.us/j/87830852593';

-- Feb 7, 2026: Board Meeting (completed, needs minutes approval)
INSERT INTO meetings (id, date, time, location, zoom_link, status, created_by)
VALUES (
  'a1b2c3d4-0002-4000-8000-000000000002',
  '2026-02-07',
  '11:00',
  'Zoom',
  NULL,
  'completed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
)
ON CONFLICT (id) DO UPDATE SET
  status = 'completed',
  time = '11:00';

-- ======================================================
-- 2. AGENDA ITEMS for Feb 28 Meeting
-- ======================================================

-- Item 1: Welcome + Call to Order
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Welcome + Call to Order',
  'Alison calls meeting to order. Confirm quorum. Guided centering moment. Welcome guests. Share purpose: from mission to practice to impact.',
  5,
  'Board Business',
  1,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 2: ED + Board President Updates
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'ED + Board President Updates',
  'JoYi covers the big picture: AIdedEQ as TPC''s new technology arm, the market gap, the March 6-8 hackathon, and how AIdedEQ connects to TPC.',
  15,
  'Board Business',
  2,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 3: AIdedEQ Website Walkthrough
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'AIdedEQ: Website Walkthrough',
  'Live walkthrough of aidedeq.com. Mission, vision, who we serve, our focus, how we build, how to get involved.',
  10,
  'AIdedEQ Updates',
  3,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 4: AIdedEQ Tools: Mission to Practice
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'AIdedEQ Tools: Mission to Practice',
  'Gabby presents the Pocket Facilitator, tools in development, hackathon submission builder. Community vote on which tools to present at hackathon.',
  10,
  'AIdedEQ Updates',
  4,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 5: Marketing, Market Research + Our Edge
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Marketing, Market Research + Our Edge',
  'Kailani covers market landscape, competitive differentiators, target audiences, and key metrics for next quarter.',
  10,
  'Programs',
  5,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 6: Girls Who Vibe Program Update
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Girls Who Vibe: Program Update',
  'Spring break playbook status, community engagement metrics, how GWV feeds into AIdedEQ, partnership opportunities.',
  10,
  'Programs',
  6,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 7: Open Discussion + Small Group Time
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Open Discussion + Small Group Time',
  'Facilitated dialogue with discussion prompts. Small group breakout (3-4 people, 5 min). Report back key insights.',
  15,
  'Open Discussion',
  7,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 8: Revenue + Funding
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Revenue + Funding',
  'Alison leads: current financial position, funding goals, funding sources, how people can support, revenue model for AIdedEQ tools.',
  10,
  'Revenue & Funding',
  8,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 9: Internal Board Business
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Internal Board Business',
  'Approval of previous meeting minutes. New business items. AIdedEQ corporate arm motions. Bylaw updates. Committee reports.',
  10,
  'Board Business',
  9,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- Item 10: Closing Circle
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, created_by)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Closing Circle',
  'Recap key decisions and action items. Each member shares one word/phrase. Confirm next meeting date. Motion to adjourn.',
  5,
  'Board Business',
  10,
  'confirmed',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
);

-- ======================================================
-- 3. FEB 7 MEETING MINUTES (pending approval)
-- ======================================================

INSERT INTO meeting_minutes (id, meeting_id, content_html, attendees, quorum_verified, status, generated_by)
VALUES (
  'a1b2c3d4-0003-4000-8000-000000000003',
  'a1b2c3d4-0002-4000-8000-000000000002',
  '<h3 style="font-family:Playfair Display,serif;text-align:center;">The Practice Center</h3>
<h4 style="font-family:Playfair Display,serif;text-align:center;">Board Meeting Minutes</h4>
<hr style="border:none;border-top:2px solid #c8a961;margin:16px 0;">
<p><strong>Date:</strong> Saturday, February 7, 2026<br>
<strong>Time:</strong> 11:00 AM CT<br>
<strong>Location:</strong> Zoom (Virtual)<br>
<strong>Minutes Prepared By:</strong> Kailani, Secretary</p>
<h4 style="font-family:Playfair Display,serif;margin-top:20px;">Attendance</h4>
<p>Present: JoYi (ED and Board President), Alison (Board Chair), Gabby, Jay, Kobe<br>
Absent: Kailani (Excused Absence)</p>
<p>Quorum: Verified (5 of 6 members present)</p>
<h4 style="font-family:Playfair Display,serif;margin-top:20px;">Meeting Proceedings</h4>
<p>Minutes from the February 7 board meeting are pending upload of the full Zoom transcript and secretary notes. Board members are asked to review and approve once the complete minutes are available.</p>
<div style="margin-top:24px;padding-top:12px;border-top:2px solid #c8a961;font-size:0.75rem;color:#8a8494;text-align:center;">
Official minutes of The Practice Center Board of Directors.<br>
Retained permanently per Indiana Code IC 23-17. Subject to board approval.
</div>',
  ARRAY['JoYi', 'Alison', 'Gabby', 'Jay', 'Kobe'],
  true,
  'pending_approval',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3'
)
ON CONFLICT (id) DO NOTHING;

-- ======================================================
-- 4. BOARD SEATS
-- ======================================================
-- Seed board seats. profile_id is NULL for members who haven't created accounts yet.
-- Update these with actual UUIDs after each member signs up.

INSERT INTO board_seats (position, term_start, term_end, election_date, notes)
VALUES
  ('Board President', '2025-10-01', '2027-09-30', '2026-12-01', 'JoYi: Executive Director & Board President'),
  ('Board Chair', '2025-10-01', '2027-09-30', '2026-12-01', 'Alison: Board Chair'),
  ('Secretary', '2025-10-01', '2027-09-30', '2026-12-01', 'Kailani: Board Secretary'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Gabby: Director, AIdedEQ'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Jay: Board Member'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Kobe: Board Member')
ON CONFLICT DO NOTHING;
