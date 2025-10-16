<?php

namespace Authdog\Types;

/**
 * Metadata in the response
 */
class Meta
{
    public int $code;
    public string $message;

    public function __construct(array $data)
    {
        $this->code = $data['code'] ?? 0;
        $this->message = $data['message'] ?? '';
    }
}
