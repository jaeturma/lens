<?php

namespace App\Http\Requests\Sync;

use App\Support\Sync\SyncCursor;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use InvalidArgumentException;

class SyncChangesRequest extends FormRequest
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
            'cursor' => ['required', 'string', function (string $attribute, mixed $value, Closure $fail): void {
                try {
                    SyncCursor::fromString($value);
                } catch (InvalidArgumentException) {
                    $fail('The cursor is invalid.');
                }
            }],
            'limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ];
    }
}
