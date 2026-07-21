<?php

namespace App\Models;

use App\Enums\GuardianStudentLinkStatus;
use App\Enums\StudentSex;
use App\Enums\StudentStatus;
use App\Observers\StudentObserver;
use Database\Factories\StudentFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use LogicException;

/**
 * @property int $id
 * @property string $uuid
 * @property string $lrn
 * @property string $student_number
 * @property string $name
 * @property StudentSex $sex
 * @property string $grade
 * @property string $section
 * @property string $school_year
 * @property StudentStatus $status
 * @property string|null $photo_url
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
#[Fillable(['lrn', 'student_number', 'name', 'sex', 'grade', 'section', 'school_year', 'status', 'photo_url'])]
#[ObservedBy(StudentObserver::class)]
class Student extends Model
{
    /** @use HasFactory<StudentFactory> */
    use HasFactory;

    protected static function booted(): void
    {
        static::creating(function (Student $student): void {
            $student->uuid ??= (string) Str::uuid();
        });

        static::updating(function (Student $student): void {
            if ($student->isDirty('uuid')) {
                throw new LogicException('Student uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sex' => StudentSex::class,
            'status' => StudentStatus::class,
        ];
    }

    /**
     * @return HasMany<GuardianStudentLink, $this>
     */
    public function links(): HasMany
    {
        return $this->hasMany(GuardianStudentLink::class);
    }

    /**
     * @return HasMany<GuardianStudentLink, $this>
     */
    public function activeLinks(): HasMany
    {
        return $this->links()->where('status', GuardianStudentLinkStatus::Active);
    }
}
