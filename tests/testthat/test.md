(This is a test post)

Include Plots
-------------

``` r
library(ggplot2)

nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
ggplot(nc) +
  geom_sf(aes(fill = AREA))
```

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

![](test_files/figure-markdown_github/plot-1.png)

include external graphics
-------------------------

![](https://upload.wikimedia.org/wikipedia/commons/7/78/Proboscis_monkey_%28Nasalis_larvatus%29_composite.jpg)
