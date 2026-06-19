#' Authdog R SDK Client
#'
#' R6 class for interacting with the Authdog API
#'
#' @docType class
#' @importFrom R6 R6Class
#' @importFrom httr GET add_headers content stop_for_status
#' @importFrom jsonlite fromJSON
#' @export
AuthdogClient <- R6::R6Class("AuthdogClient",
  public = list(
    #' @field base_url Base URL for the Authdog API
    base_url = NULL,
    
    #' @field api_key Optional API key for authentication
    api_key = NULL,
    
    #' @description
    #' Create a new AuthdogClient instance
    #' @param base_url Base URL for the Authdog API (default: "https://api.authdog.com")
    #' @param api_key Optional API key for authentication
    #' @return A new AuthdogClient instance
    initialize = function(base_url = "https://api.authdog.com", api_key = NULL) {
      self$base_url <- base_url
      self$api_key <- api_key
    },
    
    #' @description
    #' Get user information using an access token
    #' @param access_token The access token for authentication
    #' @return UserInfoResponse object containing user information
    #' @examples
    #' client <- AuthdogClient$new()
    #' user_info <- client$get_user_info("your-access-token")
    get_user_info = function(access_token) {
      if (is.null(access_token) || access_token == "") {
        stop(AuthenticationError$new("Access token is required"))
      }
      
      headers <- list(
        "Authorization" = paste("Bearer", access_token),
        "Content-Type" = "application/json"
      )
      
      if (!is.null(self$api_key)) {
        headers[["X-API-Key"]] <- self$api_key
      }
      
      url <- paste0(self$base_url, "/v1/userinfo")
      
      tryCatch({
        response <- httr::GET(url, httr::add_headers(.headers = headers))
        
        if (httr::status_code(response) == 401) {
          stop(AuthenticationError$new("Authentication failed: Invalid access token"))
        }
        
        httr::stop_for_status(response)
        
        content <- httr::content(response, "text", encoding = "UTF-8")
        parsed_content <- jsonlite::fromJSON(content, simplifyVector = FALSE)
        
        return(UserInfoResponse$new(parsed_content))
        
      }, error = function(e) {
        if (inherits(e, "AuthenticationError") || inherits(e, "ApiError")) {
          stop(e)
        }
        
        if (httr::status_code(response) >= 400) {
          stop(ApiError$new(paste("API error:", httr::content(response, "text"))))
        }
        
        stop(ApiError$new(paste("Request failed:", e$message)))
      })
    }
  )
)
