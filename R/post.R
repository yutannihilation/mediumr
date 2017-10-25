#' Medium Posts API
#'
#' Creates a post on the authenticated user's profile or a given publication.
#'
#' @name medium_post
#' @param title
#'   The title of the post. Note that this title is used for SEO and when rendering the post as a listing,
#'   but will not appear in the actual post. For that, the title must be specified in the `content` field as well.
#'   Titles longer than 100 characters will be ignored. In that case, a title will be synthesized from the first
#'   content in the post when it is published.
#' @param contentFormat
#'   The format of the `content` field. There are two valid values, `"html"`, and `"markdown"`.
#' @param content
#'   The body of the post, in a valid, semantic, HTML fragment, or Markdown. Further markups may be supported
#'   in the future. For a full list of accepted HTML tags, see [here](https://medium.com/@katie/a4367010924e).
#'   If you want your title to appear on the post page, you must also include it as part of the post content.
#' @param tags
#'   Tags to classify the post. Only the first three will be used. Tags longer than 25 characters will be ignored.
#' @param canonicalUrl
#'   The original home of this content, if it was originally published elsewhere.
#' @param publishStatus
#'   The status of the post. Valid values are `"public"`, `"draft"`, or `"unlisted"`. The default is `"draft"`.
#' @param license
#'   The license of the post. Valid values are `"all-rights-reserved"`, `"cc-40-by"`, `"cc-40-by-sa"`, `"cc-40-by-nd"`,
#'   `"cc-40-by-nc"`, `"cc-40-by-nc-nd"`, `"cc-40-by-nc-sa"`, `"cc-40-zero"`, `"public-domain"`.
#'   The default is `"all-rights-reserved"`.
#' @param notifyFollowers
#'   Whether to notifyFollowers that the user has published.
#' @param publicationId
#'   Publication ID.
#' @seealso \url{https://github.com/Medium/medium-api-docs#33-posts}
#' @export
medium_create_post <- function(title,
                               contentFormat = c("markdown", "html"),
                               content = "",
                               tags = c("R", "rstats"),
                               canonicalUrl = NULL,
                               publishStatus = c("draft", "public", "unlisted"),
                               license = c("all-rights-reserved", "cc-40-by", "cc-40-by-sa", "cc-40-by-nd",
                                           "cc-40-by-nc", "cc-40-by-nc-nd", "cc-40-by-nc-sa", "cc-40-zero",
                                           "public-domain"),
                               notifyFollowers = FALSE,
                               publicationId = NULL) {
  contentFormat <- match.arg(contentFormat)
  publishStatus <- match.arg(publishStatus)
  license <- match.arg(license)

  path <- if (is.null(publicationId)) {
    authorId <- medium_get_current_user_id()
    glue::glue("/v1/users/{authorId}/posts")
  } else {
    glue::glue("/v1/publications/{publicationId}/posts")
  }

  result <- medium_request("POST",
                           path,
                           body = list(
                             title = title,
                             contentFormat = contentFormat,
                             content = content,
                             tags = tags,
                             canonicalUrl = canonicalUrl,
                             publishStatus = publishStatus,
                             license = license,
                             notifyFollowers = notifyFollowers
                           ),
                           encode = "json")

  if (interactive()) browseURL(result$url)

  result
}
