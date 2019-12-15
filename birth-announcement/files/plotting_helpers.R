library(RColorBrewer)
library(maps)

placeimage <- function(img, xcent, ycent, scale = 1, horiz = TRUE, doplot = TRUE) {
  dims <- dim(img)[1:2]
  if(horiz) dims <- rev(dims)
  xleft <- xcent - dims[1]/2*scale
  xright <- xcent + dims[1]/2*scale
  ybot <- ycent - dims[2]/2*scale
  ytop <- ycent + dims[2]/2*scale
  if(doplot) rasterImage(img, xleft, ybot, xright, ytop)
  
  out <- rbind(
    c(xcent, ybot),
    c(xleft, ycent),
    c(xcent, ytop),
    c(xright, ycent)
  )
  return(out)
}

paintline <- function(x, y, length, dens, width, horiz, xcol = "black") {
  offs <- rnorm(dens, mean = 0, sd = width)
  if (horiz) {
    for (i in 1:dens) {
      pdata <- cbind(rnorm(2, mean = x, sd = length/2.5), rep(y + offs[i], 2))
      points(pdata, type = "l", lwd = runif(1, 0.1, 0.5), col = adjustcolor(xcol, runif(1, 0.1, 0.3)))
    }
  }
  if (!horiz) {
    for (i in 1:dens) {
      pdata <- cbind(rep(x + offs[i], 2), rnorm(2, mean = y, sd = length/2.5))
      points(pdata, type = "l", lwd = runif(1, 0.1, 0.5), col = adjustcolor(xcol, runif(1, 0.1, 0.3)))
    }
  }
  
}


