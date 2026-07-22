<?php

namespace App\Http\Requests\Announcements;

use App\Enums\AnnouncementAudienceType;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class UpdateAnnouncementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('update', $this->route('announcement'));
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string', 'max:10000'],
            'expires_at' => ['nullable', 'date', 'after:now'],
            'audience_type' => ['required', new Enum(AnnouncementAudienceType::class)],
            'audience_grade' => ['nullable', 'required_if:audience_type,grade', 'required_if:audience_type,section', 'string', 'max:50'],
            'audience_section' => ['nullable', 'required_if:audience_type,section', 'string', 'max:50'],
            'student_ids' => ['nullable', 'required_if:audience_type,students', 'array'],
            'student_ids.*' => ['integer', Rule::exists('students', 'id')],
        ];
    }
}
