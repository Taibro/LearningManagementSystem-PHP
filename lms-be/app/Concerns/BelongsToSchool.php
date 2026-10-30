<?php

namespace App\Concerns;

use App\Services\Database\PostgresContextService;
use Illuminate\Database\Eloquent\Model;

trait BelongsToSchool
{
    public static function bootBelongsToSchool(): void
    {
        static::creating(function (Model $model) {
            if (empty($model->school_id) && PostgresContextService::getSchoolId()) {
                $model->school_id = PostgresContextService::getSchoolId();
            }
        });
    }
}

