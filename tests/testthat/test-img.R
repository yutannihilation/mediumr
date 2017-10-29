context("test-img.R")

test_that("extract_image_paths() works", {
  md_text <- read_utf8("test.md")
  imgs <- extract_image_paths(md_text)
  expect_identical(imgs, "test_files/figure-markdown_github/plot-1.png")
})
