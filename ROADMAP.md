# TPC Board App: Product Roadmap

## V1 (Current): Ground / Practice / Commit / Act Framework

The TPC governance framework integrated across all pages:

- Consent package for routine approvals (bundled one-click approve, pull-from-consent escape hatch)
- Ground items: pre-read context, live time is Q&A only
- Practice items: live working time, discussion, alignment
- Decision recording: statement, type (approve/decline/defer/direction_given), owner, rationale
- Action items with owner, due date, status, DB persistence
- Agenda grouped by framework type with color-coded tags
- Board pack (meeting-level document attachments)
- Framework-structured minutes generation
- Dashboard: action items panel, prep status, Google Calendar link
- Feb 7 minutes approval as first consent item

---

## V2: Async Prep, Pre-Voting, and Engagement

### Async Prep / Annotations
- Comments and questions pinned to agenda items or document sections
- "Questions to answer before meeting" queue per Ground item
- Threaded Q&A with notifications
- Comparable to Boardable's "prep to purpose" loop

### Pre-Voting (Zeck-style)
- Vote intent in advance on Decision items
- Shows chair where alignment already exists before live discussion
- Build after decisions/actions model is solid in V1

### Readiness and Engagement Signals (full version)
- "Seen" status for board pack per member per document
- "Who's prepped" dashboard view for the chair
- V1 has simple prep status counts; V2 adds per-member tracking

### Auto-Generated Meeting Pages
- Build section cards dynamically from agenda items + type + attachments
- Templates for each item_type (Ground card, Practice card, Decision card)
- Eliminates hand-crafted meeting.html per meeting

### Parking Lot
- "Off-agenda topics" capture during Practice sections
- Roll forward into next meeting's agenda as draft items

### Meeting Recap AI
- Decisions made, actions assigned, open questions
- Auto-generated summary email to all board members post-meeting
- OnBoard AI and Boardable AI market this as immediate value

### Agenda Templates
- Recurring templates: monthly board, committee, special session
- Pre-populated with standard consent items and default flow

### E-Signatures
- Sign documents within the app (conflict of interest forms, board agreements)
- Requires mature permissions and audit trails first

### Magic Link / Passwordless Auth
- Zeck-style "no username/password" flow
- Great for adoption with non-technical board members
- Build once auth/security posture is ready

### Full Calendar Integration
- Google Workspace API (not just URL links)
- Auto-create events, send invites, attach board pack link
- Reminders: 7 days, 1 day, 1 hour before meeting

---

## V3: Scale and Compliance

### Audit Trails and Compliance Reporting
- "Who accessed what and when" log
- Compliance dashboard for IC 23-17 requirements
- Export-ready audit reports for annual filings

### Advanced Role/Term Governance
- Committee management (finance, governance, program committees)
- Role registers with duty descriptions
- Election triggers: auto-notify when terms expire, nomination workflow
- Succession planning tools

### Deep Integrations and Dynamic Linking
- Cross-meeting decision references ("as decided in Feb 28 meeting...")
- Link action items to external project management (Mission2Practice)
- Zeck-style dynamic linking to surface key info across meetings

### Mobile Apps and Offline Mode
- Native iOS/Android app for meeting prep on the go
- Offline document viewing with sync when connected
- Push notifications for approvals and action item reminders

### Public Transparency Archive
- Public-facing page showing approved minutes (redacted as needed)
- Required by some state nonprofit transparency laws
- Board-approved content only

### Advanced AI
- Real-time transcription during meeting (beyond Zoom)
- AI-suggested action items from discussion notes
- Trend analysis across meetings (recurring topics, unresolved items)
- Board health scoring (attendance, prep rates, decision velocity)

---

## Competitive Notes

Researched: OnBoard, BoardPro, Boardable, Zeck, Agendalink

TPC differentiator: Ground/Practice/Commit/Act framework is not offered by any competitor. Most use generic Info/Discuss/Decide. Our framework reflects how TPC actually governs and is built for small, mission-driven nonprofit boards.

Key competitive features by version:

- V1 covers: agenda management, consent agenda, decision recording, action tracking, minutes generation, board pack, IC 23-17 compliance
- V2 closes gap with: async prep (Boardable), pre-voting (Zeck), engagement tracking (OnBoard), AI recap (OnBoard/Boardable)
- V3 positions for scale: audit trails, committee management, mobile, public transparency
