<?php

use App\Actions\Audit\RecordAuditLog;
use App\Models\AuditLog;
use App\Models\School;
use App\Models\User;
use Illuminate\Support\Facades\Schema;

test('it records the actor, action, target, and metadata', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $target = School::factory()->create();

    $log = (new RecordAuditLog)($actor, 'school.updated', $target, ['name' => 'New Name']);

    expect($log)->toBeInstanceOf(AuditLog::class)
        ->and($log->actor_id)->toBe($actor->id)
        ->and($log->action)->toBe('school.updated')
        ->and($log->target_id)->toBe($target->id)
        ->and($log->target_type)->toBe($target->getMorphClass())
        ->and($log->metadata)->toBe(['name' => 'New Name'])
        ->and($log->created_at)->not->toBeNull();

    $this->assertDatabaseHas('audit_logs', [
        'id' => $log->id,
        'action' => 'school.updated',
    ]);
});

test('it allows a null actor and target for system-initiated entries', function () {
    $log = (new RecordAuditLog)(null, 'attendance.absence_calculated');

    expect($log->actor_id)->toBeNull()
        ->and($log->target_type)->toBeNull()
        ->and($log->target_id)->toBeNull();
});

test('it redacts secret-shaped metadata keys at any nesting depth', function () {
    $actor = User::factory()->create();

    $log = (new RecordAuditLog)($actor, 'user.password_reset', null, [
        'password' => 'super-secret',
        'nested' => ['token' => 'abc123', 'note' => 'kept'],
    ]);

    expect($log->metadata)->toBe([
        'password' => '[redacted]',
        'nested' => ['token' => '[redacted]', 'note' => 'kept'],
    ]);
});

test('audit log rows are append-only', function () {
    expect(AuditLog::UPDATED_AT)->toBeNull();
    expect(Schema::hasColumn('audit_logs', 'updated_at'))->toBeFalse();
});
