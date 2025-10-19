#' Authdog Data Types
#'
#' Data type classes for Authdog SDK responses
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export

#' @title Email
#' @description Email information
#' @export
Email <- R6::R6Class("Email",
  public = list(
    #' @field value Email address
    value = NULL,
    
    #' @field type Email type
    type = NULL,
    
    #' @description
    #' Create a new Email instance
    #' @param value Email address
    #' @param type Email type
    initialize = function(value, type = NULL) {
      self$value <- value
      self$type <- type
    }
  )
)

#' @title Photo
#' @description Photo information
#' @export
Photo <- R6::R6Class("Photo",
  public = list(
    #' @field value Photo URL
    value = NULL,
    
    #' @field type Photo type
    type = NULL,
    
    #' @description
    #' Create a new Photo instance
    #' @param value Photo URL
    #' @param type Photo type
    initialize = function(value, type = NULL) {
      self$value <- value
      self$type <- type
    }
  )
)

#' @title Names
#' @description Name information
#' @export
Names <- R6::R6Class("Names",
  public = list(
    #' @field family_name Family name
    family_name = NULL,
    
    #' @field given_name Given name
    given_name = NULL,
    
    #' @description
    #' Create a new Names instance
    #' @param family_name Family name
    #' @param given_name Given name
    initialize = function(family_name = NULL, given_name = NULL) {
      self$family_name <- family_name
      self$given_name <- given_name
    }
  )
)

#' @title Verification
#' @description Verification information
#' @export
Verification <- R6::R6Class("Verification",
  public = list(
    #' @field verified Whether the item is verified
    verified = NULL,
    
    #' @field type Verification type
    type = NULL,
    
    #' @description
    #' Create a new Verification instance
    #' @param verified Whether the item is verified
    #' @param type Verification type
    initialize = function(verified = FALSE, type = NULL) {
      self$verified <- verified
      self$type <- type
    }
  )
)

#' @title Session
#' @description Session information
#' @export
Session <- R6::R6Class("Session",
  public = list(
    #' @field remaining_seconds Remaining seconds in session
    remaining_seconds = NULL,
    
    #' @description
    #' Create a new Session instance
    #' @param remaining_seconds Remaining seconds in session
    initialize = function(remaining_seconds = NULL) {
      self$remaining_seconds <- remaining_seconds
    }
  )
)

#' @title Meta
#' @description Meta information
#' @export
Meta <- R6::R6Class("Meta",
  public = list(
    #' @field code Response code
    code = NULL,
    
    #' @field message Response message
    message = NULL,
    
    #' @description
    #' Create a new Meta instance
    #' @param code Response code
    #' @param message Response message
    initialize = function(code = NULL, message = NULL) {
      self$code <- code
      self$message <- message
    }
  )
)

#' @title User
#' @description User information
#' @export
User <- R6::R6Class("User",
  public = list(
    #' @field id User ID
    id = NULL,
    
    #' @field external_id External user ID
    external_id = NULL,
    
    #' @field user_name Username
    user_name = NULL,
    
    #' @field display_name Display name
    display_name = NULL,
    
    #' @field emails List of Email objects
    emails = NULL,
    
    #' @field photos List of Photo objects
    photos = NULL,
    
    #' @field names Names object
    names = NULL,
    
    #' @field verifications List of Verification objects
    verifications = NULL,
    
    #' @field provider Authentication provider
    provider = NULL,
    
    #' @field environment_id Environment ID
    environment_id = NULL,
    
    #' @description
    #' Create a new User instance
    #' @param data User data from API response
    initialize = function(data) {
      self$id <- data$id
      self$external_id <- data$externalId
      self$user_name <- data$userName
      self$display_name <- data$displayName
      self$provider <- data$provider
      self$environment_id <- data$environmentId
      
      # Parse emails
      if (!is.null(data$emails)) {
        self$emails <- lapply(data$emails, function(email) {
          Email$new(email$value, email$type)
        })
      }
      
      # Parse photos
      if (!is.null(data$photos)) {
        self$photos <- lapply(data$photos, function(photo) {
          Photo$new(photo$value, photo$type)
        })
      }
      
      # Parse names
      if (!is.null(data$names)) {
        self$names <- Names$new(data$names$familyName, data$names$givenName)
      }
      
      # Parse verifications
      if (!is.null(data$verifications)) {
        self$verifications <- lapply(data$verifications, function(verification) {
          Verification$new(verification$verified, verification$type)
        })
      }
    }
  )
)

#' @title UserInfoResponse
#' @description Complete user info response
#' @export
UserInfoResponse <- R6::R6Class("UserInfoResponse",
  public = list(
    #' @field meta Meta object
    meta = NULL,
    
    #' @field session Session object
    session = NULL,
    
    #' @field user User object
    user = NULL,
    
    #' @description
    #' Create a new UserInfoResponse instance
    #' @param data Response data from API
    initialize = function(data) {
      if (!is.null(data$meta)) {
        self$meta <- Meta$new(data$meta$code, data$meta$message)
      }
      
      if (!is.null(data$session)) {
        self$session <- Session$new(data$session$remainingSeconds)
      }
      
      if (!is.null(data$user)) {
        self$user <- User$new(data$user)
      }
    }
  )
)
