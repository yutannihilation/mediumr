#' Publish R Markdown Document to 'Medium'
#'
#' Knit and post a given R Markdown file to 'Medium'.
#'
#' @param input path to a .Rmd file. If `NULL`, use the activedocument.
#'
#' @export
medium_upload_Rmd <- function(input = NULL) {
  if(is.null(input) && rstudioapi::isAvailable()){
    input <- rstudioapi::getActiveDocumentContext()$path
  }

  if(tolower(tools::file_ext(input)) != "rmd") {
    stop(sprintf("%s is not .Rmd file!", basename(input)))
  }

  md_file <- rmarkdown::render(
    input = input,
    output_format = rmarkdown::md_document(variant = "markdown_github"),
    encoding = "UTF-8"
  )

  front_matter <- rmarkdown::yaml_front_matter(input, "UTF-8")

  mediumaddin_upload(
    md_file = md_file,
    title   = front_matter$title,
    tags    = front_matter$tags
  )
}

mediumaddin_upload <- function(md_file, title, tags) {
  md_text <- read_utf8(md_file)
  md_dir <- dirname(md_file)
  imgs <- extract_image_paths(md_text)

  # Shiny UI -----------------------------------------------------------
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Preview",
                           right = miniUI::miniTitleBarButton("done", "Publish", primary = TRUE)),
    miniUI::miniContentPanel(
      shiny::h1(title, align = "center"),
      shiny::div(
        shiny::HTML(
          markdown::markdownToHTML(md_file,
                                   fragment.only = TRUE,
                                   encoding = "UTF-8")
        )
      )
    )
  )

  # Shiny Server -------------------------------------------------------
  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      if(identical(Sys.getenv("MEDIUM_API_TOKEN"), "")) {
        token <- rstudioapi::askForPassword("Input Medium API token:")
        Sys.setenv(MEDIUM_API_TOKEN = token)
        return(FALSE)
      }

      progress <- shiny::Progress$new(session, min=0, max=2)
      on.exit(progress$close())

      # Step 1) Upload Images
      progress$set(message = "Uploading the images...")

      num_imgs <- length(imgs)
      for (i in seq_along(imgs)) {
        progress$set(detail = imgs[i])

        # attempt to avoid rate limits
        Sys.sleep(0.2)

        image_url <- medium_upload_image(file.path(md_dir, imgs[i]))$url
        md_text <- stringr::str_replace_all(md_text, stringr::fixed(imgs[i]), image_url)

        progress$set(value = i/num_imgs)
      }

      # Step 2) Upload Markdown
      progress$set(message = "Updating the document...")

      result <- medium_create_post(
        title = title,
        contentFormat = "markdown",
        content = md_text,
        tags = tags
      )

      progress$set(value = 2, message = "Done!")
      Sys.sleep(2)

      invisible(shiny::stopApp())
      return(result)
    })
  }

  viewer <- shiny::dialogViewer("Preview", width = 1000, height = 800)
  shiny::runGadget(ui, server, viewer = viewer)
}

read_utf8 <- function(x) {
  paste(readLines(x, encoding = "UTF-8"), collapse = "\n")
}

extract_image_paths <- function(md_text) {
  html_doc <- xml2::read_html(commonmark::markdown_html(md_text))
  img_nodes <- xml2::xml_find_all(html_doc, ".//img")
  xml2::xml_attr(img_nodes, "src")
}
