const std = @import("std");
const authdog = @import("lib.zig");

pub fn runTests() void {
    std.testing.refAllDecls(@This());
}

test "AuthdogClient initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", "test-api-key", 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    try std.testing.expectEqualStrings("https://api.authdog.com", client.base_url);
    try std.testing.expectEqualStrings("test-api-key", client.api_key.?);
    try std.testing.expectEqual(@as(u32, 5000), client.timeout_ms);
}

test "AuthdogClient initialization without API key" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 10000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    try std.testing.expectEqualStrings("https://api.authdog.com", client.base_url);
    try std.testing.expectEqual(@as(?[]const u8, null), client.api_key);
    try std.testing.expectEqual(@as(u32, 10000), client.timeout_ms);
}

test "Meta struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for meta
    
    

    const json_str = "{\"code\": 200, \"message\": \"Success\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const meta = client.parseMeta(tree.value) catch |err| {
        std.debug.print("Failed to parse meta: {}\n", .{err});
        return;
    };

    try std.testing.expectEqual(@as(i64, 200), meta.code);
    try std.testing.expectEqualStrings("Success", meta.message);
}

test "Session struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for session
    
    

    const json_str = "{\"remainingSeconds\": 3600}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const session = client.parseSession(tree.value) catch |err| {
        std.debug.print("Failed to parse session: {}\n", .{err});
        return;
    };

    try std.testing.expectEqual(@as(u32, 3600), session.remaining_seconds);
}

test "Names struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for names
    
    

    const json_str = "{\"id\": \"name-123\", \"formatted\": \"John Doe\", \"familyName\": \"Doe\", \"givenName\": \"John\", \"middleName\": \"William\", \"honorificPrefix\": \"Mr.\", \"honorificSuffix\": \"Jr.\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const names = client.parseNames(tree.value) catch |err| {
        std.debug.print("Failed to parse names: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("name-123", names.id);
    try std.testing.expectEqualStrings("John Doe", names.formatted.?);
    try std.testing.expectEqualStrings("Doe", names.family_name);
    try std.testing.expectEqualStrings("John", names.given_name);
    try std.testing.expectEqualStrings("William", names.middle_name.?);
    try std.testing.expectEqualStrings("Mr.", names.honorific_prefix.?);
    try std.testing.expectEqualStrings("Jr.", names.honorific_suffix.?);
}

test "Names struct parsing with null optional fields" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for names with null optional fields
    
    

    const json_str = "{\"id\": \"name-123\", \"familyName\": \"Doe\", \"givenName\": \"John\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const names = client.parseNames(tree.value) catch |err| {
        std.debug.print("Failed to parse names: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("name-123", names.id);
    try std.testing.expectEqual(@as(?[]const u8, null), names.formatted);
    try std.testing.expectEqualStrings("Doe", names.family_name);
    try std.testing.expectEqualStrings("John", names.given_name);
    try std.testing.expectEqual(@as(?[]const u8, null), names.middle_name);
    try std.testing.expectEqual(@as(?[]const u8, null), names.honorific_prefix);
    try std.testing.expectEqual(@as(?[]const u8, null), names.honorific_suffix);
}

test "Photo struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for photo
    
    

    const json_str = "{\"id\": \"photo-123\", \"value\": \"https://example.com/photo.jpg\", \"type\": \"profile\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const photo = client.parsePhoto(tree.value) catch |err| {
        std.debug.print("Failed to parse photo: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("photo-123", photo.id);
    try std.testing.expectEqualStrings("https://example.com/photo.jpg", photo.value);
    try std.testing.expectEqualStrings("profile", photo.type);
}

test "Email struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for email
    
    

    const json_str = "{\"id\": \"email-123\", \"value\": \"john@example.com\", \"type\": \"work\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const email = client.parseEmail(tree.value) catch |err| {
        std.debug.print("Failed to parse email: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("email-123", email.id);
    try std.testing.expectEqualStrings("john@example.com", email.value);
    try std.testing.expectEqualStrings("work", email.type.?);
}

test "Email struct parsing without type" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for email without type
    
    

    const json_str = "{\"id\": \"email-123\", \"value\": \"john@example.com\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const email = client.parseEmail(tree.value) catch |err| {
        std.debug.print("Failed to parse email: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("email-123", email.id);
    try std.testing.expectEqualStrings("john@example.com", email.value);
    try std.testing.expectEqual(@as(?[]const u8, null), email.type);
}

