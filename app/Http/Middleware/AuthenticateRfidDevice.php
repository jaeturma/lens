<?php

namespace App\Http\Middleware;

use App\Actions\RfidDevices\VerifyRfidDeviceCredentials;
use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuthenticateRfidDevice
{
    public function __construct(private readonly VerifyRfidDeviceCredentials $verifyRfidDeviceCredentials) {}

    public function handle(Request $request, Closure $next): Response
    {
        $deviceCode = $request->getUser();
        $secret = $request->getPassword();

        $device = ($deviceCode && $secret)
            ? ($this->verifyRfidDeviceCredentials)($deviceCode, $secret)
            : null;

        if (! $device) {
            return ApiResponse::error('Invalid device credentials.', [], 401);
        }

        $request->attributes->set('rfidDevice', $device);

        return $next($request);
    }
}
