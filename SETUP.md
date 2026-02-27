# TPC Board Management Dashboard: Setup Guide

## Your Supabase Project

Your project is already created at:
https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo

Project URL: `https://fdzfiizwgvraamgkqggo.supabase.co`

---

## Step 1: Get Your Supabase Anon Key

1. Go to https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/settings/api
2. Under "Project API keys", copy the **anon / public** key
3. Open `js/config.js` in this folder
4. Replace `YOUR_SUPABASE_ANON_KEY` with your key

Your `config.js` should look like:
```javascript
const SUPABASE_URL = 'https://fdzfiizwgvraamgkqggo.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOi...your-actual-key-here';
```

---

## Step 2: Run Database Migrations

1. Go to https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/sql
2. Click "New query"
3. Open `supabase/migrations/001_schema.sql` from this folder
4. Copy the entire contents and paste into the SQL editor
5. Click "Run" (the play button)
6. Wait for "Success" message
7. Repeat for `supabase/migrations/002_seed.sql`

This creates all 10 tables, security policies, and seed data.

---

## Step 3: Configure Authentication

1. Go to https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/auth/providers
2. Under "Email", make sure it's enabled (it should be by default)
3. Go to URL Configuration: https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/auth/url-configuration
4. Set Site URL to your Netlify domain (after deploying), e.g.: `https://tpc-board.netlify.app`
5. Add Redirect URLs:
   - `https://tpc-board.netlify.app/dashboard.html`
   - `http://localhost:8080/dashboard.html` (for local testing)

---

## Step 4: Create Board Member Accounts

1. Go to https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/auth/users
2. Click "Add user" > "Create new user"
3. Create accounts for each board member:

| Name     | Email                          | Password    | Role      |
|----------|--------------------------------|-------------|-----------|
| JoYi     | JoYiRhyss@gmail.com           | (set one)   | admin     |
| Admin    | Admin@thepracticecenter.org    | (set one)   | admin     |
| Alison   | (her email)                    | (set one)   | chair     |
| Kailani  | (her email)                    | (set one)   | secretary |
| Gabby    | (her email)                    | (set one)   | member    |
| Jay      | (his email)                    | (set one)   | member    |
| Kobe     | (his email)                    | (set one)   | member    |

4. After creating users, their profiles are auto-created by the database trigger
5. To set roles: go to Table Editor > profiles > edit each row's `role` field

---

## Step 5: Create Storage Buckets

1. Go to https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/storage/buckets
2. Create 3 buckets:
   - **agenda-files** (Private) - for slide decks, PDFs, images
   - **zoom-transcripts** (Private) - for uploaded Zoom recordings/notes
   - **documents** (Private) - for bylaws and policies
3. For each bucket, go to Policies and add:
   - SELECT: Allow authenticated users
   - INSERT: Allow authenticated users

---

## Step 6: Deploy Edge Function (Optional - for AI Minutes)

This step enables AI-powered minutes generation using Claude.

1. Install Supabase CLI: `npm install -g supabase`
2. Link your project: `supabase link --project-ref fdzfiizwgvraamgkqggo`
3. Set your Anthropic API key:
   ```
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-your-key-here
   ```
4. Deploy the function:
   ```
   supabase functions deploy process-minutes --project-ref fdzfiizwgvraamgkqggo
   ```

Without this step, minutes generation works locally using the built-in template (no AI processing).

---

## Step 7: Deploy to Netlify

**Option A: Drag and Drop (fastest)**
1. Go to https://app.netlify.com/drop
2. Drag the entire `TPC-Board-App` folder onto the page
3. Wait for deploy (usually under 30 seconds)
4. Copy your site URL (e.g., `https://random-name.netlify.app`)
5. Go back to Step 3 and update your Site URL in Supabase auth settings

**Option B: GitHub + Netlify (recommended for ongoing updates)**
1. Push this folder to a GitHub repo
2. Go to https://app.netlify.com
3. Click "Add new site" > "Import an existing project"
4. Connect your GitHub repo
5. Deploy settings: publish directory = `.` (root)
6. Deploy

---

## Step 8: Update Site URL

After deploying:
1. Copy your Netlify URL
2. Go to Supabase Auth URL Configuration (Step 3 above)
3. Update the Site URL to your Netlify domain
4. Add it to Redirect URLs

---

## Testing Checklist

After completing all steps:

- [ ] Open your Netlify URL in a browser
- [ ] Login page appears with TPC logo
- [ ] Sign in with JoYi's credentials
- [ ] Dashboard loads with sidebar navigation
- [ ] Click "Add to Agenda" and submit a test item
- [ ] Navigate to "Live Meeting" and see the agenda
- [ ] Go to "Minutes" and paste some test notes
- [ ] Click "Generate Official Minutes"
- [ ] Download minutes as PDF
- [ ] Check "Governance" page shows board seats
- [ ] Test approval workflow on Minutes page

---

## Troubleshooting

**"Supabase not configured" message on login:**
- Check that `js/config.js` has your real Supabase URL and anon key

**Login fails with "Invalid login credentials":**
- Make sure you created the user in Supabase Auth (Step 4)
- Check the email matches exactly (case-sensitive)

**Tables not found errors:**
- Make sure you ran both SQL migration files (Step 2)

**File uploads fail:**
- Make sure you created the storage buckets (Step 5)
- Check that bucket policies allow authenticated users

**Edge function errors:**
- Check that ANTHROPIC_API_KEY is set: `supabase secrets list`
- Check function logs: `supabase functions logs process-minutes`

---

## Architecture

```
Browser (Netlify)  <-->  Supabase
  index.html              Auth (login)
  dashboard.html          PostgreSQL (data)
  agenda.html             Storage (files)
  meeting.html            Edge Functions (AI)
  minutes.html
  archive.html
  governance.html
  admin.html
```

All data stays in your Supabase project. The frontend is static HTML/JS with no build step.
Indiana nonprofit compliance (IC 23-17) is built into the minutes template and archive system.
