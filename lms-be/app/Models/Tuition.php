<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Tuition extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'semester_id',
        'total_credits',
        'total_amount',
        'paid_amount',
        'status',
        'payment_date',
    ];

    protected $casts = [
        'total_credits' => 'integer',
        'total_amount' => 'decimal:2',
        'paid_amount' => 'decimal:2',
        'payment_date' => 'datetime',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }
}
