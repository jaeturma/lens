<?php

namespace App\Http\Requests\Rfid;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreRfidScanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'uid' => ['required', 'string', 'max:64'],
            'device_timestamp' => ['required', 'date'],
            'request_id' => ['required', 'string', 'max:100'],
        ];
    }
}
