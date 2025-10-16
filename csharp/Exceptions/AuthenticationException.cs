using System;

namespace Authdog.Exceptions
{
    /// <summary>
    /// Exception thrown when authentication fails
    /// </summary>
    public class AuthenticationException : AuthdogException
    {
        public AuthenticationException(string message = "Authentication failed") : base(message)
        {
        }

        public AuthenticationException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
