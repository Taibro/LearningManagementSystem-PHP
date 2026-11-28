<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Class ClassMaterial
 * 
 * @property int $id
 * @property string $class_materials_id
 * @property int $school_id
 * @property int $class_id
 * @property string $title
 * @property string|null $description
 * @property int|null $file_upload_id
 * @property string|null $file_type
 * @property int|null $file_size
 * @property int $uploaded_by
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property ImageUpload|null $fileUpload
 * @property School $school
 * @property CourseClass $class
 * @property User $user
 *
 * @package App\Models
 */
class ClassMaterial extends Model
{
	protected $table = 'class_materials';

	protected $casts = [
		'class_materials_id' => 'string',
		'school_id' => 'int',
		'class_id' => 'int',
		'file_upload_id' => 'int',
		'file_size' => 'int',
		'uploaded_by' => 'int'
	];

	protected $fillable = [
		'class_materials_id',
		'school_id',
		'class_id',
		'title',
		'description',
		'file_upload_id',
		'file_type',
		'file_size',
		'uploaded_by'
	];

	/**
	 * @return BelongsTo<ImageUpload, $this>
	 */
	public function fileUpload(): BelongsTo
	{
		return $this->belongsTo(ImageUpload::class, 'file_upload_id');
	}

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function class()
	{
		return $this->belongsTo(CourseClass::class, 'class_id');
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'uploaded_by');
	}
}
