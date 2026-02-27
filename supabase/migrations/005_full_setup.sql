-- ======================================================
-- TPC Board App: COMPLETE SETUP (Run this ONE file)
-- ======================================================
-- Paste this entire script into Supabase SQL Editor and click Run.
-- It is safe to re-run (uses IF NOT EXISTS and ON CONFLICT).
-- ======================================================

-- =====================
-- 1. TABLES
-- =====================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('admin', 'chair', 'secretary', 'member')) DEFAULT 'member',
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  time TIME NOT NULL DEFAULT '14:00',
  location TEXT DEFAULT 'Zoom',
  zoom_link TEXT,
  status TEXT CHECK (status IN ('scheduled', 'in_progress', 'completed', 'archived')) DEFAULT 'scheduled',
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS agenda_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  presenter_id UUID REFERENCES profiles(id),
  time_needed_minutes INT DEFAULT 10,
  section_category TEXT DEFAULT 'Board Business',
  item_order INT DEFAULT 0,
  status TEXT CHECK (status IN ('draft', 'confirmed', 'published', 'completed')) DEFAULT 'draft',
  item_type TEXT CHECK (item_type IN ('consent', 'ground', 'practice', 'decision', 'act')) DEFAULT 'practice',
  decision_statement TEXT,
  decision_type TEXT CHECK (decision_type IN ('approve', 'decline', 'defer', 'direction_given')),
  decision_owner UUID REFERENCES profiles(id),
  decision_rationale TEXT,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS agenda_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agenda_item_id UUID REFERENCES agenda_items(id) ON DELETE CASCADE NOT NULL,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_type TEXT,
  file_size INT,
  uploaded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS meeting_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE NOT NULL,
  agenda_item_id UUID REFERENCES agenda_items(id) ON DELETE CASCADE NOT NULL,
  secretary_id UUID REFERENCES profiles(id),
  content TEXT DEFAULT '',
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(agenda_item_id)
);

CREATE TABLE IF NOT EXISTS meeting_minutes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE NOT NULL,
  content_html TEXT,
  attendees TEXT[],
  quorum_verified BOOLEAN DEFAULT false,
  motions JSONB DEFAULT '[]',
  action_items_json JSONB DEFAULT '[]',
  status TEXT CHECK (status IN ('draft', 'pending_approval', 'approved', 'ratified', 'archived')) DEFAULT 'draft',
  generated_by UUID REFERENCES profiles(id),
  zoom_transcript_path TEXT,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS minute_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  minute_id UUID REFERENCES meeting_minutes(id) ON DELETE CASCADE NOT NULL,
  approver_id UUID REFERENCES profiles(id) NOT NULL,
  approved BOOLEAN NOT NULL,
  comments TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(minute_id, approver_id)
);

CREATE TABLE IF NOT EXISTS action_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  minute_id UUID REFERENCES meeting_minutes(id) ON DELETE CASCADE,
  meeting_id UUID REFERENCES meetings(id),
  task_description TEXT NOT NULL,
  assigned_to UUID REFERENCES profiles(id),
  due_date DATE,
  status TEXT CHECK (status IN ('open', 'in_progress', 'completed')) DEFAULT 'open',
  exported_to_m2p BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS board_seats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  position TEXT NOT NULL,
  profile_id UUID REFERENCES profiles(id),
  term_start DATE NOT NULL,
  term_end DATE NOT NULL,
  election_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT CHECK (category IN ('bylaws', 'policy', 'template', 'training', 'signed_form', 'conflict_of_interest', 'board_agreement', 'board_pack', 'pre_read')) DEFAULT 'policy',
  content TEXT,
  file_path TEXT,
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
  version INT DEFAULT 1,
  uploaded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- 2. AUTO-CREATE PROFILE ON SIGNUP
