import type { Student } from './student';

export type Guardian = {
    id: number;
    uuid: string;
    user_id: number;
    name: string;
    email: string;
    mobile_number: string;
    status: 'active' | 'inactive';
    notify_attendance: boolean;
    notify_announcements: boolean;
    created_at: string;
    updated_at: string;
};

export type GuardianFilters = {
    q?: string | null;
    status?: string | null;
};

export type GuardianStudentLink = {
    id: number;
    uuid: string;
    student_id: number;
    guardian_id: number;
    relationship_type: 'mother' | 'father' | 'guardian' | 'other';
    is_primary_contact: boolean;
    status: 'active' | 'revoked';
    notifications_enabled: boolean;
    student: Student;
};

export type LinkableStudent = Pick<Student, 'id' | 'name' | 'lrn'>;
