// ======================================================
// TPC Board App: Database Operations
// ======================================================

const DB = {
  // ---- MEETINGS ----
  async getMeetings(status) {
    let query = supabase.from('meetings').select('*').order('date', { ascending: false });
    if (status) query = query.eq('status', status);
    const { data, error } = await query;
    return { data: data || [], error };
  },

  async getUpcomingMeeting() {
    const today = new Date().toISOString().split('T')[0];
    const { data, error } = await supabase
      .from('meetings')
      .select('*')
      .gte('date', today)
      .order('date', { ascending: true })
      .limit(1)
      .single();
    return { data, error };
  },

  async getMeeting(id) {
    const { data, error } = await supabase.from('meetings').select('*').eq('id', id).single();
    return { data, error };
  },

  async createMeeting(meeting) {
    const { data, error } = await supabase.from('meetings').insert(meeting).select().single();
    return { data, error };
  },

  async updateMeeting(id, updates) {
    const { data, error } = await supabase.from('meetings').update(updates).eq('id', id).select().single();
    return { data, error };
  },

  async deleteMeeting(id) {
    // Delete agenda items first (cascade may handle this, but be explicit)
    await supabase.from('agenda_items').delete().eq('meeting_id', id);
    const { error } = await supabase.from('meetings').delete().eq('id', id);
    return { error };
  },

  // ---- AGENDA ITEMS ----
  async getAgendaItems(meetingId) {
    const { data, error } = await supabase
      .from('agenda_items')
      .select('*, presenter:profiles!agenda_items_presenter_id_fkey(full_name), submitter:profiles!agenda_items_created_by_fkey(full_name)')
      .eq('meeting_id', meetingId)
      .order('item_order', { ascending: true });
    return { data: data || [], error };
  },

  async createAgendaItem(item) {
    const { data, error } = await supabase.from('agenda_items').insert(item).select().single();
    return { data, error };
  },

  async updateAgendaItem(id, updates) {
    const { data, error } = await supabase.from('agenda_items').update(updates).eq('id', id).select().single();
    return { data, error };
  },

  async deleteAgendaItem(id) {
    const { error } = await supabase.from('agenda_items').delete().eq('id', id);
    return { error };
  },

  async reorderAgendaItems(items) {
    // items = [{id, item_order}, ...]
    const promises = items.map(i =>
      supabase.from('agenda_items').update({ item_order: i.item_order }).eq('id', i.id)
    );
    const results = await Promise.all(promises);
    return { error: results.find(r => r.error)?.error || null };
  },

  // ---- AGENDA ATTACHMENTS ----
  async getAttachments(agendaItemId) {
    const { data, error } = await supabase
      .from('agenda_attachments')
      .select('*')
      .eq('agenda_item_id', agendaItemId)
      .order('created_at', { ascending: true });
    return { data: data || [], error };
  },

  async createAttachment(attachment) {
    const { data, error } = await supabase.from('agenda_attachments').insert(attachment).select().single();
    return { data, error };
  },

  // ---- MEETING NOTES ----
  async getNotes(meetingId) {
    const { data, error } = await supabase
      .from('meeting_notes')
      .select('*')
      .eq('meeting_id', meetingId)
      .order('created_at', { ascending: true });
    return { data: data || [], error };
  },

  async getNote(agendaItemId) {
    const { data, error } = await supabase
      .from('meeting_notes')
      .select('*')
      .eq('agenda_item_id', agendaItemId)
      .maybeSingle();
    return { data, error };
  },

  async upsertNote(note) {
    const { data, error } = await supabase
      .from('meeting_notes')
      .upsert(note, { onConflict: 'agenda_item_id' })
      .select()
      .single();
    return { data, error };
  },

  // ---- MEETING MINUTES ----
  async getMinutes(meetingId) {
    const { data, error } = await supabase
      .from('meeting_minutes')
      .select('*')
      .eq('meeting_id', meetingId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();
    return { data, error };
  },

  async createMinutes(minutes) {
    const { data, error } = await supabase.from('meeting_minutes').insert(minutes).select().single();
    return { data, error };
  },

  async updateMinutes(id, updates) {
    const { data, error } = await supabase.from('meeting_minutes').update(updates).eq('id', id).select().single();
    return { data, error };
  },

  // ---- MINUTE APPROVALS ----
  async getApprovals(minutesId) {
    const { data, error } = await supabase
      .from('minute_approvals')
      .select('*, approver:profiles(full_name)')
      .eq('minute_id', minutesId);
    return { data: data || [], error };
  },

  async submitApproval(minutesId, approverId, approved, comments) {
    const { data, error } = await supabase
      .from('minute_approvals')
      .upsert({
        minute_id: minutesId,
        approver_id: approverId,
        approved,
        comments,
        created_at: new Date().toISOString()
      }, { onConflict: 'minute_id,approver_id' })
      .select()
      .single();
    return { data, error };
  },

  // ---- ACTION ITEMS ----
  async getActionItems(minutesId) {
    const { data, error } = await supabase
      .from('action_items')
      .select('*, assignee:profiles(full_name)')
      .eq('minute_id', minutesId)
      .order('created_at', { ascending: true });
    return { data: data || [], error };
  },

  async getAllOpenActionItems() {
    const { data, error } = await supabase
      .from('action_items')
      .select('*, assignee:profiles(full_name), minutes:meeting_minutes(meeting_id)')
      .eq('status', 'open')
      .order('due_date', { ascending: true });
    return { data: data || [], error };
  },

  async createActionItem(item) {
    const { data, error } = await supabase.from('action_items').insert(item).select().single();
    return { data, error };
  },

  async getActionItemsByMeeting(meetingId) {
    const { data, error } = await supabase
      .from('action_items')
      .select('*, assignee:profiles(full_name, email)')
      .eq('meeting_id', meetingId)
      .order('due_date', { ascending: true });
    return { data: data || [], error };
  },

  async updateActionItem(id, updates) {
    const { data, error } = await supabase.from('action_items').update(updates).eq('id', id).select().single();
    return { data, error };
  },

  // ---- DOCUMENTS (Meeting-level) ----
  async getDocumentsByMeeting(meetingId) {
    const { data, error } = await supabase
      .from('documents')
      .select('*')
      .eq('meeting_id', meetingId)
      .order('created_at', { ascending: false });
    return { data: data || [], error };
  },

  // ---- BOARD SEATS ----
  async getBoardSeats() {
    const { data, error } = await supabase
      .from('board_seats')
      .select('*, holder:profiles(full_name, email)')
      .order('term_end', { ascending: true });
    return { data: data || [], error };
  },

  async updateBoardSeat(id, updates) {
    const { data, error } = await supabase.from('board_seats').update(updates).eq('id', id).select().single();
    return { data, error };
  },

  async createBoardSeat(seat) {
    const { data, error } = await supabase.from('board_seats').insert(seat).select().single();
    return { data, error };
  },

  async getExpiringSeats(withinDays = 90) {
    const futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + withinDays);
    const { data, error } = await supabase
      .from('board_seats')
      .select('*, holder:profiles(full_name)')
      .lte('term_end', futureDate.toISOString().split('T')[0])
      .gte('term_end', new Date().toISOString().split('T')[0]);
    return { data: data || [], error };
  },

  // ---- DOCUMENTS ----
  async getDocuments(category) {
    let query = supabase.from('documents').select('*').order('created_at', { ascending: false });
    if (category) query = query.eq('category', category);
    const { data, error } = await query;
    return { data: data || [], error };
  },

  async createDocument(doc) {
    const { data, error } = await supabase.from('documents').insert(doc).select().single();
    return { data, error };
  },

  // ---- PROFILES ----
  async getProfiles() {
    const { data, error } = await supabase.from('profiles').select('*').order('full_name');
    return { data: data || [], error };
  },

  async updateProfile(id, updates) {
    const { data, error } = await supabase.from('profiles').update(updates).eq('id', id).select().single();
    return { data, error };
  }
};
