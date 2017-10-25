#' Publish R Markdown Document to 'Medium'
#'
#' Knit and post a given R Markdown file to 'Medium'.
#'
#' @param Rmd_file path to a .Rmd file. If `NULL`, use the activedocument.
#'
#' @export
medium_create_post_from_Rmd <- function(Rmd_file = NULL) {
  if(is.null(Rmd_file) && rstudioapi::isAvailable()){
    Rmd_file <- rstudioapi::getActiveDocumentContext()$path
  }

  if(tolower(tools::file_ext(Rmd_file)) != "rmd") {
    stop(sprintf("%s is not .Rmd file!", basename(Rmd_file)))
  }

  md_file <- rmarkdown::render(
    input = Rmd_file,
    output_format = rmarkdown::md_document(variant = "markdown_github"),
    encoding = "UTF-8"
  )

  front_matter <- rmarkdown::yaml_front_matter(Rmd_file, "UTF-8")

  mediumaddin_upload(
    md_file = md_file,
    title   = front_matter$title,
    tags    = front_matter$tags
  )
}

mediumaddin_upload <- function(md_file, title, tags) {
  # Medium doesn't insert title in its content automatically
  md_text <- paste(glue::glue("# title"),
                   read_utf8(md_file),
                   sep = "\n\n")

  md_dir <- dirname(md_file)
  imgs <- extract_image_paths(md_text)

  # Shiny UI -----------------------------------------------------------
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Preview",
                           right = miniUI::miniTitleBarButton("done", "Publish", primary = TRUE)),
    miniUI::miniContentPanel(
      shiny::fluidRow(
        shiny::column(3, shiny::radioButtons(
          "publishStatus", "publishStatus",
          choices = c("draft", "public", "unlisted")
        )),
        shiny::column(3, shiny::selectInput(
          "license", "license",
          choices = eval(formals(medium_create_post)$license)
        )),
        shiny::column(2, shiny::checkboxInput("publication", "associate with a publication")),
        shiny::column(4, shiny::conditionalPanel(
          condition = "input.publication == true",
          shiny::textInput("publicationId", label = "publication ID")
        ))
      ),
      shiny::hr(),
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

      publicationId <- if (nchar(input$publicationId) > 0) input$publicationId else NULL

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
        tags = tags,
        publishStatus = input$publishStatus,
        publicationId = publicationId
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
