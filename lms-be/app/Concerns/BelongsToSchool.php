<?php

namespace App\Concerns;

use App\Services\Database\PostgresContextService;
use Illuminate\Database\Eloquent\Model;

trait BelongsToSchool
{
    public static function bootBelongsToSchool(): void
    {
        static::creating(function (Model $model) {
            if (empty($model->getAttribute('school_id')) && PostgresContextService::getSchoolId()) {
                $model->setAttribute('school_id', PostgresContextService::getSchoolId());
            }
        });
    }
}

