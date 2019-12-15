# function to extract relevant data from digitized maps
# currently doing:
#   - extract locations visited (numerical vector)
#   - calculate segment lengths of paths between locations visited (data frame)
#   - draw the path with location visited (plot)

pathdataextraction <- function(x, output = c("visits", "segmentlengths", "figure")) {
  # what file type:
  if(grep("csv", x = x) == 1) {
    xdata <- read.csv(x)
    pdata <- subset(xdata, cat == "path")
    sdata <- subset(xdata, cat == "calib")
    ldata <- subset(xdata, cat %in% as.character(1:6))
  }


  # return visited locations
  if(output == "visits") {
    res <- as.numeric(na.omit(pdata$x2))
    return(res)
  }

  # plot path
  if(output == "figure") {
    plot(0, 0, type="n", xlim = range(pdata$x1), ylim = range(pdata$y1), asp = 1, ann = FALSE, axes = FALSE)
    points(pdata$x1, pdata$y1, type = "l")
    points(pdata$x1[1], pdata$y1[1], pch = 16, col = "red", cex = 0.5)
    points(pdata$x1[nrow(pdata)], pdata$y1[nrow(pdata)], pch = 16, col = "blue", cex = 0.5)
    bdata <- subset(pdata, !is.na(x2))
    xcol <- rgb(1, 215/255, 0, alpha = 0.7)
    points(bdata$x1, bdata$y1, pch = 16, col = xcol, cex = 2)
    text(bdata$x1, bdata$y1, labels = bdata$x2)
    box()
    legend(mean(range(pdata$x1)), max(pdata$y1)*1.05, legend = c("start", "stop"), pch = 16, xpd = T, col = c("red", "blue"), ncol = 2, xjust = 0.5, yjust = 0.5, cex = 0.5)
  }



  # get scale measurements in pixels
  scaledists <- apply(sdata, 1, function(X) dist(rbind(X[c("x1", "y1")], as.numeric(X[c("x2", "y2")]))))
  # and transform to meters depending on 'realdist'
  scaledists <- scaledists / sdata$realdist
  scaledistsCV <- sd(scaledists)/mean(scaledists) * 100
  if(scaledistsCV > 5) {
    message("check the scale measurements, they seem to be not very consistent (large variation) in this file:", "\n", x)
  }

  # calculate path lengths of segments between visits
  nseg <- sum(!is.na(pdata$x2)) - 1
  # continue only if there was at least one segment (i.e. at least two visits)
  if(output == "segmentlengths" & nseg == 0) {
    message("no (or only one) location visited: no segments available")
    return(NULL)
  }

  if(output == "segmentlengths" & nseg > 0) {
    segdists <- numeric(nseg)
    visited <- pdata$x2[!is.na(pdata$x2)]
    visitline <- which(!is.na(pdata$x2))
    i=1
    for(i in 1:nseg) {
      temp <- pdata[visitline[i] : visitline[i+1], ]
      dists <- as.matrix(dist(temp[, c("x1", "y1")]))
      dists <- dists[2:ncol(dists), 1:(ncol(dists)-1)]
      dists <- sum(diag(dists))
      segdists[i] <- dists
    }
    res <- data.frame(from = visited[1:(length(visited) - 1)], to = visited[2:length(visited)])
    res$distpixels <- segdists
    res$dist <- segdists/mean(scaledists)
    return(res)
  }

}


