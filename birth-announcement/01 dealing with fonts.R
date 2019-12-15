library(showtext)
font_add(family = "mplus", regular = "birth-announcement/files/mplus-2p-light.ttf")
showtextdb:::already_loaded(family = "mplus") # should be TRUE

plot(0, 0, type = "n")
par(family = "M+ 2p light")
text(0, 0, labels = "japanese text: 2008年8月8日")

# If you see Japanese characters, it worked