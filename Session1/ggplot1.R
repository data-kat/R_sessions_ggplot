
#*************************************************************************
#*************************************************************************
#                  ** GGPLOT SESSION 1 (28 AUGUST 2019) **            ####
#*************************************************************************
#*************************************************************************


# If you are not working in a version control R Studio Project,
#  You will need to use setwd() to specify your working directory
#   Note: you will need to use forward slashes instead of backslashes (Wibdows default),
#   and remove the "#" at teh beginning of the line
#setwd("C:\Users\OneDrive - scion\Documents\1 - Workspace\R_sessions\R_session_ggplot1")


if(!require(ggplot2)){install.packages("ggplot2")}
if(!require(reshape2)){install.packages("reshape2")}
if(!require(dplyr)){install.packages("dplyr")} # part of tidyverse
if(!require(magrittr)){install.packages("magrittr")} # part of tidyverse
if(!require(gridExtra)){install.packages("gridExtra")}
if(!require(grid)){install.packages("grid")}

library(ggplot2)
library(reshape2)
library(dplyr) # part of tidyverse
library(magrittr) # part of tidyverse
library(gridExtra)
library(grid)


# Set a desired ggplot theme:
theme_set(theme_classic())




## Function to extract legend
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}





#$$$$$$$ R Studio tips: #$$$$$$$$$$

# To navigate headers in this script, clip at the two little up/down arrows in
#   the bottom-left corner of this text editor window
# A heading gets generated when there's 4 or more "#" at the end of the line.
# If there's no text, the heading is blank. So to simply separate out sections,
#   I generally use one "#" and some other symbol to avoid getting a blank heading
# To search and/or replace something, use Ctrl+F to bring up the search bar at the top


#$$$$$$$ Writing tips: #$$$$$$$$$$

# Keep lines short - avoid horizontal scrolling to save time
# Column names are in CAPS (personal preference)
# Use spaces as you would in the English language - after commas, on either side of "=", etc.
# Leave lots of little comments - you may not remember certain details 6 months from now




#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
######################  GGPLOT BASICS ####################
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


testdata = data.frame(my_x = c(1,2), my_y = c(20, 10))
testdata

# ggplot() takes from zero to 2 arguments in this order: data and mapping
ggplot(data = testdata, aes(x = my_x , y = my_y)) +
    geom_point() +
    geom_line()

# If you get the order wrong, ggplot will throw an error:
ggplot(aes(x = my_x , y = my_y), testdata) +
    geom_point() +
    geom_line()

# can remedy this by specifying the name of each argument:
ggplot(mapping = aes(x = my_x , y = my_y), data = testdata) +
    geom_point() +
    geom_line()

# You cannot omit the mapping/aes() argument, as it's needed for ggplot to know
#   where the points/line are to be drawn
ggplot(data = testdata) +
    geom_point() +
    geom_line()

# However, you can omit data argument, as long as you give the exact x an y coordinates
#   in the aes() call:
ggplot(mapping = aes(x = testdata$my_x, y = testdata$my_y)) +
    geom_point() +
    geom_line()

# You don't even need to refer to any dataframe at all,
#   as long as x and y gets the same number of entries:
ggplot(mapping = aes(x = c(1, 2), y = c(10, 20))) +
    geom_point() +
    geom_line()


# Data and mapping can be specified in ggplot() AND/OR geom_line (and other geoms).
# The order of these two arguments are reversed in the geoms, but ggplot will
#   remind you if you forget :)
# Of course you can specify the names of the arguments if there's a particular order
#   that you want to follow

ggplot() +
    geom_point(aes(x = my_x , y = my_y), testdata) +
    geom_line(aes(x = my_x , y = my_y), testdata)

# Usually the easiest way is to specify things that do not change between multiple
#   geoms in ggplot() call, and changeable things in individual geom_...() calls



# You can also get creative :)
ggplot() +
    geom_point(aes(x = c(2, 3), y = c(3, 3)), size = 2) +
    geom_point(aes(x = c(2, 3), y = c(3, 3)), size = 4.5, alpha = 0.4) +
    geom_curve(aes(x = 1.5, y = 2, xend = 3.5, yend = 2), curvature = 0.7) +
    geom_segment(aes(x = 1.8, y = 3.1, xend = 2.1, yend = 3.3)) +
    geom_segment(aes(x = 2.9, y = 3.3, xend = 3.2, yend = 3.1)) +
    lims(x = c(1, 4), y = c(1, 4)) +
    coord_fixed(ratio = 1) +
    geom_point(aes(x = 2.5, y = 2.25), shape = 25)




