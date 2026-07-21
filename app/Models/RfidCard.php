<?php

namespace App\Models;

use App\Enums\RfidCardStatus;
use Database\Factories\RfidCardFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property string $uid
 * @property int $student_id
 * @property RfidCardStatus $status
 * @property string|null $active_uid
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read Student $student
 */
#[Fillable(['uid', 'student_id', 'status'])]
class RfidCard extends Model
{
    /** @use HasFactory<RfidCardFactory> */
    use HasFactory;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => RfidCardStatus::class,
        ];
    }

    /**
     * @return BelongsTo<Student, $this>
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
