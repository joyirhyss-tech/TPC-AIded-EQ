-- ======================================================
-- TPC Board App: V1 Framework Upgrade
-- Ground / Practice / Commit / Act
-- ======================================================
-- Run this in Supabase SQL Editor after 002_seed_meetings.sql

-- 1. Add TPC Framework columns to agenda_items
ALTER TABLE agenda_items
ADD COLUMN IF NOT EXISTS item_type TEXT CHECK (item_type IN ('consent', 'ground', 'practice', 'decision', 'act')) DEFAULT 'practice';

ALTER TABLE agenda_items
ADD COLUMN IF NOT EXISTS decision_statement TEXT;

ALTER TABLE agenda_items
ADD COLUMN IF NOT EXISTS decision_type TEXT CHECK (decision_type IN ('approve', 'decline', 'defer', 'direction_given'));

ALTER TABLE agenda_items
ADD COLUMN IF NOT EXISTS decision_owner UUID REFERENCES profiles(id);

ALTER TABLE agenda_items
ADD COLUMN IF NOT EXISTS decision_rationale TEXT;

-- 2. Add meeting_id to documents for board pack per meeting
ALTER TABLE documents
ADD COLUMN IF NOT EXISTS meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE;

-- 3. Expand document categories (replaces 003 migration)
ALTER TABLE documents DROP CONSTRAINT IF EXISTS documents_category_check;
ALTER TABLE documents ADD CONSTRAINT documents_category_check
  CHECK (category IN ('bylaws', 'policy', 'template', 'training', 'signed_form', 'conflict_of_interest', 'board_agreement', 'board_pack', 'pre_read'));

-- 4. Set item_type on existing Feb 28 agenda items
-- Welcome + Call to Order
UPDATE agenda_items SET item_type = 'consent'
WHERE title = 'Welcome + Call to Order'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- ED + Board President Updates
UPDATE agenda_items SET item_type = 'ground'
WHERE title = 'ED + Board President Updates'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- AIdedEQ: Website Walkthrough
UPDATE agenda_items SET item_type = 'practice'
WHERE title = 'AIdedEQ: Website Walkthrough'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- AIdedEQ Tools: Mission to Practice
UPDATE agenda_items SET item_type = 'practice'
WHERE title = 'AIdedEQ Tools: Mission to Practice'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Marketing, Market Research + Our Edge
UPDATE agenda_items SET item_type = 'practice'
WHERE title = 'Marketing, Market Research + Our Edge'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Girls Who Vibe: Program Update
UPDATE agenda_items SET item_type = 'practice'
WHERE title = 'Girls Who Vibe: Program Update'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Open Discussion + Small Group Time
UPDATE agenda_items SET item_type = 'practice'
WHERE title = 'Open Discussion + Small Group Time'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Revenue + Funding
UPDATE agenda_items SET item_type = 'decision'
WHERE title = 'Revenue + Funding'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Internal Board Business
UPDATE agenda_items SET item_type = 'decision'
WHERE title = 'Internal Board Business'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- Closing Circle
UPDATE agenda_items SET item_type = 'consent'
WHERE title = 'Closing Circle'
AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';

-- 5. Insert new consent item: Approve Feb 7 Meeting Minutes
INSERT INTO agenda_items (
  id, meeting_id, title, description, time_needed_minutes,
  section_category, item_order, status, item_type, created_by, created_at
) VALUES (
  'a1b2c3d4-0011-4000-8000-000000000011',
  'a1b2c3d4-0001-4000-8000-000000000001',
  'Approve February 7 Meeting Minutes',
  'Board vote to approve the minutes from the February 7, 2026 board meeting. Minutes have been circulated for review.',
  2,
  'Board Business',
  2,
  'confirmed',
  'consent',
  '90d84ab7-fe9d-4d97-be7e-555f81feadf3',
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- 6. Reorder items to follow the default TPC framework flow:
-- Consent items first, then Ground, Practice, Decision, Act
UPDATE agenda_items SET item_order = 1 WHERE title = 'Welcome + Call to Order' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 2 WHERE title = 'Approve February 7 Meeting Minutes' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 3 WHERE title = 'ED + Board President Updates' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 4 WHERE title = 'AIdedEQ: Website Walkthrough' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 5 WHERE title = 'AIdedEQ Tools: Mission to Practice' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 6 WHERE title = 'Marketing, Market Research + Our Edge' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 7 WHERE title = 'Girls Who Vibe: Program Update' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 8 WHERE title = 'Open Discussion + Small Group Time' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 9 WHERE title = 'Revenue + Funding' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 10 WHERE title = 'Internal Board Business' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
UPDATE agenda_items SET item_order = 11 WHERE title = 'Closing Circle' AND meeting_id = 'a1b2c3d4-0001-4000-8000-000000000001';
