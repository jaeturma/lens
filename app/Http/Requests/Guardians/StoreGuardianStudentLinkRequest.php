<?php

namespace App\Http\Requests\Guardians;

use App\Enums\GuardianRelationshipType;
use App\Models\Guardian;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class StoreGuardianStudentLinkRequest extends FormRequest
{
    public function authorize(): bool
    {
        /** @var Guardian $guardian */
        $guardian = $this->route('guardian');

        return (bool) $this->user()?->can('update', $guardian);
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'student_id' => ['required', 'integer', Rule::exists('students', 'id')],
            'relationship_type' => ['required', new Enum(GuardianRelationshipType::class)],
            'is_primary_contact' => ['sometimes', 'boolean'],
            'notifications_enabled' => ['sometimes', 'boolean'],
        ];
    }
}
