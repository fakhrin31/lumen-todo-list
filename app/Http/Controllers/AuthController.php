<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function register(Request $request) {
        $this->validate($request, [
            'name' => 'required|string', 'email' => 'required|email|unique:users', 'password' => 'required|confirmed',
        ]);
        $user = new User(['name' => $request->name, 'email' => $request->email, 'password' => Hash::make($request->password)]);
        $user->save();
        return response()->json(['message' => 'User created successfully!'], 201);
    }

    public function login(Request $request) {
        $this->validate($request, ['email' => 'required|email', 'password' => 'required|string']);
        $credentials = $request->only(['email', 'password']);
        if (!$token = Auth::attempt($credentials)) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }
        return $this->respondWithToken($token);
    }

    public function me() { return response()->json(Auth::user()); }
    public function logout() { Auth::logout(); return response()->json(['message' => 'Successfully logged out']); }
    protected function respondWithToken($token) {
        return response()->json(['access_token' => $token, 'token_type' => 'bearer', 'expires_in' => Auth::factory()->getTTL() * 60]);
    }
}