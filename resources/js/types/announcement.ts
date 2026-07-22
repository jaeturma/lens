import type { Student } from './student';

export type Announcement = {
    id: number;
    uuid: string;
    title: string;
    body: string;
    author_id: number | null;
    status: 'draft' | 'published' | 'expired' | 'withdrawn';
    audience_type: 'all' | 'grade' | 'section' | 'students';
    audience_grade: string | null;
    audience_section: string | null;
    published_at: string | null;
    expires_at: string | null;
    created_at: string;
    updated_at: string;
    students?: Pick<Student, 'id' | 'name' | 'lrn'>[];
};

export type AnnouncementFilters = {
    q?: string | null;
    status?: string | null;
};
