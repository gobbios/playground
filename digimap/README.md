# digimap

This is the attempt to write a shiny app which takes scans of maps with tracks and digitize the routes/paths that are drawn by hand on these maps. The app originated from a project that looked at the paths monkeys in an enclosure took when visiting several feeding boxes placed at different locations.

The app only accepts jp(e)g images as input and therefore needs the `jpeg` package installed (`install.packages("jpeg")`).

In addition you need the following packages:

`install.packages("shiny")`

`install.packages("shinyjs")`

`install.packages("rmarkdown")`

and probably also

`install.packages("devtools")`

To run it, use

`shiny::runGitHub("gobbios/playground", subdir = "digimap/digimap")`

A manual for how to use it is actually inside the app.
