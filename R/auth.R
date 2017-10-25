#' Medium Authentication
#'
#' `medium_set_auth()` interactivery asks for the token and store it as an environmental variable `MEDIUM_API_TOKEN`.
#' It is recommended to set this variable in `.Renviron`.
#'
#' @name medium_auth
#' @seealso \url{https://github.com/Medium/medium-api-docs#22-self-issued-access-tokens}
#' @export
medium_set_auth <- function() {
  if (!interactive()) stop("Set MEDIUM_API_TOKEN environemnt variable.")

  token <- if(rstudioapi::isAvailable()) {
    rstudioapi::askForPassword("Medium API token: ")
  } else {
    cat("Medium API token: ")
    readLines(n = 1L)
  }

  Sys.setenv(MEDIUM_API_TOKEN = token)
  token
}

medium_authorization_header <- function() {
  token <- Sys.getenv("MEDIUM_API_TOKEN")
  if (identical(token, "")) token <- medium_set_auth()
  httr::add_headers(Authorization = paste("Bearer", token))
}
