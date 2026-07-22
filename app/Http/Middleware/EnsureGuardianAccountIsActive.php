<?php

namespace App\Http\Middleware;

use App\Enums\GuardianStatus;
use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Login already rejects an inactive guardian's *credentials*
 * (`LoginController`), but a token issued before deactivation kept working
 * against every other endpoint indefinitely (`docs/api/SYNC.md`'s own
 * `guardian` section had documented this as the current, unresolved
 * behavior since WP-02-02). This closes that gap by re-checking status on
 * every request, not just at login — deactivating a guardian now takes
 * effect on their very next request, on any device, without needing to
 * separately revoke their token(s).
 *
 * Responds `401`, not `403`: `docs/api/AUTHENTICATION.md`'s `/auth/me`
 * contract, and `SessionController.build()` on the Flutter side
 * (WP-07-07), already treat a `401` specifically as "this session is no
 * longer valid, return to login" versus any other failure (fails open —
 * offline-first). A deactivated account's token is exactly that case, not
 * a merely-forbidden action by an otherwise-valid session.
 *
 * A guardian-role account with no `Guardian` profile yet is unaffected
 * (login does not require one either — see WP-02-02) and every
 * non-guardian role passes through untouched.
 */
class EnsureGuardianAccountIsActive
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user->isGuardian() && $user->guardian?->status === GuardianStatus::Inactive) {
            return ApiResponse::error('This account is inactive. Please contact the school.', [], 401);
        }

        return $next($request);
    }
}