#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
######################      PLOTTING REAL DATA      ####################
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

####--------------   _IMPORTING AND PREPPING REAL DATA  ------------####


# Plotting weather data

# Read in the weather data file
wx_all = read.csv("Athol_wx.csv", skip = 1)

# Check structure of the DATETIME column:
str(wx_all$DATETIME)


# Create a NEWDATETIME column, which is the same as DATETIME,
#   but in proper datetime format
wx_all$NEWDATETIME = as.POSIXct(wx_all$DATETIME, format = "%d/%m/%Y %H:%M")

# Ensure that the NEWDATETIME has the same values as DATETIME.
#   Then delete the DATETIME COLUMN:
wx_all = within(wx_all, rm(DATETIME))

# Rename NEWDATETIME to DATETIME:
names(wx_all)[names(wx_all) == "NEWDATETIME"] <- "DATETIME"

# Now that DATETIME is in POSIXct format, can use "<" and ">" and plot it more easily.

# Subset the dataframe to only retain 2018 weather:
wx_jan18 = wx_all[wx_all$DATETIME >= as.POSIXct("2018-01-01 00:00:00") &
                wx_all$DATETIME < as.POSIXct("2018-02-01 00:00:00"), ]


# Add some new columns to the wx_all dataset to be used later

wx_all$YEAR = substr(wx_all$DATETIME, 1, 4) # extract from 1st to 4th character
wx_all$MONTH = substr(wx_all$DATETIME, 6, 7) # extract from 6th to 7th character
wx_all$DAY = substr(wx_all$DATETIME, 9, 10) # extract from 9th to 10th character

# Convert month number to month abbreviation
wx_all$MONTH_ABB = factor(month.abb[as.numeric(wx_all$MONTH)], levels = month.abb)

# Create a new date column hwere you substitute the year with "0000"
#   The result is still in datetime format, but year has no effect
#   -> can plot multiple years together
wx_all$MONTH_DAY = as.POSIXct(gsub("\\d{4}", "0000", wx_all$DATETIME))



####--------------------   _LINE PLOTS  --------------------####


# Can create a basic plot of temperature over time:
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP)) +
    geom_line()

# To plot multiple variables this way, would need to specify x and y
#   within the aesthetic separately for every line:
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP), color = "green") +
    geom_line(aes(x = DATETIME, y = RH), color = "red")

# But how do we insert a legend? Include color in the aes() command!
#   Note: when inside aes(), you cannot specify the actual color of the line,
#         but only the NAME associated with that color in the legend
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP, color = "green")) +
    geom_line(aes(x = DATETIME, y = RH, color = "red"))


# So it's better to use meaningful names:
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP, color = "temp")) +
    geom_line(aes(x = DATETIME, y = RH, color = "RH"))

# Want to have control over actual colors of each variable?
#   -> use scale_color manual().
# Bonus: it also allows us to change legend lables if needed
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP, color = "temp")) +
    geom_line(aes(x = DATETIME, y = RH, color = "RH")) +
    scale_color_manual(values = c("orange", "blue"), labels = c("RH (%)", "Temp (°C)"))
# Note1: to get the ° symbol, hold down ALT and press 248 on the number pad of the keyboard

# Want to change the position of the legend?
# Basic options include "top", "bottom", "right", "left", "none"
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP, color = "temp")) +
    geom_line(aes(x = DATETIME, y = RH, color = "RH")) +
    scale_color_manual(values = c("orange", "blue"), labels = c("RH (%)", "Temp (°C)")) +
    theme(legend.position = "bottom")

# Note1: change the name of the COLOR legend with:
#    + labs(color = "Your custom name")
# Note2: remove the legend title with:
#   + theme(legend.title = element_blank())

# Try it here!






# labs() allows us to change x-axis and y-axis labels, title, subtitle,
#   and title of any legend you may have
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP, color = "temp")) +
    geom_line(aes(x = DATETIME, y = RH, color = "RH")) +
    scale_color_manual(values = c("orange", "blue"), labels = c("RH (%)", "Temp (°C)")) +
    theme(legend.position = "bottom") +
    labs(color = "Variables: ", title = "My title", subtitle = "My subtitle", x = "Date", y = "Value")


