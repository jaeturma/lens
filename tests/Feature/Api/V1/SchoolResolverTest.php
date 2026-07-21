<?php

use App\Models\School;
use App\Models\SchoolSettings;

test('a valid school id resolves with profile and mobile status data', function () {
    $school = School::factory()->create([
        'public_id' => 'SCH-0001',
        'name' => 'Example School',
    ]);
    SchoolSettings::factory()->for($school)->create([
        'timezone' => 'Asia/Manila',
        'mobile_enabled' => true,
        'maintenance_mode' => false,
        'maintenance_message' => null,
        'notifications_enabled' => true,
        'minimum_app_version' => '0.1.0',
    ]);

    $response = $this->getJson('/api/v1/schools/resolve/SCH-0001');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'school_id' => 'SCH-0001',
            'uuid' => $school->uuid,
            'name' => 'Example School',
            'timezone' => 'Asia/Manila',
            'mobile_enabled' => true,
            'maintenance_mode' => false,
            'maintenance_message' => null,
            'notifications_enabled' => true,
            'minimum_app_version' => '0.1.0',
        ],
    ]);
});

test('an unknown school id is rejected safely', function () {
    $response = $this->getJson('/api/v1/schools/resolve/DOES-NOT-EXIST');

    $response->assertNotFound()->assertJson([
        'success' => false,
        'message' => 'School ID not found.',
    ]);
});

test('a school without settings is rejected safely', function () {
    School::factory()->create(['public_id' => 'SCH-0002']);

    $response = $this->getJson('/api/v1/schools/resolve/SCH-0002');

    $response->assertNotFound()->assertJson(['success' => false]);
});

test('a disabled or maintenance school still resolves with its status flags', function () {
    $school = School::factory()->create(['public_id' => 'SCH-0003']);
    SchoolSettings::factory()->for($school)->create([
        'mobile_enabled' => false,
        'maintenance_mode' => true,
        'maintenance_message' => 'Upgrading systems, back soon.',
    ]);

    $response = $this->getJson('/api/v1/schools/resolve/SCH-0003');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'mobile_enabled' => false,
            'maintenance_mode' => true,
            'maintenance_message' => 'Upgrading systems, back soon.',
        ],
    ]);
});

test('the resolver is rate limited per ip', function () {
    for ($i = 0; $i < 10; $i++) {
        $this->getJson('/api/v1/schools/resolve/DOES-NOT-EXIST')->assertNotFound();
    }

    $this->getJson('/api/v1/schools/resolve/DOES-NOT-EXIST')
        ->assertStatus(429);
});
