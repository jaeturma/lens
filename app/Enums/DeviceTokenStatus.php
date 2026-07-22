<?php

namespace App\Enums;

enum DeviceTokenStatus: string
{
    case Active = 'active';

    /** Guardian/client-initiated (WP-06-04) — e.g. on logout. */
    case Revoked = 'revoked';

    /** System-initiated, on a push delivery failure (WP-06-06). Not set by this package. */
    case Deactivated = 'deactivated';
}
