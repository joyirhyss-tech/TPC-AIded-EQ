-- ======================================================
-- TPC Board App: Add signed_form category to documents
-- ======================================================
-- Run this in Supabase SQL Editor after 002_seed_meetings.sql

-- Drop the old constraint and add expanded one
ALTER TABLE documents DROP CONSTRAINT IF EXISTS documents_category_check;
ALTER TABLE documents ADD CONSTRAINT documents_category_check
  CHECK (category IN ('bylaws', 'policy', 'template', 'training', 'signed_form', 'conflict_of_interest', 'board_agreement'));
