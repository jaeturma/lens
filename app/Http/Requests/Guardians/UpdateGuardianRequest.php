<?php

namespace App\Http\Requests\Guardians;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateGuardianRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('update', $this->route('guardian'));
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255'],
            'mobile_number' => ['required', 'string', 'max:20'],
            'notify_attendance' => ['sometimes', 'boolean'],
            'notify_announcements' => ['sometimes', 'boolean'],
        ];
    }
}
