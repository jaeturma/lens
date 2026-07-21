<?php

test('versioned health endpoint returns the success envelope', function () {
    $response = $this->getJson('/api/v1/health');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'status' => 'ok',
        ],
    ]);
});
