<?php

declare(strict_types=1);

/*
 * Trimmed from kreait/laravel-firebase's published default: only Cloud
 * Messaging (push signal delivery, WP-06-05) is used in this app — the
 * Firestore/Realtime Database/Storage/Auth-tenant sections that package
 * ships by default were removed rather than left as unused dead config
 * for components this app never touches.
 */
return [
    'default' => env('FIREBASE_PROJECT', 'app'),

    'projects' => [
        'app' => [

            /*
             * A Firebase service account JSON credentials file — never
             * committed. See docs/NOTIFICATIONS.md for how this is
             * provisioned in each environment.
             */
            'credentials' => env('FIREBASE_CREDENTIALS', env('GOOGLE_APPLICATION_CREDENTIALS')),

            'cache_store' => env('FIREBASE_CACHE_STORE', 'file'),

            'logging' => [
                'http_log_channel' => env('FIREBASE_HTTP_LOG_CHANNEL'),
                'http_debug_log_channel' => env('FIREBASE_HTTP_DEBUG_LOG_CHANNEL'),
            ],

            'http_client_options' => [
                'proxy' => env('FIREBASE_HTTP_CLIENT_PROXY'),
                'timeout' => env('FIREBASE_HTTP_CLIENT_TIMEOUT'),
            ],
        ],
    ],
];
