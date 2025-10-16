<?php

namespace Authdog\Exceptions;

/**
 * Base exception class for all Authdog SDK errors
 */
class AuthdogException extends \Exception
{
    public function __construct(string $message = "", int $code = 0, ?\Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }
}
