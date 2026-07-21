<?php

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

test('unknown api route returns a consistent 404 error envelope', function () {
    $response = $this->getJson('/api/v1/does-not-exist');

    $response->assertNotFound()
        ->assertJson(['success' => false])
        ->assertJsonStructure(['success', 'message', 'errors']);
});

test('validation failures return a consistent 422 error envelope', function () {
    Route::post('/api/v1/_test/validate', function (Request $request) {
        $request->validate(['name' => 'required|string']);

        return response()->json(['success' => true]);
    });

    $response = $this->postJson('/api/v1/_test/validate', []);

    $response->assertStatus(422)
        ->assertJson(['success' => false])
        ->assertJsonStructure(['success', 'message', 'errors' => ['name']]);
});

test('authentication failures return a consistent 401 error envelope', function () {
    Route::get('/api/v1/_test/auth', function () {
        throw new AuthenticationException;
    });

    $response = $this->getJson('/api/v1/_test/auth');

    $response->assertStatus(401)->assertJson([
        'success' => false,
        'message' => 'Unauthenticated.',
    ]);
});

test('authorization failures return a consistent 403 error envelope', function () {
    Route::get('/api/v1/_test/forbidden', function () {
        throw new AuthorizationException('You cannot do that.');
    });

    $response = $this->getJson('/api/v1/_test/forbidden');

    $response->assertStatus(403)->assertJson([
        'success' => false,
        'message' => 'You cannot do that.',
    ]);
});

test('unhandled server errors are hidden behind a generic message', function () {
    config(['app.debug' => false]);

    Route::get('/api/v1/_test/boom', function () {
        throw new RuntimeException('leaked internal detail');
    });

    $response = $this->getJson('/api/v1/_test/boom');

    $response->assertStatus(500)->assertJson([
        'success' => false,
        'message' => 'Server error.',
    ]);

    expect($response->getContent())->not->toContain('leaked internal detail');
});
