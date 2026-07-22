<?php

use App\Models\School;
use App\Models\SchoolSettings;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
|
| The closure you provide to your test functions is always bound to a specific PHPUnit test
| case class. By default, that class is "PHPUnit\Framework\TestCase". Of course, you may
| need to change it using the "pest()" function to bind different classes or traits.
|
*/

pest()->extend(TestCase::class)
    ->use(RefreshDatabase::class)
    ->beforeEach(function () {
        // QUEUE_CONNECTION=sync in phpunit.xml means a dispatched job runs
        // immediately, inline. Without this, App\Jobs\SendPushSignal
        // (WP-06-05) would attempt a real Firebase call as a side effect
        // of every test that creates a GuardianNotification — most of
        // which have nothing to do with push delivery. Faked globally
        // here since it's the only queued job in the app today; a test
        // that actually wants to exercise SendPushSignal calls its
        // handle() method directly instead of relying on the queue.
        Queue::fake();
    })
    ->in('Feature');

/*
|--------------------------------------------------------------------------
| Expectations
|--------------------------------------------------------------------------
|
| When you're writing tests, you often need to check that values meet certain conditions. The
| "expect()" function gives you access to a set of "expectations" methods that you can use
| to assert different things. Of course, you may extend the Expectation API at any time.
|
*/

expect()->extend('toBeOne', function () {
    return $this->toBe(1);
});

/*
|--------------------------------------------------------------------------
| Functions
|--------------------------------------------------------------------------
|
| While Pest is very powerful out-of-the-box, you may have some testing code specific to your
| project that you don't want to repeat in every file. Here you can also expose helpers as
| global functions to help you to reduce the number of lines of code in your test files.
|
*/

/**
 * @param  array<string, mixed>  $settingsOverrides
 */
function bindSchool(array $settingsOverrides = []): School
{
    $school = School::factory()->create(['public_id' => 'SCH-0001']);
    SchoolSettings::factory()->for($school)->create($settingsOverrides);

    return $school;
}
