#' Medium Users API
#'
#' Returns details of the user who has granted permission to the application.
#'
#' @name medium_user
#' @seealso \url{https://github.com/Medium/medium-api-docs#getting-the-authenticated-users-details}
#' @return
#'   * `id`: A unique identifier for the user.
#'   * `username`: The user’s username on Medium.
#'   * `name`: The user’s name on Medium.
#'   * `url`: The URL to the user’s profile on Medium
#'   * `imageUrl`: The URL to the user’s avatar on Medium
#' @export
medium_get_current_user <- function() {
  result <- medium_request("GET", "/v1/me")

  # user ID is needed to send requests to Publications API and Posts API.
  Sys.setenv("MEDIUM_USER_ID" = result$data$id)

  result$data
}
