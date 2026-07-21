<?php

namespace App\Providers;

use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\RfidCard;
use App\Models\RfidDevice;
use App\Models\School;
use App\Models\Student;
use Carbon\CarbonImmutable;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureDefaults();

        // API Resources are wrapped in the shared success envelope
        // (see App\Http\Responses\ApiResponse) instead of Laravel's
        // default "data" wrapping, to match docs/API-STANDARD.md.
        JsonResource::withoutWrapping();

        $this->configureRateLimiting();

        // Short, stable aliases for polymorphic resource_type/target_type
        // columns (sync_changes, audit_logs), so the documented API
        // contract never leaks an App\Models\* class name.
        Relation::morphMap([
            'school' => School::class,
            'student' => Student::class,
            'guardian' => Guardian::class,
            'guardian_student_link' => GuardianStudentLink::class,
            'rfid_device' => RfidDevice::class,
            'rfid_card' => RfidCard::class,
        ]);
    }

    /**
     * Configure named rate limiters for mobile API endpoints.
     */
    protected function configureRateLimiting(): void
    {
        RateLimiter::for('school-resolver', fn (Request $request): Limit => Limit::perMinute(10)->by($request->ip()));

        RateLimiter::for('mobile-login', function (Request $request): Limit {
            $throttleKey = Str::transliterate(Str::lower((string) $request->input('email'))).'|'.$request->ip();

            return Limit::perMinute(5)->by($throttleKey);
        });

        RateLimiter::for('sync', function (Request $request): Limit {
            return Limit::perMinute(30)->by($request->user()?->id ?: $request->ip());
        });
    }

    /**
     * Configure default behaviors for production-ready applications.
     */
    protected function configureDefaults(): void
    {
        Date::use(CarbonImmutable::class);

        DB::prohibitDestructiveCommands(
            app()->isProduction(),
        );

        Password::defaults(fn (): ?Password => app()->isProduction()
            ? Password::min(12)
                ->mixedCase()
                ->letters()
                ->numbers()
                ->symbols()
                ->uncompromised()
            : null,
        );
    }
}
