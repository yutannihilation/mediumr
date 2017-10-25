#' Medium Publications API
#'
#' `medium_get_publications()` returns a full list of publications that the user is related to in some way.
#' `medium_get_contributors()` returns a list of contributors for a given publication.
#'
#' @name medium_publication
#' @return
#' Publication:
#'   * `id`: A unique identifier for the publication.
#'   * `name`: The publication's name on Medium.
#'   * `description`: Short description of the publication
#'   * `url`: The URL to the publication's homepage
#'   * `imageUrl`: The URL to the publication's image/logo
#' Contributor:
#'   * `publicationId`: An ID for the publication.
#'   * `userId`: A user ID of the contributor.
#'   * `role`: Role of the user identified by userId in the publication identified by publicationId. 'editor' or 'writer'.
#' @export
medium_get_publications <- function() {
  userId <- medium_get_current_user_id()

  result <- medium_request("GET", glue::glue("/v1/users/{userId}/publications"))
  result$data
}

#' @rdname medium_publication
#' @param publicationId Publication ID.
#' @export
medium_get_contributors <- function(publicationId) {
  result <- medium_request("GET", glue::glue("/v1/publications/{publicationId}/contributors"))
}
