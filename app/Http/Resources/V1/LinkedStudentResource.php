<?php

namespace App\Http\Resources\V1;

use App\Models\GuardianStudentLink;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin GuardianStudentLink
 */
class LinkedStudentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->student->uuid,
            'lrn' => $this->student->lrn,
            'student_number' => $this->student->student_number,
            'name' => $this->student->name,
            'sex' => $this->student->sex->value,
            'grade' => $this->student->grade,
            'section' => $this->student->section,
            'school_year' => $this->student->school_year,
            'status' => $this->student->status->value,
            'photo_url' => $this->student->photo_url,
            'relationship_type' => $this->relationship_type->value,
            'is_primary_contact' => $this->is_primary_contact,
        ];
    }
}
