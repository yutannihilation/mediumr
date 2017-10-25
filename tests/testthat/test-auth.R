context("auth")

test_that("Authorization header", {
  withr::with_envvar(
    setNames("xxxx", "MEDIUM_API_TOKEN"),
    {
      expect_equivalent(
        medium_authorization_header()$headers["Authorization"],
        "Bearer xxxx"
      )
    }
  )
})
