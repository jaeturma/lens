<?php

namespace App\Models;

use App\Enums\GuardianRelationshipType;
use App\Enums\GuardianStudentLinkStatus;
use App\Observers\GuardianStudentLinkObserver;
use Database\Factories\GuardianStudentLinkFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use LogicException;

/**
 * @property int $id
 * @property string $uuid
 * @property int $student_id
 * @property int $guardian_id
 * @property GuardianRelationshipType $relationship_type
 * @property bool $is_primary_contact
 * @property GuardianStudentLinkStatus $status
 * @property bool $notifications_enabled
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read Student $student
 * @property-read Guardian $guardian
 */
#[Fillable(['student_id', 'guardian_id', 'relationship_type', 'is_primary_contact', 'status', 'notifications_enabled'])]
#[ObservedBy(GuardianStudentLinkObserver::class)]
class GuardianStudentLink extends Model
{
    /** @use HasFactory<GuardianStudentLinkFactory> */
    use HasFactory;

    protected $table = 'guardian_student';

    protected static function booted(): void
    {
        static::creating(function (GuardianStudentLink $link): void {
            $link->uuid ??= (string) Str::uuid();
        });

        static::updating(function (GuardianStudentLink $link): void {
            if ($link->isDirty('uuid')) {
                throw new LogicException('GuardianStudentLink uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'relationship_type' => GuardianRelationshipType::class,
            'is_primary_contact' => 'boolean',
            'status' => GuardianStudentLinkStatus::class,
            'notifications_enabled' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<Student, $this>
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * @return BelongsTo<Guardian, $this>
     */
    public function guardian(): BelongsTo
    {
        return $this->belongsTo(Guardian::class);
    }
}
