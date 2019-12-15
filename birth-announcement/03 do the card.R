library(png)
library(maps)
library(RColorBrewer)
library(showtext)
library(jpeg)
source("birth-announcement/files/plotting_helpers.R")

# some general options
savetofile <- TRUE # should the result be printed directly to a jpeg file


# generate a template for the overall plot, which is then used repeatedly (for overplotting)
pfunc <- function() {
  plot(0, 0, type = "n", xlim = c(1, 4850), ylim = c(1, 3500), asp = 1, 
       xlab = "", ylab = "", xaxs = "i", yaxs = "i", axes = FALSE, ann = FALSE)
}

# read the two photos
img1 <- readJPEG(source = "birth-announcement/files/face.jpeg")
img2 <- readJPEG(source = "birth-announcement/files/crying.jpg")


exfac <- 3.2
if(savetofile) jpeg("birth-announcement/babycard.jpg", width = 14.5*exfac, height = 10.5*exfac, units = "cm", res = 1000, quality = 100, pointsize = 12 * exfac)

pfunc()


# do the maps -------------------------------------------------------------
# the placement of the individual elements requires a little trial and error ...
par(new = TRUE, mar = c(0, 0, 0, 0))
pfunc()
addimage("birth-announcement/files/japan.png",       0.22, x = 4155, y = 2440)
addimage("birth-announcement/files/france.png",      0.15, x = 3355, y = 2940)
addimage("birth-announcement/files/germany.png",     0.09, x = 4055, y = 2940)
addimage("birth-announcement/files/switzerland.png", 0.08, x = 3055, y = 2540)
addimage("birth-announcement/files/southafrica.png", 0.12, x = 3405, y = 2340)
addimage("birth-announcement/files/stork.png",       0.23, x = 3755, y = 2580)

# the baby pictures -------------------------------------------------------

par(new = TRUE)
pfunc()

# need to adapt the scale argument depending on the dimensions of the images
x <- placeimage(img1, xcent = 1385, ycent = 2600, scale = 1.7, horiz = TRUE)
x2 <- placeimage(img2, xcent = 3775, ycent = 1030, scale = 1.7, horiz = TRUE)

# some ornamentation
roundcorners(coords = x, startsize = 6, dens = 100, transp = 0.02)
cornerlines(coords = x, dims = dim(img1)[1:2], scale = 0.3, dens = 600 * exfac, width = 20, XCOL = "white")
framelines(coords = x, offs = 5, dims = dim(img1)[1:2], scale = 1, dens = 300 * exfac)

roundcorners(coords = x2, startsize = 6, dens = 100, transp = 0.02)
cornerlines(coords = x2, dims = dim(img2)[1:2], scale = 0.1, dens = 600 * exfac, width = 20, XCOL = "white")
framelines(coords = x2, offs = 5, dims = dim(img2)[1:2], scale = 1, dens = 300 * exfac)


# the announcement --------------------------------------------------------

par(new = TRUE, mar = c(0, 0, 0, 0), plt = c(0.15, 0.43, 0.11, 0.17))
fern(col = grey(0.2, 0.3), cex = 0.05)

par(new = TRUE, mar = c(0, 0, 0, 0), plt = c(0, 1, 0, 1))
pfunc()

font_add(family = "mplus", regular = "birth-announcement/files/mplus-2p-light.ttf")
fonttest <- showtextdb:::already_loaded(family = "mplus") # should be TRUE

par(family = ifelse(fonttest, "M+ 2p light", "serif"))

text(x = 1510-125, y = 1500, labels = "Geneviève", cex = 1.6)

text(x = 1510-125, y = 1200, labels = "née le 8 Août 2008 à Genève", cex = 0.6, font = 2)
text(x = 1510-125, y = 1050, labels = "geboren am 8 August 2008 in Genf", cex = 0.6)
text(x = 1510-125, y = 900, labels = "born August 8, 2008 in Geneva", cex = 0.6)
if (fonttest) text(x = 1510-125, y = 750, labels = "ジュネーブで2008年8月8日生まれ", cex = 0.58)
text(x = 1510-125, y = 260, labels = "Mom & Dad", cex = 0.5, font = 2)

paintline(x = 1510-125, y = 170, length = 600, dens = 100 * exfac, width = 6, horiz = TRUE)

if(savetofile) dev.off()
