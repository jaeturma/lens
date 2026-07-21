<?php

namespace App\Http\Requests\RfidDevices;

use App\Enums\RfidDeviceDirectionMode;
use App\Models\RfidDevice;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class StoreRfidDeviceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('create', RfidDevice::class);
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'device_code' => ['required', 'string', 'max:50', Rule::unique('rfid_devices', 'device_code')],
            'location' => ['required', 'string', 'max:255'],
            'direction_mode' => ['required', new Enum(RfidDeviceDirectionMode::class)],
        ];
    }
}
