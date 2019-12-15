library(RColorBrewer)
xdata <- read.csv("HartRisley95/HartRisley95data.csv")

xdata$incomeclass3 <- factor(xdata$incomeclass3, levels = c("welfare", "workingclass", "prof"))
xdata$incomeclass4 <- factor(xdata$incomeclass4, levels = c("welfare", "workingclass", "middleclass", "prof"))
xdata[, "SEI"] <- as.numeric(xdata[, "SEI"])

# extract two summary rows
xsummary <- xdata[43:44, 5:ncol(xdata)]
# clean data
xdata <- droplevels(xdata[1:42, ])

# column means
round(colMeans(xdata[, 5:ncol(xdata)]))
# and correlations with SEI
round(cor(xdata[, "SEI"], xdata[, 5:ncol(xdata)]), 2)
# compare to summaries from the book (top row are means, bottom row are correlations)
xsummary



png(filename = "hartrisley.png", height = 3.5, width = 4, units = "in", res = 200)
xcols <- brewer.pal(4, name = "Dark2")
par(family = "serif", las = 1)
plot(xdata$SEI, xdata$vocab_all_words, xlim = c(0, 100), ylim = c(0, 3700), yaxs = "i", xaxs = "i", axes = FALSE,
     xlab = "SES", ylab = "mean words per hour", pch = 16, col = xcols[xdata$incomeclass4])
axis(2)
axis(3)
box()

yvals <- tapply(xdata$vocab_all_words, xdata$incomeclass4, mean)
xloc <- tapply(xdata$SEI, xdata$incomeclass4, mean)
rect(xleft = xloc - 5, ybottom = 0, xright = xloc + 5, ytop = yvals, border = NA, col = adjustcolor(xcols, 0.5))
text(x = xloc, y = c(-100), labels = levels(xdata$incomeclass4), xpd = TRUE, srt = 45,
     adj = 1, cex = 0.7, col = xcols, font = 2)

res <- lm(vocab_all_words ~ SEI, data = xdata)
abline(res)

dev.off()
