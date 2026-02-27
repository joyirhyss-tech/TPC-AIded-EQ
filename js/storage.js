// ======================================================
// TPC Board App: File Storage Module
// ======================================================

const Storage = {
  buckets: {
    agendaFiles: 'agenda-files',
    zoomTranscripts: 'zoom-transcripts',
    documents: 'documents'
  },

  // Upload a file to a bucket
  async upload(bucket, filePath, file) {
    if (!isSupabaseConfigured()) {
      console.warn('Storage: demo mode, file not uploaded');
      return { data: { path: filePath }, error: null };
    }
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false
      });
    return { data, error };
  },

  // Get public URL for a file
  getPublicUrl(bucket, filePath) {
    if (!isSupabaseConfigured()) return '#';
    const { data } = supabase.storage.from(bucket).getPublicUrl(filePath);
    return data.publicUrl;
  },

  // Get signed URL for private file
  async getSignedUrl(bucket, filePath, expiresIn = 3600) {
    if (!isSupabaseConfigured()) return { url: '#', error: null };
    const { data, error } = await supabase.storage
      .from(bucket)
      .createSignedUrl(filePath, expiresIn);
    return { url: data?.signedUrl, error };
  },

  // Delete a file
  async remove(bucket, filePaths) {
    if (!isSupabaseConfigured()) return { error: null };
    const { error } = await supabase.storage.from(bucket).remove(filePaths);
    return { error };
  },

  // Upload agenda attachment
  async uploadAgendaFile(meetingId, agendaItemId, file) {
    const ext = file.name.split('.').pop();
    const path = `${meetingId}/${agendaItemId}/${Date.now()}.${ext}`;
    return await this.upload(this.buckets.agendaFiles, path, file);
  },

  // Upload Zoom transcript
  async uploadTranscript(meetingId, file) {
    const ext = file.name.split('.').pop();
    const path = `${meetingId}/transcript-${Date.now()}.${ext}`;
    return await this.upload(this.buckets.zoomTranscripts, path, file);
  },

  // Upload document (bylaws, etc.)
  async uploadDocument(category, file) {
    const ext = file.name.split('.').pop();
    const path = `${category}/${Date.now()}-${file.name}`;
    return await this.upload(this.buckets.documents, path, file);
  },

  // Get file type icon
  getFileIcon(filename) {
    const ext = filename.split('.').pop().toLowerCase();
    const icons = {
      pdf: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M9 15v-2h2a1 1 0 110 2H9z"/></svg>',
      pptx: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>',
      png: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>',
      jpg: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>'
    };
    return icons[ext] || icons.pdf;
  }
};
