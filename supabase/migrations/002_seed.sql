-- ======================================================
-- TPC BOARD MANAGEMENT: SEED DATA
-- Run this AFTER 001_schema.sql and AFTER creating user accounts
-- ======================================================

-- NOTE: Board seats are seeded with placeholder profile_id values.
-- After creating user accounts, update profile_id to match actual UUIDs.
-- You can find user IDs in Supabase Dashboard > Authentication > Users

-- Seed the first meeting: February 28, 2026
INSERT INTO meetings (date, time, location, status)
VALUES ('2026-02-28', '14:00', 'Zoom', 'scheduled')
ON CONFLICT DO NOTHING;

-- Board seat definitions (update profile_id after users are created)
-- All officers: 2-year terms, starting October 2025
-- Elections: December 2026, new terms start January 2027

INSERT INTO board_seats (position, term_start, term_end, election_date, notes) VALUES
  ('Board President', '2025-10-01', '2027-09-30', '2026-12-01', 'JoYi: Executive Director & Board President. 2-year term.'),
  ('Board Chair', '2025-10-01', '2027-09-30', '2026-12-01', 'Alison: Board Chair. 2-year term.'),
  ('Secretary', '2025-10-01', '2027-09-30', '2026-12-01', 'Kailani: Board Secretary. 2-year term.'),
  ('Director (Seat 1)', '2025-10-01', '2027-09-30', '2026-12-01', 'Gabby: Board Member. 2-year term.'),
  ('Director (Seat 2)', '2025-10-01', '2027-09-30', '2026-12-01', 'Jay: Board Member. 2-year term.'),
  ('Director (Seat 3)', '2025-10-01', '2027-09-30', '2026-12-01', 'Kobe: Board Member. 2-year term.')
ON CONFLICT DO NOTHING;
