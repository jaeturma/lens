import type { Student } from './student';

export type RfidDevice = {
    id: number;
    device_code: string;
    location: string;
    direction_mode: 'entry' | 'exit' | 'both';
    status: 'active' | 'revoked';
    last_activity_at: string | null;
    created_at: string;
    updated_at: string;
};

export type RfidDeviceFilters = {
    q?: string | null;
    status?: string | null;
};

export type RfidCard = {
    id: number;
    uid: string;
    student_id: number;
    status: 'active' | 'deactivated' | 'replaced';
    created_at: string;
    updated_at: string;
    student: Pick<Student, 'id' | 'name' | 'lrn'>;
};

export type RfidCardFilters = {
    q?: string | null;
    status?: string | null;
};

export type AssignableStudent = Pick<Student, 'id' | 'name' | 'lrn'>;

export type RfidScan = {
    id: number;
    rfid_device_id: number;
    uid: string;
    device_timestamp: string;
    request_id: string;
    classification:
        'valid' | 'duplicate_window' | 'unknown_card' | 'inactive_card';
    created_at: string;
    device: Pick<RfidDevice, 'id' | 'device_code' | 'location'>;
};

export type RfidScanFilters = {
    rfid_device_id?: number | string | null;
    classification?: string | null;
};
