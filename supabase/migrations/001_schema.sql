-- ======================================================
-- TPC BOARD MANAGEMENT: DATABASE SCHEMA
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- ======================================================

-- 1. PROFILES (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('admin', 'chair', 'secretary', 'member')) DEFAULT 'member',
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile when user signs up
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
      WHEN NEW.email IN ('joyirhyss@gmail.com', 'admin@thepracticecenter.org') THEN 'admin'
      ELSE 'member'
    END
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 2. MEETINGS
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

-- 3. AGENDA ITEMS
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
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. AGENDA ATTACHMENTS
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

-- 5. MEETING NOTES (secretary's live notes per agenda item)
CREATE TABLE IF NOT EXISTS meeting_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE NOT NULL,
  agenda_item_id UUID REFERENCES agenda_items(id) ON DELETE CASCADE NOT NULL,
  secretary_id UUID REFERENCES profiles(id),
  content TEXT DEFAULT '',
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(agenda_item_id)
);

-- 6. MEETING MINUTES
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

-- 7. MINUTE APPROVALS
CREATE TABLE IF NOT EXISTS minute_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  minute_id UUID REFERENCES meeting_minutes(id) ON DELETE CASCADE NOT NULL,
  approver_id UUID REFERENCES profiles(id) NOT NULL,
  approved BOOLEAN NOT NULL,
  comments TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(minute_id, approver_id)
);

-- 8. ACTION ITEMS
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

-- 9. BOARD SEATS
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

-- 10. DOCUMENTS (bylaws, policies)
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT CHECK (category IN ('bylaws', 'policy', 'template', 'training')) DEFAULT 'policy',
  content TEXT,
  file_path TEXT,
  version INT DEFAULT 1,
  uploaded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ======================================================
-- ROW LEVEL SECURITY
-- ======================================================

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

-- All authenticated users can read all data
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

-- Members can submit approvals
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

-- ======================================================
-- INDEXES
-- ======================================================

CREATE INDEX idx_meetings_date ON meetings(date);
CREATE INDEX idx_meetings_status ON meetings(status);
CREATE INDEX idx_agenda_items_meeting ON agenda_items(meeting_id);
CREATE INDEX idx_agenda_items_order ON agenda_items(item_order);
CREATE INDEX idx_meeting_notes_item ON meeting_notes(agenda_item_id);
CREATE INDEX idx_minutes_meeting ON meeting_minutes(meeting_id);
CREATE INDEX idx_minute_approvals_minute ON minute_approvals(minute_id);
CREATE INDEX idx_action_items_status ON action_items(status);
CREATE INDEX idx_board_seats_end ON board_seats(term_end);