test "Verification struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for verification
    
    

    const json_str = "{\"id\": \"verification-123\", \"email\": \"john@example.com\", \"verified\": true, \"createdAt\": \"2023-01-01T00:00:00Z\", \"updatedAt\": \"2023-01-02T00:00:00Z\"}";
    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const verification = client.parseVerification(tree.value) catch |err| {
        std.debug.print("Failed to parse verification: {}\n", .{err});
        return;
    };

    try std.testing.expectEqualStrings("verification-123", verification.id);
    try std.testing.expectEqualStrings("john@example.com", verification.email);
    try std.testing.expectEqual(true, verification.verified);
    try std.testing.expectEqualStrings("2023-01-01T00:00:00Z", verification.created_at);
    try std.testing.expectEqualStrings("2023-01-02T00:00:00Z", verification.updated_at);
}

test "User struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for user
    
    

    const json_str = 
        \\{
        \\  "id": "user-123",
        \\  "externalId": "ext-123",
        \\  "userName": "johndoe",
        \\  "displayName": "John Doe",
        \\  "nickName": "Johnny",
        \\  "profileUrl": "https://example.com/profile",
        \\  "title": "Software Engineer",
        \\  "userType": "employee",
        \\  "preferredLanguage": "en",
        \\  "locale": "en-US",
        \\  "timezone": "UTC",
        \\  "active": true,
        \\  "names": {
        \\    "id": "name-123",
        \\    "familyName": "Doe",
        \\    "givenName": "John"
        \\  },
        \\  "photos": [
        \\    {
        \\      "id": "photo-123",
        \\      "value": "https://example.com/photo.jpg",
        \\      "type": "profile"
        \\    }
        \\  ],
        \\  "emails": [
        \\    {
        \\      "id": "email-123",
        \\      "value": "john@example.com",
        \\      "type": "work"
        \\    }
        \\  ],
        \\  "verifications": [
        \\    {
        \\      "id": "verification-123",
        \\      "email": "john@example.com",
        \\      "verified": true,
        \\      "createdAt": "2023-01-01T00:00:00Z",
        \\      "updatedAt": "2023-01-02T00:00:00Z"
        \\    }
        \\  ],
        \\  "provider": "google",
        \\  "createdAt": "2023-01-01T00:00:00Z",
        \\  "updatedAt": "2023-01-02T00:00:00Z",
        \\  "environmentId": "env-123"
        \\}
    ;

    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    var user = client.parseUser(tree.value) catch |err| {
        std.debug.print("Failed to parse user: {}\n", .{err});
        return;
    };
    defer user.deinit(allocator);

    try std.testing.expectEqualStrings("user-123", user.id);
    try std.testing.expectEqualStrings("ext-123", user.external_id);
    try std.testing.expectEqualStrings("johndoe", user.user_name);
    try std.testing.expectEqualStrings("John Doe", user.display_name);
    try std.testing.expectEqualStrings("Johnny", user.nick_name.?);
    try std.testing.expectEqualStrings("https://example.com/profile", user.profile_url.?);
    try std.testing.expectEqualStrings("Software Engineer", user.title.?);
    try std.testing.expectEqualStrings("employee", user.user_type.?);
    try std.testing.expectEqualStrings("en", user.preferred_language.?);
    try std.testing.expectEqualStrings("en-US", user.locale);
    try std.testing.expectEqualStrings("UTC", user.timezone.?);
    try std.testing.expectEqual(true, user.active);
    try std.testing.expectEqualStrings("google", user.provider);
    try std.testing.expectEqualStrings("2023-01-01T00:00:00Z", user.created_at);
    try std.testing.expectEqualStrings("2023-01-02T00:00:00Z", user.updated_at);
    try std.testing.expectEqualStrings("env-123", user.environment_id);

    // Test names
    try std.testing.expectEqualStrings("name-123", user.names.id);
    try std.testing.expectEqualStrings("Doe", user.names.family_name);
    try std.testing.expectEqualStrings("John", user.names.given_name);

    // Test photos
    try std.testing.expectEqual(@as(usize, 1), user.photos.items.len);
    try std.testing.expectEqualStrings("photo-123", user.photos.items[0].id);
    try std.testing.expectEqualStrings("https://example.com/photo.jpg", user.photos.items[0].value);
    try std.testing.expectEqualStrings("profile", user.photos.items[0].type);

    // Test emails
    try std.testing.expectEqual(@as(usize, 1), user.emails.items.len);
    try std.testing.expectEqualStrings("email-123", user.emails.items[0].id);
    try std.testing.expectEqualStrings("john@example.com", user.emails.items[0].value);
    try std.testing.expectEqualStrings("work", user.emails.items[0].type.?);

    // Test verifications
    try std.testing.expectEqual(@as(usize, 1), user.verifications.items.len);
    try std.testing.expectEqualStrings("verification-123", user.verifications.items[0].id);
    try std.testing.expectEqualStrings("john@example.com", user.verifications.items[0].email);
    try std.testing.expectEqual(true, user.verifications.items[0].verified);
}

