library(shiny); library(jpeg)
library(shinyjs)

navbarPage("a map digitizer",
           tabPanel("overview",
                    includeMarkdown("overview.md")
           ),
           tabPanel("app",
                    sidebarLayout(
                      sidebarPanel(width = 3,
                                   fileInput("mymap", "Choose map image", accept = c(".jpg", ".jpeg")),
                                   tags$hr(style="border-color: black;"),
                                   h4("path"),
                                   # checkboxInput("drawpath", "draw the path?", value = 1),
                                   checkboxInput("drawmode", "in path mode?", value = 0),
                                   selectInput("pathcolor", "color for path", selected =  "gold",
                                               choices = c("gold", "green", "red", "white", "black")),
                                   actionButton("removelastrowpath", "delete last row"),
                                   selectInput("boxvisited", "choose location:",
                                               choices = 1:42), #lapply(1:42, function(X)X)
                                   actionButton("submitvisit", "submit box visit"),
                                   tags$hr(style="border-color: black;"),
                                   h4("send calibration point(s)"),
                                   actionButton("sendtotable", "submit"),
                                   actionButton("removelastrow", "delete latest row"),
                                   numericInput("calibstep", "real distance (m)", 10, width = '50%'),
                                   tags$hr(style="border-color: black;"),
                                   actionButton("checkdata", "download data")
                                   # downloadButton("downloadData", "Download")
                      ),
                      mainPanel(width = 9,
                                fluidRow(
                                  column(2, h4("path data"), tableOutput("pathdata")),
                                  useShinyjs(),
                                  inlineCSS(list("table" = "font-size: 8px")),
                                  column(10,
                                         plotOutput("mapimage", dblclick = "map_dblclick", brush = brushOpts(id = "map_brush", resetOnNew = TRUE), click = "map_click"),
                                         h4("calibration data (scale)"),
                                         tableOutput("tempshow"),
                                         tableOutput("calibration")
                                  )
                                )
                      )
                    )
           ),
           tabPanel("landmarks",
                    sidebarLayout(
                      sidebarPanel(
                        h4("select group"),
                        selectInput("calibgroup", "Choose a group:", choices = c("TON", "LOT", "CAP")),
                        h4("select landmark"),
                        selectInput("caliblocation", "Choose a landmark:", choices = NULL)

                      ),
                      mainPanel(
                        plotOutput("mapimage2", dblclick = "map2_dblclick", brush = brushOpts(id = "map2_brush", resetOnNew = TRUE), click = "map2_click"),
                        tableOutput("abscalibration")
                    )
                    )

           ),
           tabPanel("manual",
                    includeMarkdown("manual.md")
           )


)

