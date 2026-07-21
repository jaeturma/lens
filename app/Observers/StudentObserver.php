<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\Student;

class StudentObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    public function created(Student $student): void
    {
        ($this->recordSyncChange)($student, SyncChangeAction::Created, $this->payload($student));
    }

    public function updated(Student $student): void
    {
        ($this->recordSyncChange)($student, SyncChangeAction::Updated, $this->payload($student));
    }

    public function deleted(Student $student): void
    {
        ($this->recordSyncChange)($student, SyncChangeAction::Deleted, $this->payload($student));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Student $student): array
    {
        return [
            'uuid' => $student->uuid,
            'lrn' => $student->lrn,
            'student_number' => $student->student_number,
            'name' => $student->name,
            'sex' => $student->sex->value,
            'grade' => $student->grade,
            'section' => $student->section,
            'school_year' => $student->school_year,
            'status' => $student->status->value,
            'photo_url' => $student->photo_url,
        ];
    }
}
