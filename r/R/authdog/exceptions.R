#' Authdog Error Classes
#'
#' Custom error classes for Authdog SDK
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export

#' @title Base Authdog Error
#' @description Base error class for all Authdog SDK errors
#' @export
AuthdogError <- R6::R6Class("AuthdogError",
  inherit = error,
  public = list(
    #' @field message Error message
    message = NULL,
    
    #' @description
    #' Create a new AuthdogError instance
    #' @param message Error message
    initialize = function(message) {
      self$message <- message
      super$initialize(message)
    }
  )
)

#' @title Authentication Error
#' @description Error class for authentication failures
#' @export
AuthenticationError <- R6::R6Class("AuthenticationError",
  inherit = AuthdogError,
  public = list(
    #' @description
    #' Create a new AuthenticationError instance
    #' @param message Error message
    initialize = function(message = "Authentication failed") {
      super$initialize(message)
    }
  )
)

#' @title API Error
#' @description Error class for API request failures
#' @export
ApiError <- R6::R6Class("ApiError",
  inherit = AuthdogError,
  public = list(
    #' @description
    #' Create a new ApiError instance
    #' @param message Error message
    initialize = function(message = "API request failed") {
      super$initialize(message)
    }
  )
)
