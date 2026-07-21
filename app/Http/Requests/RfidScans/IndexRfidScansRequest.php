<?php

namespace App\Http\Requests\RfidScans;

use App\Enums\RfidScanClassification;
use App\Models\RfidScan;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class IndexRfidScansRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('viewAny', RfidScan::class);
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'rfid_device_id' => ['nullable', 'integer', Rule::exists('rfid_devices', 'id')],
            'classification' => ['nullable', new Enum(RfidScanClassification::class)],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function filters(): array
    {
        return $this->safe()->only(['rfid_device_id', 'classification']);
    }
}
