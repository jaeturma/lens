export type Student = {
    id: number;
    uuid: string;
    lrn: string;
    student_number: string;
    name: string;
    sex: 'male' | 'female';
    grade: string;
    section: string;
    school_year: string;
    status: 'active' | 'inactive';
    photo_url: string | null;
    created_at: string;
    updated_at: string;
};

export type StudentFilters = {
    q?: string | null;
    grade?: string | null;
    section?: string | null;
    school_year?: string | null;
    status?: string | null;
};

export type PaginationLink = {
    url: string | null;
    label: string;
    active: boolean;
};

export type Paginated<T> = {
    data: T[];
    links: PaginationLink[];
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    from: number | null;
    to: number | null;
};
