<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TodoController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $todos = $user->todos()->get();

        return response()->json($todos, 200);
    }

    public function store(Request $request)
    {
        // gunakan Validator, bukan $request->validate()
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $todo = Auth::user()->todos()->create([
            'title' => $request->title
        ]);

        return response()->json($todo, 201);
    }

    public function show($id)
    {
        $todo = Auth::user()->todos()->where('id', $id)->firstOrFail();
        return response()->json($todo, 200);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'title'   => 'sometimes|string|max:255',
            'is_done' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $todo = Auth::user()->todos()->where('id', $id)->firstOrFail();

        $todo->update($request->only(['title', 'is_done']));

        return response()->json($todo, 200);
    }


    public function destroy($id)
    {
        $todo = Auth::user()->todos()->where('id', $id)->firstOrFail();
        $todo->delete();

        return response()->json(['message' => 'Deleted Successfully'], 200);
    }
}
