<?php

namespace Authdog\Exceptions;

/**
 * Exception thrown when authentication fails
 */
class AuthenticationException extends AuthdogException
{
    public function __construct(string $message = "Authentication failed", int $code = 401, ?\Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }
}
