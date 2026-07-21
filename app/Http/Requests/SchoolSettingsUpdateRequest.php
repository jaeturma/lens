<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class SchoolSettingsUpdateRequest extends FormRequest
{
    /**
     * Authorization is enforced by the route (policy/middleware) once an
     * administrative endpoint consumes this request; not yet wired here
     * because Sanctum and roles/policies do not exist until WP-01-04/05.
     */
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
            'timezone' => ['required', 'timezone'],
            'mobile_enabled' => ['required', 'boolean'],
            'maintenance_mode' => ['required', 'boolean'],
            'maintenance_message' => ['nullable', 'string', 'max:255', 'required_if:maintenance_mode,true'],
            'notifications_enabled' => ['required', 'boolean'],
            'minimum_app_version' => ['required', 'string', 'regex:/^\d+\.\d+\.\d+$/'],
        ];
    }
}
