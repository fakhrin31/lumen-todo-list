<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Handle a login request to the application.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function login(Request $request)
    {
        $this->validate($request, [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->input('email'))->first();

        if (!$user) {
            return response()->json(['message' => 'Login failed'], 401);
        }

        if (Hash::check($request->input('password'), $user->password)) {
            $user->api_token = Str::random(60);
            $user->save();
            return response()->json(['api_token' => $user->api_token]);
        }

        return response()->json(['message' => 'Login failed'], 401);
    }
}