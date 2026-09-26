// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Directory user in an environment (distinct from user-info User)
    /// </summary>
    public class EnvUser
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("environmentId")]
        public string? EnvironmentId { get; set; }

        [JsonProperty("externalId")]
        public string? ExternalId { get; set; }

        [JsonProperty("userName")]
        public string? UserName { get; set; }

        [JsonProperty("displayName")]
        public string? DisplayName { get; set; }

        [JsonProperty("nickName")]
        public string? NickName { get; set; }

        [JsonProperty("profileUrl")]
        public string? ProfileUrl { get; set; }

        [JsonProperty("active")]
        public bool? Active { get; set; }

        [JsonProperty("changePw")]
        public bool? ChangePw { get; set; }

        [JsonProperty("provider")]
        public string? Provider { get; set; }

        [JsonProperty("emails")]
        public List<EnvUserEmail> Emails { get; set; } = new();

        [JsonProperty("lastLogin")]
        public string? LastLogin { get; set; }

        [JsonProperty("createdAt")]
        public string? CreatedAt { get; set; }

        [JsonProperty("updatedAt")]
        public string? UpdatedAt { get; set; }
    }
}
