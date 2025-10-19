test_that("AuthdogError can be created", {
  error <- AuthdogError$new("Test error message")
  expect_s3_class(error, "AuthdogError")
  expect_equal(error$message, "Test error message")
})

test_that("AuthenticationError can be created", {
  error <- AuthenticationError$new("Authentication failed")
  expect_s3_class(error, "AuthenticationError")
  expect_equal(error$message, "Authentication failed")
})

test_that("AuthenticationError has default message", {
  error <- AuthenticationError$new()
  expect_s3_class(error, "AuthenticationError")
  expect_equal(error$message, "Authentication failed")
})

test_that("ApiError can be created", {
  error <- ApiError$new("API request failed")
  expect_s3_class(error, "ApiError")
  expect_equal(error$message, "API request failed")
})

test_that("ApiError has default message", {
  error <- ApiError$new()
  expect_s3_class(error, "ApiError")
  expect_equal(error$message, "API request failed")
})
