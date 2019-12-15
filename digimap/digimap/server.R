library(shiny)

shinyServer(function(input, output, session) {
  # set range of selection (brush) -> for zooming
  ranges <- reactiveValues(x = NULL, y = NULL)
  # obtain image data (if none is selected take the example image)
  getplotdata <- reactive({
    mymap <- input$mymap
    if(is.null(mymap)) myfig <- readJPEG(source = "img/testimage1.jpeg", native = TRUE)
    if (!is.null(mymap)) myfig <- readJPEG(source = mymap$datapath, native = TRUE)
    return(myfig)
  })
  # get dimensions of the image
  getplotdatadims <- reactive(dim(getplotdata()))

  # plot image and add path and visited locations
  output$mapimage <- renderPlot({
    D <- getplotdatadims()
    par(mar = c(0, 0, 0, 0))
    if(is.null(ranges$x)) {
      plot(0, 0, "n", xlim = c(1, D[2]), ylim = c(1, D[1]), asp = 1, ann = F, axes = F, xaxs = "i", yaxs = "i")
    } else {
      plot(0, 0, "n", xlim = ranges$x, ylim = ranges$y, asp = 1, ann = F, axes = F, xaxs = "i", yaxs = "i")
    }
    rasterImage(getplotdata(), xleft = 1, ybottom = 1, xright = D[2], ytop = D[1])
    if(nrow(pathdata$df) >= 2 ) { # & input$drawpath
      for(i in 2:nrow(pathdata$df)) {
          arrows(x0 = pathdata$df[i-1, 1], y0 = pathdata$df[i-1, 2], x1 = pathdata$df[i, 1], y1 = pathdata$df[i, 2], length = 0.1, col = input$pathcolor, lwd = 2)
      }
      X <- which(!is.na(pathdata$df[, 3]))
      if(length(X) >= 1) {
        temp <- pathdata$df[X, , drop = FALSE]
        text(temp[, 1], temp[, 2], label = "@", font = 2, col = "blue", cex=2)
        # points(temp[, 1], temp[, 2], pch = 8, col = "blue", cex=2)
      }
    }
  })

  # for zooming
  observeEvent(input$map_dblclick, {
    brush <- input$map_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
    } else {
      D <- getplotdatadims()
      ranges$x <- c(1, D[2])
      ranges$y <- c(1, D[1])
    }
  })

  # prepare path data
  pathdata <- reactiveValues()
  pathdata$df <- matrix(ncol = 6, nrow = 0)
  pathdata$visits <- numeric(0)

  # prepare calibration data (for scale measurements)
  calibdata <- reactiveValues()
  calibdata$df <- data.frame(x1 = NA, y1 = NA, x2 = NA, y2 = NA)

  calibrationcounter <- reactiveValues(cnt = 0)
  observeEvent(input$map_click, {
    # draw path mode
    if(input$drawmode) {
      pathdata$df <- rbind(pathdata$df, NA)
      nr <- nrow(pathdata$df)
      pathdata$df[nr, 1] <- input$map_click$x
      pathdata$df[nr, 2] <- input$map_click$y
    }
    # calibration mode
    if(!input$drawmode) {
      if(calibrationcounter$cnt[1] %% 2 == 0) {
        calibdata$df$x1[1] <- input$map_click$x
        calibdata$df$y1[1] <- input$map_click$y
      } else {
        calibdata$df$x2[1] <- input$map_click$x
        calibdata$df$y2[1] <- input$map_click$y
      }
      calibrationcounter$cnt[1] <- calibrationcounter$cnt[1] + 1
    }
  })

  observeEvent(input$submitvisit, {
    #nr <- length(pathdata$visits)
    # pathdata$visits <- input$boxvisited
    nr <- nrow(pathdata$df)
    X <- as.integer(input$boxvisited)
    pathdata$df[nr, 3] <- X
  })

  output$tempshow <- renderTable({calibdata$df})

  # actual calibration data
  calibdata$realdata <- data.frame(x1 = numeric(0), y1 = numeric(0), x2 = numeric(0), y2 = numeric(0), realdist = numeric(0), pixeldist = numeric(0))
  cn <- c("x1", "y1", "x2", "y2", "realdist", "pixeldist")

  observeEvent(input$sendtotable, {
    cdata <- as.numeric(calibdata$df[1, ]) #
    calibdata$realdata <- rbind(calibdata$realdata, c(cdata, as.numeric(input$calibstep[1]), NA))
    colnames(calibdata$realdata) <- cn
    temp <- data.frame(c(calibdata$df$x1[1], calibdata$df$x2[1]), c(calibdata$df$y1[1], calibdata$df$y2[1]))
    calibdata$realdata[nrow(calibdata$realdata), "pixeldist"] <-  as.numeric(dist(temp))
  })
  observeEvent(input$removelastrow, {
    X <- nrow(calibdata$realdata)
    if(X >= 1) calibdata$realdata <- calibdata$realdata[-X, ]
  })


  output$calibration <- renderTable({
    calibdata$realdata[, , drop = FALSE]
  })
  output$pathdata <- renderTable({
    TEMP <- pathdata$df[, 1:3, drop = FALSE]
    colnames(TEMP) <- c("x", "y", "ZZ")
    TEMP <- data.frame(x=round(TEMP[, 1]), y = round(TEMP[, 2]), visit = as.character(TEMP[, 3]))
    # TEMP <- data.frame(TEMP, visit = pathdata$visits)
    if(nrow(TEMP) >= 2) TEMP <- TEMP[nrow(TEMP):1, ]
    TEMP
  }, na = "", digits = 0)

  observeEvent(input$removelastrowpath, {
    X <- nrow(pathdata$df)
    if(X >= 1) pathdata$df <- pathdata$df[-X, ]
  })


  # prepare output for download
  # file needs to contain at least two different data sets:
  # 1) path data (x,y pairs)
  # 2) calibration points (2 pairs plus real distance)
  # 3) eventually need to add fixed locations?
  generateoutput <- reactive({
    MYOUT <- matrix(ncol = 6, nrow = nrow(pathdata$df) + nrow(calibdata$realdata), "")
    MYOUT1 <- cbind('calib', apply(calibdata$realdata[, 1:5, drop = FALSE], 2, as.character))
    MYOUT2 <- cbind('path', apply(pathdata$df[, 1:5, drop = FALSE], 2, as.character))

    if(nrow(calibdata$realdata) >= 1) MYOUT[1:nrow(calibdata$realdata), ] <- MYOUT1[, ]
    if(nrow(pathdata$df) >= 1) MYOUT[(nrow(calibdata$realdata) + 1) : nrow(MYOUT), ] <- MYOUT2

    MYOUT3 <- t(abscalibdata$df)
    MYOUT3 <- cbind(colnames(abscalibdata$df), MYOUT3)
    MYOUT3 <- cbind(MYOUT3, rep(NA, nrow(MYOUT3)), rep(NA, nrow(MYOUT3)), rep(NA, nrow(MYOUT3)) )
    MYOUT <- rbind(MYOUT, MYOUT3)
    colnames(MYOUT) <- c("cat", "x1", "y1", "x2", "y2", "realdist")
    # add filename of source
    filename <- input$mymap$name
    if(is.null(filename)) filename <- "example"
    MYOUT <- cbind(MYOUT, filename)

    # prepare as list as well, so we can save an .RData file, too
    res <- list()
    res$calib <- calibdata$realdata[, 1:5, drop = FALSE]
    res$path <- pathdata$df[, 1:3, drop = FALSE]
    res$landmarks <- abscalibdata$df
    res$filename <- filename

    xres <- list()
    xres$DF <- MYOUT
    xres$LIST <- res
    return(xres)
  })




  enterfilename <- function() {
    modalDialog(textInput("filename", "Choose a file name"), footer = tagList(modalButton("Cancel"), actionButton("saveresults", "OK")))
  }

  observeEvent(input$checkdata, showModal(enterfilename()))

  observeEvent(input$saveresults, {
    # run checks:
    rdata <- generateoutput()$LIST
    check1 <- check2 <- TRUE
    # at least three calibration/scale measurements
    if(nrow(rdata$calib) < 3 | sum(!is.na(rdata$calib$x2)) <= 3) {
      showModal(modalDialog(
        "Less than three calibration/scale measurements",
        easyClose = TRUE,
        footer = NULL
      ))
      check1 <- FALSE
    }
    # all landmarks checked?
    check2 <- sum(is.na(colSums(rdata$landmarks))) == 0
    if(!check2) {
      showModal(modalDialog(
        "Less than six landmarks recorded",
        easyClose = TRUE,
        footer = NULL
      ))
    }

    # only continue if both checks are satisfied
    if(check1 & check2) {
      FN <- input$filename
      if(FN == "") {
        showModal(modalDialog(
          "no files have been written",
          tags$br(),
          "please try again and enter a file name"
        ))
      } else {
        fn1 <- paste(FN, ".RData", sep = "")
        fn2 <- paste(FN, ".csv", sep = "")
        # check whether files exist already
        if(fn1 %in% list.files() | fn2 %in% list.files()) {
          showModal(modalDialog(
            "files by that name exist already, nothing written",
            tags$br(),
            paste("check this location: '", getwd(), "'")
          ))
        } else {
          write.csv(generateoutput()$DF, file = fn2, row.names = FALSE, quote = FALSE)
          save(rdata, file = fn1)
          showModal(modalDialog(
            paste("two files have been written to '", getwd(), "'"),
            tags$hr(style="border-color: black;"),
            fn1,
            tags$hr(style="border-color: black;"),
            fn2,
            tags$hr(style="border-color: black;")
          ))
        }

      }
    }



  })


  TONchoices <- as.character(1:6)
  LOTchoices <- as.character(1:6)
  CAPchoices <- as.character(1:6)

  # select choices for dropdown based on group choice
  # not actually necessary, but approach maybe useful for other things later (or in a different context altogether)
  observe({
    x <- input$calibgroup
    if(input$calibgroup == "TON") {
      updateSelectInput(session, "caliblocation", label = "", choices = c("1", "2", "3", "4", "5", "6"))
    }
    if(input$calibgroup == "LOT") {
      updateSelectInput(session, "caliblocation", label = "", choices = c("1", "2", "3", "4", "5", "6"))
    }
    if(input$calibgroup == "CAP") {
      updateSelectInput(session, "caliblocation", label = "", choices = c("1", "2", "3", "4", "5", "6"))
    }
  })



  # absolute calibration data/ group's landmarks
  abscalibdata <- reactiveValues()
  abscalibdata$df <- matrix(ncol = 6, nrow = 2, dimnames = list(c("x", "y"), NULL))
  # rownames(abscalibdata$df) <- c("x", "y")
  observe({
    # abscalibdata$df <- matrix(ncol = 3, nrow = 2)
    if(input$calibgroup == "TON") colnames(abscalibdata$df) <- TONchoices
    if(input$calibgroup == "LOT") colnames(abscalibdata$df) <- LOTchoices
    if(input$calibgroup == "CAP") colnames(abscalibdata$df) <- CAPchoices

  })

  observeEvent(input$map2_click, {
    loc <- input$map2_click
    if(input$caliblocation == "1") abscalibdata$df[, 1] <- c(loc$x[1], loc$y[1])
    if(input$caliblocation == "2") abscalibdata$df[, 2] <- c(loc$x[1], loc$y[1])
    if(input$caliblocation == "3") abscalibdata$df[, 3] <- c(loc$x[1], loc$y[1])
    if(input$caliblocation == "4") abscalibdata$df[, 4] <- c(loc$x[1], loc$y[1])
    if(input$caliblocation == "5") abscalibdata$df[, 5] <- c(loc$x[1], loc$y[1])
    if(input$caliblocation == "6") abscalibdata$df[, 6] <- c(loc$x[1], loc$y[1])
  })


  output$abscalibration <- renderTable({
    abscalibdata$df[, , drop = FALSE]
  }, rownames = TRUE)

  # absolute calibration = landmarks
  output$mapimage2 <- renderPlot({
    D <- getplotdatadims()
    par(mar = c(0, 0, 0, 0))
    if(is.null(ranges$x)) {
      plot(0, 0, "n", xlim = c(1, D[2]), ylim = c(1, D[1]), asp = 1, ann = F, axes = F, xaxs = "i", yaxs = "i")
    } else {
      plot(0, 0, "n", xlim = ranges$x, ylim = ranges$y, asp = 1, ann = F, axes = F, xaxs = "i", yaxs = "i")
    }
    box()
    rasterImage(getplotdata(), xleft = 1, ybottom = 1, xright = D[2], ytop = D[1])
  })


})
