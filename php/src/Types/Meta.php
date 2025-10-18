<?php

namespace Authdog\Types;

/**
 * Metadata in the response
 */
class Meta
{
    public int $code;
    public string $message;
    public string $requestId;

    public function __construct(array $data)
    {
        $this->code = $data['code'] ?? 0;
        $this->message = $data['message'] ?? '';
        $this->requestId = $data['requestId'] ?? '';
    }

    public function get(string $key): mixed
    {
        return match($key) {
            'requestId' => $this->requestId,
            'code' => $this->code,
            'message' => $this->message,
            default => null
        };
    }
}
