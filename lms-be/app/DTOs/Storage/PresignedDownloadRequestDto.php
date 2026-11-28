<?php

namespace App\DTOs\Storage;

use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

final class PresignedDownloadRequestDto
{
    public const DISPOSITION_INLINE = 'inline';

    public const DISPOSITION_ATTACHMENT = 'attachment';

    public function __construct(
        public readonly string $disposition = self::DISPOSITION_INLINE,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'disposition' => ['nullable', 'string', Rule::in([self::DISPOSITION_INLINE, self::DISPOSITION_ATTACHMENT])],
        ]);

        return new self(
            disposition: isset($validated['disposition'])
                ? strtolower((string) $validated['disposition'])
                : self::DISPOSITION_INLINE,
        );
    }
}
