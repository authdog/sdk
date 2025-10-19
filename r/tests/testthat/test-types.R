test_that("Email can be created", {
  email <- Email$new("test@example.com", "work")
  expect_s3_class(email, "Email")
  expect_equal(email$value, "test@example.com")
  expect_equal(email$type, "work")
})

test_that("Email can be created without type", {
  email <- Email$new("test@example.com")
  expect_s3_class(email, "Email")
  expect_equal(email$value, "test@example.com")
  expect_null(email$type)
})

test_that("Photo can be created", {
  photo <- Photo$new("https://example.com/photo.jpg", "profile")
  expect_s3_class(photo, "Photo")
  expect_equal(photo$value, "https://example.com/photo.jpg")
  expect_equal(photo$type, "profile")
})

test_that("Names can be created", {
  names <- Names$new("Doe", "John")
  expect_s3_class(names, "Names")
  expect_equal(names$family_name, "Doe")
  expect_equal(names$given_name, "John")
})

test_that("Verification can be created", {
  verification <- Verification$new(TRUE, "email")
  expect_s3_class(verification, "Verification")
  expect_true(verification$verified)
  expect_equal(verification$type, "email")
})

test_that("Session can be created", {
  session <- Session$new(3600)
  expect_s3_class(session, "Session")
  expect_equal(session$remaining_seconds, 3600)
})

test_that("Meta can be created", {
  meta <- Meta$new(200, "Success")
  expect_s3_class(meta, "Meta")
  expect_equal(meta$code, 200)
  expect_equal(meta$message, "Success")
})

test_that("User can be created from data", {
  user_data <- list(
    id = "user-123",
    externalId = "ext-123",
    userName = "johndoe",
    displayName = "John Doe",
    provider = "google-oauth20",
    environmentId = "env-123",
    emails = list(
      list(value = "john@example.com", type = "work")
    ),
    photos = list(
      list(value = "https://example.com/photo.jpg", type = "profile")
    ),
    names = list(
      familyName = "Doe",
      givenName = "John"
    ),
    verifications = list(
      list(verified = TRUE, type = "email")
    )
  )
  
  user <- User$new(user_data)
  expect_s3_class(user, "User")
  expect_equal(user$id, "user-123")
  expect_equal(user$display_name, "John Doe")
  expect_length(user$emails, 1)
  expect_length(user$photos, 1)
  expect_s3_class(user$names, "Names")
  expect_length(user$verifications, 1)
})

test_that("UserInfoResponse can be created from data", {
  response_data <- list(
    meta = list(code = 200, message = "Success"),
    session = list(remainingSeconds = 3600),
    user = list(
      id = "user-123",
      externalId = "ext-123",
      userName = "johndoe",
      displayName = "John Doe",
      provider = "google-oauth20",
      environmentId = "env-123",
      emails = list(),
      photos = list(),
      names = list(),
      verifications = list()
    )
  )
  
  response <- UserInfoResponse$new(response_data)
  expect_s3_class(response, "UserInfoResponse")
  expect_s3_class(response$meta, "Meta")
  expect_s3_class(response$session, "Session")
  expect_s3_class(response$user, "User")
})