-- =====================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    CASE
      WHEN LOWER(NEW.email) IN ('joyirhyss@gmail.com', 'gabriellaflowers6@gmail.com', 'kailani.rhyss@gmail.com', 'admin@thepracticecenter.org') THEN 'admin'
      ELSE 'member'
    END
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================
-- 3. ROW LEVEL SECURITY
-- =====================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE agenda_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE agenda_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_minutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE minute_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE action_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE board_seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running (safe to ignore errors)
DO $$ BEGIN
  -- Read policies
  DROP POLICY IF EXISTS "Members can read profiles" ON profiles;
  DROP POLICY IF EXISTS "Members can read meetings" ON meetings;
  DROP POLICY IF EXISTS "Members can read agenda items" ON agenda_items;
  DROP POLICY IF EXISTS "Members can read attachments" ON agenda_attachments;
  DROP POLICY IF EXISTS "Members can read notes" ON meeting_notes;
  DROP POLICY IF EXISTS "Members can read minutes" ON meeting_minutes;
  DROP POLICY IF EXISTS "Members can read approvals" ON minute_approvals;
  DROP POLICY IF EXISTS "Members can read action items" ON action_items;
  DROP POLICY IF EXISTS "Members can read board seats" ON board_seats;
  DROP POLICY IF EXISTS "Members can read documents" ON documents;
  -- Write policies
  DROP POLICY IF EXISTS "Members can create agenda items" ON agenda_items;
  DROP POLICY IF EXISTS "Members can create attachments" ON agenda_attachments;
  DROP POLICY IF EXISTS "Members can approve minutes" ON minute_approvals;
  DROP POLICY IF EXISTS "Members can update approvals" ON minute_approvals;
  DROP POLICY IF EXISTS "Admins can manage meetings" ON meetings;
  DROP POLICY IF EXISTS "Managers can update agenda" ON agenda_items;
  DROP POLICY IF EXISTS "Managers can delete agenda" ON agenda_items;
  DROP POLICY IF EXISTS "Secretary can manage notes" ON meeting_notes;
  DROP POLICY IF EXISTS "Secretary can manage minutes" ON meeting_minutes;
  DROP POLICY IF EXISTS "Secretary can manage action items" ON action_items;
  DROP POLICY IF EXISTS "Admin can manage profiles" ON profiles;
  DROP POLICY IF EXISTS "Admin can manage board seats" ON board_seats;
  DROP POLICY IF EXISTS "Admin can manage documents" ON documents;
END $$;

-- Read: all authenticated users can read everything
CREATE POLICY "Members can read profiles" ON profiles FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read meetings" ON meetings FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read agenda items" ON agenda_items FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read attachments" ON agenda_attachments FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read notes" ON meeting_notes FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read minutes" ON meeting_minutes FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read approvals" ON minute_approvals FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read action items" ON action_items FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read board seats" ON board_seats FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Members can read documents" ON documents FOR SELECT USING (auth.uid() IS NOT NULL);

-- Members can submit agenda items and attachments
CREATE POLICY "Members can create agenda items" ON agenda_items FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Members can create attachments" ON agenda_attachments FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Members can submit approvals (own only)
CREATE POLICY "Members can approve minutes" ON minute_approvals FOR INSERT WITH CHECK (auth.uid() = approver_id);
CREATE POLICY "Members can update approvals" ON minute_approvals FOR UPDATE USING (auth.uid() = approver_id);

-- Admin/Chair/Secretary can manage meetings and agenda
CREATE POLICY "Admins can manage meetings" ON meetings FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'chair', 'secretary'))
);
CREATE POLICY "Managers can update agenda" ON agenda_items FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'chair', 'secretary'))
);
CREATE POLICY "Managers can delete agenda" ON agenda_items FOR DELETE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'chair', 'secretary'))
);

-- Secretary/Admin can manage notes and minutes
CREATE POLICY "Secretary can manage notes" ON meeting_notes FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'secretary'))
);
CREATE POLICY "Secretary can manage minutes" ON meeting_minutes FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'secretary'))
);
CREATE POLICY "Secretary can manage action items" ON action_items FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'secretary'))
);

-- Admin can manage profiles, seats, documents
CREATE POLICY "Admin can manage profiles" ON profiles FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can manage board seats" ON board_seats FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can manage documents" ON documents FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'secretary'))
);

-- =====================
-- 4. INDEXES
-- =====================

CREATE INDEX IF NOT EXISTS idx_meetings_date ON meetings(date);
CREATE INDEX IF NOT EXISTS idx_meetings_status ON meetings(status);
CREATE INDEX IF NOT EXISTS idx_agenda_items_meeting ON agenda_items(meeting_id);
CREATE INDEX IF NOT EXISTS idx_agenda_items_order ON agenda_items(item_order);
CREATE INDEX IF NOT EXISTS idx_meeting_notes_item ON meeting_notes(agenda_item_id);
CREATE INDEX IF NOT EXISTS idx_minutes_meeting ON meeting_minutes(meeting_id);
CREATE INDEX IF NOT EXISTS idx_minute_approvals_minute ON minute_approvals(minute_id);
CREATE INDEX IF NOT EXISTS idx_action_items_status ON action_items(status);
CREATE INDEX IF NOT EXISTS idx_board_seats_end ON board_seats(term_end);

-- =====================
-- 5. SEED DATA
-- =====================

