<?php

namespace App\Models;

use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use Database\Factories\RfidDeviceFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property string $device_code
 * @property string $location
 * @property RfidDeviceDirectionMode $direction_mode
 * @property string $secret
 * @property RfidDeviceStatus $status
 * @property Carbon|null $last_activity_at
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
#[Fillable(['device_code', 'location', 'direction_mode', 'secret', 'status'])]
#[Hidden(['secret'])]
class RfidDevice extends Model
{
    /** @use HasFactory<RfidDeviceFactory> */
    use HasFactory;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'direction_mode' => RfidDeviceDirectionMode::class,
            'secret' => 'hashed',
            'status' => RfidDeviceStatus::class,
            'last_activity_at' => 'datetime',
        ];
    }
}
