MEDIUM_API_BASE_URL <- "https://api.medium.com"

medium_request <- function(verb, path, ...) {
  res <- httr::VERB(
    verb = verb,
    url = MEDIUM_API_BASE_URL,
    path = path,
    medium_authorization_header()
  )

  httr::stop_for_status(res)

  httr::content(res)
}
