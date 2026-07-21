<?php

use App\Http\Requests\SchoolSettingsUpdateRequest;
use Illuminate\Support\Facades\Validator;

function schoolSettingsRules(): array
{
    return (new SchoolSettingsUpdateRequest)->rules();
}

test('valid settings pass validation', function () {
    $validator = Validator::make([
        'timezone' => 'Asia/Manila',
        'mobile_enabled' => true,
        'maintenance_mode' => false,
        'maintenance_message' => null,
        'notifications_enabled' => true,
        'minimum_app_version' => '0.1.0',
    ], schoolSettingsRules());

    expect($validator->passes())->toBeTrue();
});

test('an invalid timezone fails validation', function () {
    $validator = Validator::make([
        'timezone' => 'Not/A_Timezone',
        'mobile_enabled' => true,
        'maintenance_mode' => false,
        'notifications_enabled' => true,
        'minimum_app_version' => '0.1.0',
    ], schoolSettingsRules());

    expect($validator->fails())->toBeTrue()
        ->and($validator->errors()->has('timezone'))->toBeTrue();
});

test('a non-semver minimum_app_version fails validation', function () {
    $validator = Validator::make([
        'timezone' => 'Asia/Manila',
        'mobile_enabled' => true,
        'maintenance_mode' => false,
        'notifications_enabled' => true,
        'minimum_app_version' => 'v1',
    ], schoolSettingsRules());

    expect($validator->fails())->toBeTrue()
        ->and($validator->errors()->has('minimum_app_version'))->toBeTrue();
});

test('maintenance_mode true requires a maintenance_message', function () {
    $validator = Validator::make([
        'timezone' => 'Asia/Manila',
        'mobile_enabled' => true,
        'maintenance_mode' => true,
        'notifications_enabled' => true,
        'minimum_app_version' => '0.1.0',
    ], schoolSettingsRules());

    expect($validator->fails())->toBeTrue()
        ->and($validator->errors()->has('maintenance_message'))->toBeTrue();
});
