<?php

namespace App\Providers;

use Carbon\CarbonImmutable;
use Illuminate\Cache\RateLimiting\Limit;
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
    }

    /**
     * Configure named rate limiters for unauthenticated public API endpoints.
     */
    protected function configureRateLimiting(): void
    {
        RateLimiter::for('school-resolver', fn (Request $request): Limit => Limit::perMinute(10)->by($request->ip()));

        RateLimiter::for('mobile-login', function (Request $request): Limit {
            $throttleKey = Str::transliterate(Str::lower((string) $request->input('email'))).'|'.$request->ip();

            return Limit::perMinute(5)->by($throttleKey);
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
