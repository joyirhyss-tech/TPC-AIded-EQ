# TPC Board App: Deploy Today Guide

Follow these steps IN ORDER. The whole process takes about 15 minutes.

---

## STEP 1: Run the Database Setup (2 minutes)

1. Open this link in your browser:
   https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/sql/new

2. Open the file `supabase/migrations/005_full_setup.sql` from this folder

3. Copy the ENTIRE contents of that file

4. Paste it into the Supabase SQL Editor

5. Click the green **Run** button (or Cmd+Enter)

6. Wait for "Success. No rows returned" message

If you see errors about "already exists", that is OK. The script is designed to be re-run safely.

---

## STEP 2: Create Board Member Accounts (5 minutes)

1. Go to: https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/auth/users

2. Click **Add user** > **Create new user** for each person:

| Name     | Email                        | Password        | Auto Confirm |
|----------|------------------------------|-----------------|--------------|
| JoYi     | JoYiRhyss@gmail.com         | (pick one)      | YES          |
| Alison   | (her email)                  | (pick one)      | YES          |
| Kailani  | (her email)                  | (pick one)      | YES          |
| Gabby    | (her email)                  | (pick one)      | YES          |
| Jay      | (his email)                  | (pick one)      | YES          |
| Kobe     | (his email)                  | (pick one)      | YES          |

IMPORTANT: Check the "Auto Confirm User" checkbox for each one.

3. Write down each person's password. They will need it to log in.

The database trigger automatically creates their profile when the account is created.

---

## STEP 3: Set Board Member Roles (3 minutes)

After creating all accounts, set their roles:

1. Go to: https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/editor

2. Click on the **profiles** table

3. Find each person's row and edit the **role** field:

| Name     | Set role to   |
|----------|---------------|
| JoYi     | admin         |
| Alison   | chair         |
| Kailani  | secretary     |
| Gabby    | member        |
| Jay      | member        |
| Kobe     | member        |

4. Click the checkmark to save each row after editing

---

## STEP 4: Link Board Seats to Profiles (2 minutes)

1. Stay in the Table Editor
2. Go to the **profiles** table and copy each person's **id** (UUID)
3. Go to the **board_seats** table
4. For each seat row, paste the matching profile UUID into the **profile_id** column:
   - Board President -> JoYi's UUID
   - Board Chair -> Alison's UUID
   - Secretary -> Kailani's UUID
   - Director (Gabby) -> Gabby's UUID
   - Director (Jay) -> Jay's UUID
   - Director (Kobe) -> Kobe's UUID

This step is optional for launch but makes the Governance page show proper names.

---

## STEP 5: Create Storage Buckets (2 minutes)

1. Go to: https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/storage/buckets

2. Click **New bucket** and create these three:

| Bucket Name       | Public? |
|-------------------|---------|
| agenda-files      | No      |
| zoom-transcripts  | No      |
| documents         | No      |

3. For EACH bucket, click on it, then go to **Policies** tab, then click **New Policy** > **For full customization**:

   - Policy name: `Allow authenticated access`
   - Allowed operation: **ALL** (SELECT, INSERT, UPDATE, DELETE)
   - Target roles: **authenticated**
   - USING expression: `true`
   - WITH CHECK expression: `true`
   - Click **Review** then **Save**

---

## STEP 6: Configure Auth Redirect URLs (1 minute)

1. Go to: https://supabase.com/dashboard/project/fdzfiizwgvraamgkqggo/auth/url-configuration

2. Set **Site URL** to your Netlify domain, e.g.:
   `https://tpc-board-meeting-dashboard.netlify.app`

3. Under **Redirect URLs**, add:
   - `https://tpc-board-meeting-dashboard.netlify.app/dashboard.html`
   - `http://localhost:8080/dashboard.html` (for local testing)

---

## STEP 7: Deploy to Netlify (2 minutes)

**Option A: Drag and Drop**
1. Go to https://app.netlify.com/drop
2. Drag the entire `TPC-Board-App` folder onto the page
3. Wait for deploy to complete
4. Copy the URL and update Step 6 Site URL if it differs

**Option B: Push to GitHub, then auto-deploy**
1. Push this repo to GitHub
2. Connect the GitHub repo to Netlify
3. Deploy settings: publish directory = `.` (root)

---

## STEP 8: Test Login

1. Open your Netlify URL
2. Sign in with JoYi's email and password
3. You should see the Dashboard with the Feb 28 meeting, agenda items, and action items
4. Check: Agenda page, Meeting page, Governance page

---

## Quick Troubleshooting

**Login fails with "Invalid login credentials":**
- Check the email matches exactly (case-sensitive)
- Make sure "Auto Confirm User" was checked when creating the account

**"No upcoming meetings" on dashboard:**
- The SQL migration may not have run. Go back to Step 1.

**File uploads fail:**
- Storage buckets may not be created. Go back to Step 5.

**Magic link not working:**
- Check redirect URLs in Step 6
- The user's email must match an existing account