# Can customize other stuff aside from color: line type, line width, transparency
ggplot(wx_jan18) +
    geom_line(aes(x = DATETIME, y = TEMP),
              color = "blue", linetype = 6, alpha = 0.5, lwd = 1.5)

# Look at the "Linetypes and point shapes.png" for linetypes



####--------------------   _POINT PLOTS  --------------------####


# SHAPES, COLOR AND FILL

# show help document with point hapes, line widths, colors, etc.

# While lines only have color, points can have color and/or fill:
ggplot() +
    geom_point(aes(x = 1, y = 1), shape = 1, size = 7, color = "blue", fill = "orange") +
    geom_point(aes(x = 2, y = 1), shape = 19, size = 7, color = "blue", fill = "orange") +
    geom_point(aes(x = 3, y = 1), shape = 21, size = 7, color = "blue", fill = "orange")
# Note that these different shapes react to color and fill arguments differntly


# By default geom_point uses shape = 19
ggplot(wx_jan18) +
    geom_point(aes(x = DATETIME, y = TEMP), color = "red")

# Look at the "Linetypes and point shapes.png" for point shapes



# Challenge:
# Try using different shapes, sizes and colors here



# ADDING A TRENDLINE

# Note that if aesthethics are recycled, it's more efficient to place all aes() info
#   into the main ggplot() call

# Default:
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP)) +
    geom_point() +
    geom_smooth()

# Trend line:
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP)) +
    geom_point() +
    geom_smooth(method = "lm", se = F)




#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
######################  CUSTOM THEMES ####################
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# If you don't like the default look of ggplot graphs - not a problem!
# We can customize EVERYTHING


# Easy shortcut to change the look is by using pre-built themes
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP, color = RH)) +
    geom_point() +
    labs(title = "Title", x = "X label", y ="Y label") +
    theme_bw()


# Note: theme_grey is the default

# Challenge:
# Try using theme_linedraw(), theme_light(), theme_dark(), theme_minimal(),
#   theme_classic(), theme_void(), and theme_test()


# You can also make small changes in the individual plots.
# See https://ggplot2.tidyverse.org/reference/theme.html for all options.
#   There are a lot...
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP, color = RH)) +
    geom_point() +
    labs(title = "Title", x = "X label", y ="Y label") +
    theme(panel.background=element_rect(colour=NA,fill = "ivory2"),
          axis.text = element_text(color = "blue"),
          axis.title=element_text(size = 12, color = "red"),
          legend.background = element_rect("goldenrod"),
          panel.grid.major = element_line(color = "black"),
          panel.grid.minor = element_line(color = "grey60"))





# You can also modify your ggplot theme once, and it will apply to all plots in
#   the current R Studio session
# This is my custom theme:

old_theme = theme_update(
  panel.background=element_rect(colour=NA,fill = "white"),
  axis.line = element_line(colour = "black"),
  axis.text = element_text(size = 14),
  axis.title=element_text(size = 16),
  axis.title.x = element_text(margin = margin(t = 7)),
  axis.title.y = element_text(margin = margin(r = 10)),
  plot.title = element_text(size=20, margin = margin(t = 3, b = 20)),
  legend.text=element_text(size = 14),
  legend.title=element_text(size = 14),
  text = element_text(size = 20),
  legend.key = element_rect(fill = "white"),
  legend.background = element_rect(fill = NA),
  legend.position = "right",
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank())


# Check out the new theme at work:
ggplot(wx_jan18, aes(x = DATETIME, y = TEMP, color = RH)) +
    geom_point() +
    labs(title = "Title", x = "X label", y ="Y label")


# Now, reset the theme by setting it to theme_grey (as it was originally):
theme_set(theme_grey())

ggplot(wx_jan18, aes(x = DATETIME, y = TEMP, color = RH)) +
    geom_point() +
    labs(title = "Title", x = "X label", y ="Y label")

# Note: can set it to any of the complete themes that come with ggplot



# Challenge:
# Create your own custom theme by modifying the one above and adding to it from
#   the list of elements at https://ggplot2.tidyverse.org/reference/theme.html











#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
######################  PLOT MULTIPLE VARIABLES ####################
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# If you want to have multiple of the same geom for multiple variables,
#   can do it the long way:

