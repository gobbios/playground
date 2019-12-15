library(jpeg)
source("birth-announcement/files/plotting_helpers.R")

img1 <- readJPEG("birth-announcement/files/face.jpeg")
img2 <- readJPEG("birth-announcement/files/crying.jpg")
plot(0, 0, type = "n", asp = 1)
placeimage(img1, 0, 0.5, scale = 0.0005, horiz = TRUE)
x2 <- placeimage(img2, -0.5, -0.5, scale = 0.0005, horiz = TRUE)


plot(0, 0, type = "n", asp = 1)
paintline(0, 0, length = 1, width = 0.01, dens = 500, horiz = TRUE, xcol = "red")
paintline(0, 0, length = 0.4, width = 0.02, dens = 500, horiz = FALSE, xcol = "blue")

x2
framelines(coords = x2, offs = 0.1, dims = dim(img1)[1:2], width = 0.01, scale = 0.0005)

# Barnsley fern
# source: http://rstudio-pubs-static.s3.amazonaws.com/18905_c8e7a77909704e90a4a38cd3e8bc30f9.html
fern(1000, col = "black", cex = 0.5)



