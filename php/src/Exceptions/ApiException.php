<?php

namespace Authdog\Exceptions;

/**
 * Exception thrown when API requests fail
 */
class ApiException extends AuthdogException
{
    public function __construct(string $message = "API request failed", int $code = 0, ?\Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }
}
