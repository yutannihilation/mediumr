# mediumr

[![Travis build status](https://travis-ci.org/yutannihilation/mediumr.svg?branch=master)](https://travis-ci.org/yutannihilation/mediumr)

R Interface to [Medium API](https://github.com/Medium/medium-api-docs).

## Installation

You can install mediumr from github with:

``` r
# install.packages("devtools")
devtools::install_github("yutannihilation/mediumr")
```

## Addin

Using "Post to Medium" addin, you can post Rmd file to Medium directly:

![](man/figures/scresnshot.png)

## Usage

### Authentication

Issue an API token and set it as an environmental variable `MEDIUM_API_TOKEN`. You should add this line in your `.Renviron`:

```
MEDIUM_API_TOKEN='<your api token here>'
```

### Get Current User

```r
library(mediumr)

medium_get_current_user()
#> $id
#> [1] "5303d74c64f66366f00cb9b2a94f3251bf5"
#> 
#> $username
#> [1] "majelbstoat"
#> 
#> $name
#> [1] "Jamie Talbot"
#> 
#> $url
#> [1] "https://medium.com/@majelbstoat"
#> 
#> $imageUrl
#> [1] "https://images.medium.com/0*fkfQiTzT7TlUGGyI.png"
```

### Create A Post

````r
content <- "
# test

1. test1
2. test2

```r
this <- is(test)
```
"
medium_create_post("test", content = content)
````

### Upload An Image

```r
medium_upload_image("/path/to/image.png")
```
