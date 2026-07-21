<?php

use App\Support\Sync\SyncCursor;

test('the initial cursor has a zero sequence', function () {
    expect(SyncCursor::initial()->sequence())->toBe(0);
});

test('a cursor round-trips through its encoded string form', function () {
    $cursor = SyncCursor::fromSequence(42);

    $decoded = SyncCursor::fromString($cursor->encode());

    expect($decoded->sequence())->toBe(42);
    expect((string) $cursor)->toBe($cursor->encode());
});

test('the encoded cursor is opaque, not the raw sequence', function () {
    $cursor = SyncCursor::fromSequence(42);

    expect($cursor->encode())->not->toBe('42');
});

test('a negative sequence is rejected', function () {
    SyncCursor::fromSequence(-1);
})->throws(InvalidArgumentException::class);

test('malformed cursor strings are rejected', function (string $value) {
    SyncCursor::fromString($value);
})->throws(InvalidArgumentException::class)->with([
    'not base64 at all' => '%%%not-base64%%%',
    'valid base64 but not a number' => base64_encode('not-a-number'),
    'empty string' => '',
]);
