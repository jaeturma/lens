<?php

namespace App\Http\Requests\RfidDevices;

use App\Enums\RfidDeviceDirectionMode;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class UpdateRfidDeviceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('update', $this->route('rfid_device'));
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'location' => ['required', 'string', 'max:255'],
            'direction_mode' => ['required', new Enum(RfidDeviceDirectionMode::class)],
        ];
    }
}
