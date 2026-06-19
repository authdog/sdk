<?php

namespace Authdog\Types;

/**
 * Session information
 */
class Session
{
    public int $remainingSeconds;

    public function __construct(array $data)
    {
        $this->remainingSeconds = $data['remainingSeconds'] ?? 0;
    }
}
