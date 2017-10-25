#' Medium Images API
#'
#' Uploading an image.
#'
#' @name medium_image
#' @param image A path to a image file or `form_file` object.
#' @examples
#' \dontrun{
#' medium_upload_image("path/to/image.png")
#' medium_upload_image(httr::upload_file("path/to/image.png"))
#' }
#' @seealso \url{https://github.com/Medium/medium-api-docs#34-images}
#' @export
medium_upload_image <- function(image) {
  if (!inherits(image, "form_file")) image <- httr::upload_file(image)

  result <- medium_request("POST", "/v1/images", body = list(image = image))
  result
}
