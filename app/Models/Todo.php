<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Todo extends Model
{
    protected $fillable = ['title', 'is_done', 'user_id'];

    protected $casts = [
        'is_done' => 'boolean', // otomatis cast ke boolean
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

}
