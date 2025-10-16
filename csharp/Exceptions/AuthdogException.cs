using System;

namespace Authdog.Exceptions
{
    /// <summary>
    /// Base exception class for all Authdog SDK errors
    /// </summary>
    public class AuthdogException : Exception
    {
        public AuthdogException(string message) : base(message)
        {
        }

        public AuthdogException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