-- Feb 28, 2026: Upcoming Board Meeting
INSERT INTO meetings (id, date, time, location, zoom_link, status)
VALUES (
  'a1b2c3d4-0001-4000-8000-000000000001',
  '2026-02-28', '11:00', 'Zoom',
  'https://us02web.zoom.us/j/87830852593',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET time = '11:00', zoom_link = 'https://us02web.zoom.us/j/87830852593';

-- Feb 7, 2026: Completed Board Meeting
INSERT INTO meetings (id, date, time, location, status)
VALUES (
  'a1b2c3d4-0002-4000-8000-000000000002',
  '2026-02-07', '11:00', 'Zoom', 'completed'
)
ON CONFLICT (id) DO UPDATE SET status = 'completed', time = '11:00';

-- Board Seats (profile_id will be updated after users are created)
-- IDs auto-generated by gen_random_uuid()
INSERT INTO board_seats (position, term_start, term_end, election_date, notes)
VALUES
  ('Board President', '2025-10-01', '2027-09-30', '2026-12-01', 'JoYi: Executive Director & Board President'),
  ('Board Chair', '2025-10-01', '2027-09-30', '2026-12-01', 'Alison: Board Chair'),
  ('Secretary', '2025-10-01', '2027-09-30', '2026-12-01', 'Kailani: Board Secretary'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Gabby: Director, AIdedEQ'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Jay: Board Member'),
  ('Director', '2025-10-01', '2027-09-30', '2026-12-01', 'Kobe: Board Member')
ON CONFLICT DO NOTHING;

-- Agenda items for Feb 28 meeting
INSERT INTO agenda_items (meeting_id, title, description, time_needed_minutes, section_category, item_order, status, item_type)
VALUES
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Welcome + Call to Order', 'Alison calls meeting to order. Confirm quorum. Guided centering moment.', 5, 'Board Business', 1, 'confirmed', 'consent'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Approve February 7 Meeting Minutes', 'Board vote to approve the minutes from the February 7, 2026 board meeting.', 2, 'Board Business', 2, 'confirmed', 'consent'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'ED + Board President Updates', 'JoYi covers AIdedEQ as TPC technology arm, market gap, March 6-8 hackathon.', 15, 'Board Business', 3, 'confirmed', 'ground'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'AIdedEQ: Website Walkthrough', 'Live walkthrough of aidedeq.com. Mission, vision, who we serve.', 10, 'AIdedEQ Updates', 4, 'confirmed', 'practice'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'AIdedEQ Tools: Mission to Practice', 'Gabby presents Pocket Facilitator, tools in development, hackathon submission.', 10, 'AIdedEQ Updates', 5, 'confirmed', 'practice'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Marketing, Market Research + Our Edge', 'Market landscape, competitive differentiators, target audiences.', 10, 'Programs', 6, 'confirmed', 'practice'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Girls Who Vibe: Program Update', 'Spring break playbook, community engagement, partnership opportunities.', 10, 'Programs', 7, 'confirmed', 'practice'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Open Discussion + Small Group Time', 'Facilitated dialogue, small group breakout, report back.', 15, 'Open Discussion', 8, 'confirmed', 'practice'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Revenue + Funding', 'Current financial position, funding goals, AIdedEQ revenue model.', 10, 'Revenue & Funding', 9, 'confirmed', 'decision'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Internal Board Business', 'New business, AIdedEQ corporate motions, bylaw updates.', 10, 'Board Business', 10, 'confirmed', 'decision'),
  ('a1b2c3d4-0001-4000-8000-000000000001', 'Closing Circle', 'Recap decisions and action items. Confirm next meeting. Adjourn.', 5, 'Board Business', 11, 'confirmed', 'consent')
ON CONFLICT DO NOTHING;

-- Feb 7 meeting minutes (pending approval)
INSERT INTO meeting_minutes (id, meeting_id, content_html, attendees, quorum_verified, status)
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
<p>Minutes from the February 7 board meeting are pending upload of the full Zoom transcript and secretary notes.</p>
<div style="margin-top:24px;padding-top:12px;border-top:2px solid #c8a961;font-size:0.75rem;color:#8a8494;text-align:center;">
Official minutes of The Practice Center Board of Directors.<br>
Retained permanently per Indiana Code IC 23-17.
</div>',
  ARRAY['JoYi', 'Alison', 'Gabby', 'Jay', 'Kobe'],
  true,
  'pending_approval'
)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- 6. BACKFILL PROFILES FOR EXISTING USERS
-- =====================
-- If users were created before the trigger existed, create their profiles now.
INSERT INTO profiles (id, email, full_name, role)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)),
  CASE
    WHEN LOWER(u.email) IN ('joyirhyss@gmail.com', 'gabriellaflowers6@gmail.com', 'admin@thepracticecenter.org') THEN 'admin'
    ELSE 'member'
  END
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = u.id)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- DONE! Check for "Success" message above.
-- Next: Test login at your app URL.
-- =====================
