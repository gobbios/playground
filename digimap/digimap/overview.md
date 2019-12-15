# digimap

This is the attempt to write a shiny app which takes scans of maps with tracks and digitize the routes/paths that are drawn on these maps.

The app only accepts jp(e)g images as input and therefore needs the `jpeg` package installed (`install.packages("jpeg")`).

In addition you need the following packages:

`install.packages("shiny")`

`install.packages("shinyjs")`

`install.packages("rmarkdown")`

and probably also

`install.packages("devtools")`

To run it, use

`shiny::runGitHub("digimap", "gobbios", subdir = "digimap")`

A manual for how to use it is inside the app in the `manual` tab.
