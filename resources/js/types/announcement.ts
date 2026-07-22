export type Announcement = {
    id: number;
    uuid: string;
    title: string;
    body: string;
    author_id: number | null;
    status: 'draft' | 'published' | 'expired' | 'withdrawn';
    published_at: string | null;
    expires_at: string | null;
    created_at: string;
    updated_at: string;
};

export type AnnouncementFilters = {
    q?: string | null;
    status?: string | null;
};
