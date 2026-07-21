<?php

namespace App\Http\Requests\Students;

use App\Enums\StudentSex;
use App\Models\Student;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class StoreStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->can('create', Student::class);
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'lrn' => ['required', 'string', 'size:12', Rule::unique('students', 'lrn')],
            'student_number' => ['required', 'string', 'max:50', Rule::unique('students', 'student_number')],
            'name' => ['required', 'string', 'max:255'],
            'sex' => ['required', new Enum(StudentSex::class)],
            'grade' => ['required', 'string', 'max:50'],
            'section' => ['required', 'string', 'max:50'],
            'school_year' => ['required', 'string', 'max:20'],
            'photo_url' => ['nullable', 'url', 'max:2048'],
        ];
    }
}