ggplot(wx_jan18, aes(x = DATETIME)) +
    geom_line(aes(y = TEMP, color = "Temp")) +
    geom_line(aes(y = RH, color = "RH")) +
    geom_line(aes(y = WD, color = "WD")) +
    geom_line(aes(y = WS, color = "WS")) +
    geom_line(aes(y = PRECIP, color = "PRECIP"))


# Or, we can "melt" the dataset: reshape it from wide to long format, and group
#   multiple variables of interest into a "variable" column, and their values into
#   the "value" column:

wx_jan18_melt = melt(wx_jan18, id.vars = c("DATETIME"))

# This allows us to plot multiple variables all at once (more space-efficient)
ggplot(wx_jan18_melt, aes(x = DATETIME, y = value, color = variable)) +
    geom_line()



# Challenge:
# Draw WD with points, precip with columns, and the rest with lines
#   hint: it's easier using the non-melted data







# Solution:
# melted data:
ggplot(wx_jan18_melt[wx_jan18_melt$variable %in% c("TEMP", "RH", "WS"), ],
       aes(x = DATETIME, y = value,
             color = variable, fill = variable)) +
    geom_line() +
    geom_col(data = wx_jan18_melt[wx_jan18_melt$variable %in% c("PRECIP"), ]) +
    geom_point(data = wx_jan18_melt[wx_jan18_melt$variable %in% c("WD"), ])

# non-melted data:
ggplot(data = wx_jan18, aes(x = DATETIME)) +
    geom_line(aes(y = TEMP, color = "Temp")) +
    geom_line(aes(y = RH, color = "RH")) +
    geom_line(aes(y = WS, color = "Wind speed")) +
    geom_point(aes(y = WD, color = "Wind dir")) +
    geom_col(aes(y = PRECIP, fill = "Precip")) +
    labs(fill = "") +
    guides(color = guide_legend(order = 1), fill = guide_legend(order = 2)) +
    theme(legend.spacing.y = unit(0, 'cm'))




# The legend doesn't look right... To fix it, need to do some creative stuff
#   - remove the fill legend by using show.legend = F in geom_col()
#   - create a dummy geom_point for "Precip" with a point size of -Inf (makes it invisible)
#   - overrride the linetype, shape and size of the legend element susing override.aes

ggplot(data = wx_jan18, aes(x = DATETIME)) +
    geom_line(aes(y = TEMP, color = "Temp")) +
    geom_line(aes(y = RH, color = "RH")) +
    geom_line(aes(y = WS, color = "Wind speed")) +
    geom_point(aes(y = WD, color = "Wind dir")) +
    geom_col(aes(y = PRECIP, fill = "Precip"), show.legend = F) +
    geom_point(aes(y = PRECIP, color = "Precip"), size = -Inf) +
    guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 1, NA, 1),
                                                    shape = c(NA, NA, NA, 19, NA),
                                                    size = c(6, 0.7, 0.7, 1.6, 0.7))))


# Can also reorder legend elements using scale_color_discrete(breaks = ...)
#   but note that we'll need to redo the order in override.aes!
ggplot(data = wx_jan18, aes(x = DATETIME)) +
    geom_line(aes(y = TEMP, color = "Temp")) +
    geom_line(aes(y = RH, color = "RH")) +
    geom_line(aes(y = WS, color = "Wind speed")) +
    geom_point(aes(y = WD, color = "Wind dir")) +
    geom_col(aes(y = PRECIP, fill = "Precip"), show.legend = F) +
    geom_point(aes(y = PRECIP, color = "Precip"), size = -Inf) +
    guides(color = guide_legend(override.aes = list(linetype = c(1, 1, 1, NA, 1),
                                                    shape = c(NA, NA, NA, 19, NA),
                                                    size = c(0.7, 0.7, 0.7, 1.6, 6)))) +
    scale_color_discrete(breaks = c("Temp", "RH", "Wind speed", "Wind dir", "Precip"))
    

# Challenge:
#   - Add plot title, change x axis label, y axis label, legend label.
#   - Change color scheme
#   - Place legend on top or bottom








# Challenge:
# Make the same plot, but for February 2018
# Hint: refer to the end of PRE-PROCESSING WEATHER DATA section,
#   and use square brackets to subset the wx_all dataset













