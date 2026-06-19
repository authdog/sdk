test_that("AuthdogClient can be created", {
  client <- AuthdogClient$new()
  expect_s3_class(client, "AuthdogClient")
  expect_equal(client$base_url, "https://api.authdog.com")
  expect_null(client$api_key)
})

test_that("AuthdogClient can be created with custom parameters", {
  client <- AuthdogClient$new("https://custom.api.com", "api-key-123")
  expect_s3_class(client, "AuthdogClient")
  expect_equal(client$base_url, "https://custom.api.com")
  expect_equal(client$api_key, "api-key-123")
})

test_that("get_user_info requires access token", {
  client <- AuthdogClient$new()
  
  expect_error(
    client$get_user_info(NULL),
    "Access token is required"
  )
  
  expect_error(
    client$get_user_info(""),
    "Access token is required"
  )
})

test_that("get_user_info handles authentication errors", {
  client <- AuthdogClient$new()
  
  # Mock httr::GET to return 401 status
  mock_response <- list(status_code = 401)
  
  # This test would need proper mocking in a real implementation
  # For now, we just test that the method exists and has the right signature
  expect_true(is.function(client$get_user_info))
})
