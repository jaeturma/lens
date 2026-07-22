<?php

namespace App\Models;

use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Observers\AnnouncementObserver;
use Database\Factories\AnnouncementFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use LogicException;

/**
 * @property int $id
 * @property string $uuid
 * @property string $title
 * @property string $body
 * @property int|null $author_id
 * @property AnnouncementStatus $status
 * @property AnnouncementAudienceType $audience_type
 * @property string|null $audience_grade
 * @property string|null $audience_section
 * @property Carbon|null $published_at
 * @property Carbon|null $expires_at
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read User|null $author
 * @property-read Collection<int, Student> $students
 */
#[Fillable(['title', 'body', 'author_id', 'status', 'published_at', 'expires_at', 'audience_type', 'audience_grade', 'audience_section'])]
#[ObservedBy(AnnouncementObserver::class)]
class Announcement extends Model
{
    /** @use HasFactory<AnnouncementFactory> */
    use HasFactory;

    protected static function booted(): void
    {
        static::creating(function (Announcement $announcement): void {
            $announcement->uuid ??= (string) Str::uuid();
            $announcement->status ??= AnnouncementStatus::Draft;
            $announcement->audience_type ??= AnnouncementAudienceType::All;
        });

        static::updating(function (Announcement $announcement): void {
            if ($announcement->isDirty('uuid')) {
                throw new LogicException('Announcement uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => AnnouncementStatus::class,
            'audience_type' => AnnouncementAudienceType::class,
            'published_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Only meaningful when audience_type is Students — the explicitly
     * selected recipients. Empty for every other audience type.
     *
     * @return BelongsToMany<Student, $this>
     */
    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class);
    }
}
