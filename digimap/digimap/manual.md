# Manual

The app is not pretty or overly user-friendly, but it does the job, at least as far as I am concerned. If you start the app, an example "map" will be loaded, I used this example to try out things. One thing to notice is that I pretend that the four blue crosses constitute the scale. I have no idea what the real distance between the grid lines is, so I assumed it is 5m, but this can be changed (see below).

Currently it only accepts jpeg images as data input.

If you load large jpeg images, the app may become a little slow in responding. There's probably nothing much I can do about this.

If you want to start digitizing a new map image you need to restart the app.

## Zoom

Once you selected an image (or stick with the example), you zoom in by selecting the desired area followed by a double click into the shaded area. To reset the image, just double click again somewhere into the plotting area.

## Calibration/scale

You can add calibration points, which allow returning path lengths in real distances (rather than in units of pixels). For this, click on the start point of the scale (one of the blue crosses in the example). You will see coordinates change in the table below. Then select the end point of the scale, which will add a second pair of coordinates. Then add the actual scale length into the box on the left. Once your are happy, press `submit`, and you will have added the data into the table with the calibration data. You can repeat this step for multiple scales to get a more precise measurement. You can also undo this step by clicking `delete last row`, which will delete the last calibration step.


## Path data

Once you are happy with the calibration/scale data, you can switch to the actual path data. To enable recording the path you need to click the check box `in path mode?`. Once this is checked each click on the map will be recorded in the table on the left of the map (`path data`). For convenience, the most recent point is added as the top row of the table.

If you want to indicate a *visit* of a specific location along the path, you need to select the location identifier in `choose location:` and then click `submit box visit`. This should add the identifier of the visited location next to the coordinates in the top row of the path data. Please note that the app does *not* check whether the location of a selected box makes sense with respect to the current path, i.e. you could indicate a box visit of a box that is nowhere near the path the subject is currently on.

If you misclicked you can undo the last step by clicking `delete latest row` button.

You can also display the path you are drawing by checking the `draw the path?` checkbox. The path is indicated by black arrows. Any box visits are highlighted with blue stars.

The zooming doesn't work while you are in path drawing mode. If you want to (re)zoom you first need to uncheck `in path mode?` and once you are happy with your zoom just recheck it.


## Landmarks

Here you can mark some fixed locations that could differ between different groups for absolute reference. In this panel you have to first select the group and then go through each location and click on it. Zooming doesn't work directly here but depends on the settings in the `app` panel, i.e. you need to switch between `app` and `landmarks` tab if you want to adjust the zoom for the landmarks. Also, there is no option to delete data here. If you want to redo a landmark, just select in the drop-down menu and mark it again.


## Exporting

Once you are happy with your path, landmarks and scale measures, you can export your data by pressing the `download data` button. You will first be asked for a file name. Please enter the file name without the file type. Next, two checks are performed: do you have six landmarks marked and did you measure the scale at least three times. Only if both criteria are met, the saving will take place and you will get a message to that effect. If the file you want to save already exists, you will get a warning and nothing is saved, i.e. overwriting is not possible. 

Also, in fact, two files are saved: a .csv file and an .RData file. The latter allows easier handling if you want to process data in R (but is more tricky to export to Excel for example). In any case, the content of both files is identical.

# Bugs

Currently, the exporting step will fail if the calibration data has only one row. If you have only one scale on your image, simply measure it twice or three times to avoid this error (which might be a good idea anyway). Actually, the same error will happen if you only have one row in the path table, but that should never happen because a path with one point is not a path ...

# To-do list

It would be cool to have the possibility of loading a .csv file and map it onto the existing map image.