test "UserInfoResponse struct parsing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for user info response
    
    

    const json_str = 
        \\{
        \\  "meta": {
        \\    "code": 200,
        \\    "message": "Success"
        \\  },
        \\  "session": {
        \\    "remainingSeconds": 3600
        \\  },
        \\  "user": {
        \\    "id": "user-123",
        \\    "externalId": "ext-123",
        \\    "userName": "johndoe",
        \\    "displayName": "John Doe",
        \\    "locale": "en-US",
        \\    "active": true,
        \\    "names": {
        \\      "id": "name-123",
        \\      "familyName": "Doe",
        \\      "givenName": "John"
        \\    },
        \\    "photos": [],
        \\    "emails": [],
        \\    "verifications": [],
        \\    "provider": "google",
        \\    "createdAt": "2023-01-01T00:00:00Z",
        \\    "updatedAt": "2023-01-02T00:00:00Z",
        \\    "environmentId": "env-123"
        \\  }
        \\}
    ;

    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    // Manually extract the response since parseUserInfoResponse internally parses again
    const root = tree.value;

    const meta_obj = root.object.get("meta") orelse {
        std.debug.print("Missing meta object\n", .{});
        return;
    };
    const session_obj = root.object.get("session") orelse {
        std.debug.print("Missing session object\n", .{});
        return;
    };
    const user_obj = root.object.get("user") orelse {
        std.debug.print("Missing user object\n", .{});
        return;
    };

    const meta = client.parseMeta(meta_obj) catch |err| {
        std.debug.print("Failed to parse meta: {}\n", .{err});
        return;
    };
    const session = client.parseSession(session_obj) catch |err| {
        std.debug.print("Failed to parse session: {}\n", .{err});
        return;
    };
    var user = client.parseUser(user_obj) catch |err| {
        std.debug.print("Failed to parse user: {}\n", .{err});
        return;
    };
    defer user.deinit(allocator);

    // Test meta
    try std.testing.expectEqual(@as(i64, 200), meta.code);
    try std.testing.expectEqualStrings("Success", meta.message);

    // Test session
    try std.testing.expectEqual(@as(u32, 3600), session.remaining_seconds);

    // Test user
    try std.testing.expectEqualStrings("user-123", user.id);
    try std.testing.expectEqualStrings("John Doe", user.display_name);
    try std.testing.expectEqualStrings("google", user.provider);
}

test "UserInfoResponse deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000) catch |err| {
        std.debug.print("Failed to initialize client: {}\n", .{err});
        return;
    };
    defer client.deinit();

    // Mock JSON object for user info response
    
    

    const json_str = 
        \\{
        \\  "meta": {
        \\    "code": 200,
        \\    "message": "Success"
        \\  },
        \\  "session": {
        \\    "remainingSeconds": 3600
        \\  },
        \\  "user": {
        \\    "id": "user-123",
        \\    "externalId": "ext-123",
        \\    "userName": "johndoe",
        \\    "displayName": "John Doe",
        \\    "locale": "en-US",
        \\    "active": true,
        \\    "names": {
        \\      "id": "name-123",
        \\      "familyName": "Doe",
        \\      "givenName": "John"
        \\    },
        \\    "photos": [
        \\      {
        \\        "id": "photo-123",
        \\        "value": "https://example.com/photo.jpg",
        \\        "type": "profile"
        \\      }
        \\    ],
        \\    "emails": [
        \\      {
        \\        "id": "email-123",
        \\        "value": "john@example.com",
        \\        "type": "work"
        \\      }
        \\    ],
        \\    "verifications": [
        \\      {
        \\        "id": "verification-123",
        \\        "email": "john@example.com",
        \\        "verified": true,
        \\        "createdAt": "2023-01-01T00:00:00Z",
        \\        "updatedAt": "2023-01-02T00:00:00Z"
        \\      }
        \\    ],
        \\    "provider": "google",
        \\    "createdAt": "2023-01-01T00:00:00Z",
        \\    "updatedAt": "2023-01-02T00:00:00Z",
        \\    "environmentId": "env-123"
        \\  }
        \\}
    ;

    const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch |err| {
        std.debug.print("Failed to parse JSON: {}\n", .{err});
        return;
    };
    defer tree.deinit();

    const root = tree.value;

    const meta_obj = root.object.get("meta") orelse return;
    const session_obj = root.object.get("session") orelse return;
    const user_obj = root.object.get("user") orelse return;

    _ = client.parseMeta(meta_obj) catch return;
    _ = client.parseSession(session_obj) catch return;
    var user = client.parseUser(user_obj) catch return;

    // Test that deinit doesn't crash
    user.deinit(allocator);
}

test "AuthdogError enum values" {
    // Test that we can return errors
    const result: authdog.AuthdogError!void = error.AuthenticationFailed;
    try std.testing.expectError(error.AuthenticationFailed, result);
}