framelines <- function(coords, offs, dims, scale = 1, dens = NULL, width = NULL) {
  if(is.null(dens)) dens <- 500
  if(is.null(width)) width <- 15
  asp <- dims[1]/dims[2]
  l <- dims[1]*scale
  paintline(x = coords[1, 1], y = coords[1, 2] - offs,
            length = l, dens = dens, width = width, horiz = TRUE)
  paintline(x = coords[2, 1] - offs, y = coords[2, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE)
  paintline(x = coords[3, 1], y = coords[3, 2] + offs,
            length = l, dens = dens, width = width, horiz = TRUE)
  paintline(x = coords[4, 1] + offs, y = coords[4, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE)
  
}

cornerlines <- function(coords, dims, scale = 1, dens = NULL, width = NULL, XCOL = "white") {
  if(is.null(dens)) dens <- 500
  if(is.null(width)) width <- 15
  asp <- dims[1]/dims[2]
  l <- dims[1]*scale
  paintline(x = max(coords[, 1]), y = coords[1, 2],
            length = l, dens = dens, width = width, horiz = TRUE, xcol = XCOL)
  paintline(x = max(coords[, 1]), y = coords[1, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE, xcol = XCOL)
  
  paintline(x = max(coords[, 1]), y = coords[3, 2],
            length = l, dens = dens, width = width, horiz = TRUE, xcol = XCOL)
  paintline(x = max(coords[, 1]), y = coords[3, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE, xcol = XCOL)
  
  paintline(x = min(coords[, 1]), y = coords[3, 2],
            length = l, dens = dens, width = width, horiz = TRUE, xcol = XCOL)
  paintline(x = min(coords[, 1]), y = coords[3, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE, xcol = XCOL)
  paintline(x = min(coords[, 1]), y = coords[1, 2],
            length = l, dens = dens, width = width, horiz = TRUE, xcol = XCOL)
  paintline(x = min(coords[, 1]), y = coords[1, 2],
            length = l*asp, dens = dens, width = width, horiz = FALSE, xcol = XCOL)
  
}

roundcorners <- function(coords, startsize = 5, dens = 10, transp = 0.01) {
  CEX <- seq(startsize, 2, length.out = dens)
  CEX <- exp(CEX)^2
  CEX <- ((CEX / max(CEX)) * startsize) + 1
  for(k in 1:4) {
    if(k == 1) pts <- c(x[2, 1], x[1, 2])
    if(k == 2) pts <- c(x[2, 1], x[3, 2])
    if(k == 3) pts <- c(x[4, 1], x[1, 2])
    if(k == 4) pts <- c(x[4, 1], x[3, 2])
    for(i in 1:dens) {
      points(pts[1], pts[2], pch = 16, col = adjustcolor("white", alpha.f = transp), cex = CEX[i])
    }
  }
}

# source: http://rstudio-pubs-static.s3.amazonaws.com/18905_c8e7a77909704e90a4a38cd3e8bc30f9.html
fern <- function(iter = 10000, ...) {
  # iter <- 10000
  p <- runif(iter)
  coord <- matrix(c(0, 0), ncol = 1)
  df <- rbind(data.frame(), t(coord))
  for (i in 1:iter) {
    if (p[i] <= 0.05) {
      m <- matrix(c(0, 0, 0, 0.16), nrow = 2, ncol = 2)
      const <- matrix(c(0, 0), ncol = 1)
    } else if (p[i] > 0.05 && p[i] <= 0.86) {
      m <- matrix(c(0.85, -0.04, 0.04, 0.85), nrow = 2, ncol = 2)
      const <- matrix(c(0, 1.6), ncol = 1)
    } else if (p[i] > 0.86 && p[i] <= 0.93) {
      m <- matrix(c(0.2, 0.23, -0.26, 0.22), nrow = 2, ncol = 2)
      const <- matrix(c(0, 1.6), ncol = 1)
      
    } else {
      m <- matrix(c(-0.15, 0.26, 0.28, 0.24), nrow = 2, ncol = 2)
      const <- matrix(c(0, 0.44), ncol = 1)
    }
    coord <- m %*% coord + const
    df <- rbind(df, t(coord))
  }
  
  plot(x = df[, 2], y = df[, 1], asp = 1, axes = F, ann = F, pch = 16, ...)
}

addimage <- function(imgpath, sizeprop, x = 0, y = 0, col = NULL, ...) {
  # determine image type and read it
  found <- FALSE
  if(length(grep(pattern = ".jpeg", x = imgpath, ignore.case = TRUE)) == 1 | length(grep(pattern = ".jpg", x = imgpath, ignore.case = TRUE)) == 1) {
    img <- jpeg::readJPEG(imgpath)
    found <- TRUE
  }
  if(length(grep(pattern = ".png", x = imgpath, ignore.case = TRUE)) == 1) {
    img <- png::readPNG(imgpath)
    if(!is.null(col)) {
      xcol  <-  col2rgb(col, ...) / 255
      for(i in 1:3) img[, , i]  <-  xcol[i]
      
    }
    found <- TRUE
  }
  
  if(!found) stop ("file type could not be determined")
  # get dimensions, orientation and aspect ratio
  d <- dim(img)[1:2]
  if(d[1] <= d[2]) horiz = TRUE else horiz = FALSE
  # d <- d[2:1]
  imgasp <- d[1]/d[2]
  # get plotting coordinates of existing plot
  xlims <- par("usr")[1:2]
  ylims <- par("usr")[3:4]
  xlength <- diff(xlims)
  ylength <- diff(ylims)
  # and plot size in inches
  plin <- par("pin")
  # and aspect ratio of plot area
  plasp <- plin[2]/plin[1]
  
  
  # coordinates for full size in top left corner
  xleft <- xlims[1]
  ytop <- ylims[2]
  xright <- xlims[1] + xlength*sizeprop
  (ybottom <- ytop - (ylength*sizeprop) * imgasp/plasp)
  # rasterImage(image = img, xleft = xleft, ybottom = ybottom, xright = xright, ytop = ytop)
  
  # shift to desired x/y location
  xshift <- mean(c(xleft, xright))
  yshift <- mean(c(ytop, ybottom))
  xleft <- xleft + x - xshift
  ytop <- ytop + y - yshift
  xright <- xright + x - xshift
  ybottom <- ybottom + y - yshift
  rasterImage(image = img, xleft = xleft, ybottom = ybottom, xright = xright, ytop = ytop)
  # rect(xleft = xleft, ybottom = ybottom, xright = xright, ytop = ytop)
  
}


# do the maps
cols <- adjustcolor(brewer.pal(5, "Pastel2"), alpha.f = 0.5)

png("birth-announcement/files/switzerland.png", width = 7, height = 5, bg = "transparent", units = "in", res = 300)
par(mar = c(0, 0, 0, 0))
map("world", regions = "Switzerland", fill = TRUE, col = adjustcolor("black", 0.15), border = NA)
dev.off()

png("birth-announcement/files/southafrica.png", width = 7, height = 5, bg = "transparent", units = "in", res = 300)
par(mar = c(0, 0, 0, 0))
x <- map("world", regions = c("South Africa(?!:Marion Island)"), fill = TRUE, col = adjustcolor("black", 0.15), border = NA, plot = FALSE)
# remove Lesotho manually...
loc <- which(is.na(x$x)) - 1
x$x <- x$x[1:loc]
x$y <- x$y[1:loc]
map(x, fill = TRUE, col = adjustcolor("black", 0.15), border = NA)
dev.off()

png("birth-announcement/files/france.png", width = 7, height = 5, bg = "transparent", units = "in", res = 300)
par(mar = c(0, 0, 0, 0))
map("world", regions = "France(?!:Corsica)", fill = TRUE, col = adjustcolor("black", 0.15), border = NA)
dev.off()

png("birth-announcement/files/japan.png", width = 5, height = 8, bg = "transparent", units = "in", res = 300)
par(mar = c(0, 0, 0, 0))
map("world", regions = "Japan", fill = TRUE, col = adjustcolor("black", 0.15), border = NA)
dev.off()

png("birth-announcement/files/germany.png", width = 5, height = 7, bg = "transparent", units = "in", res = 300)
par(mar = c(0, 0, 0, 0))
map("world", regions = "Germany", fill = TRUE, col = adjustcolor("black", 0.15), border = NA)
dev.off()

