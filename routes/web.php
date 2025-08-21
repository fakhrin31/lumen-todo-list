<?php
/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/', function () { return 'Lumen API for To-Do List'; });

// Rute untuk Autentikasi (tidak perlu login)
$router->group(['prefix' => 'auth'], function () use ($router) {
    $router->post('register', 'AuthController@register');
    $router->post('login', 'AuthController@login');
    
    // Rute yang butuh login
    $router->group(['middleware' => 'auth:api'], function () use ($router) {
        $router->post('logout', 'AuthController@logout');
        $router->get('me', 'AuthController@me');
    });
});

// Rute untuk To-Do List (semua butuh login)
$router->group(['prefix' => 'api', 'middleware' => 'auth:api'], function () use ($router) {
    $router->get('todos', 'TodoController@index');
    $router->post('todos', 'TodoController@store');
    $router->get('todos/{id}', 'TodoController@show');
    $router->put('todos/{id}', 'TodoController@update');
    $router->delete('todos/{id}', 'TodoController@destroy');
});