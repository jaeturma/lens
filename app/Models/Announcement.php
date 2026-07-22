<?php

namespace App\Models;

use App\Enums\AnnouncementStatus;
use App\Observers\AnnouncementObserver;
use Database\Factories\AnnouncementFactory;
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
 * @property string $title
 * @property string $body
 * @property int|null $author_id
 * @property AnnouncementStatus $status
 * @property Carbon|null $published_at
 * @property Carbon|null $expires_at
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read User|null $author
 */
#[Fillable(['title', 'body', 'author_id', 'status', 'published_at', 'expires_at'])]
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
}
