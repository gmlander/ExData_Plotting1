#-- Create a temporary file to download the zip from url.
#-- Unzip the file into a .txt.
#-- Read that .txt into a dataframe (colClasses specified to avoid leading zero coercion errors).
#-- Delete the no longer necessary temp file.

temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",temp)
powerDF <- read.table(unz(temp, "household_power_consumption.txt"), sep = ";", na.strings = "?", colClasses = c("character", "character", rep("numeric", 7)), header = TRUE)
unlink(temp)

# -- Change the Date column from character to Date format. NOTE: Could have skipped this step and done the next subsetting
# -- step with the dates as characters using c("1/2/2007", "2/2/2007") but believed this a better practice (despite longer runtime)
# -- for avoiding errors due to inconsistent entry format in the original dataset.

powerDF$Date <- as.Date(powerDF$Date, format = "%d/%m/%Y")

# -- Subset the data frame for only rows of the target dates. Then delete the old data frame to save memory.

powerDFsub <- subset(powerDF, as.character(Date) %in% c("2007-02-01", "2007-02-02"))
rm("powerDF")

#-- Process the data by creating a 10th variable "datetime" from the "Date" and "Time" variables of the original data.

powerDFsub$datetime <- strptime(paste(as.character(powerDFsub$Date), powerDFsub$Time), format = "%Y-%m-%d %H:%M:%S")

# -- Construct a 2x2 plot matrix on the png device, save as "plot3.png", set plot parameters 
defaultPar <- par()
png(file="plot4.png",width= 480, height= 480)
par(mfrow = c(2,2), mar = c(3,3,3,2), xpd = NA, mgp = c(2, 0.7, 0), cex.lab = 1, cex.axis = .7)

# -- Add the global active power line graph to the top left
plot(powerDFsub$datetime, powerDFsub$Global_active_power, type = "n", xlab = "", ylab = "Global Active Power")
lines(powerDFsub$datetime, powerDFsub$Global_active_power)

# -- Add the voltage line graph to the top right
with(powerDFsub, plot(datetime, Voltage, type = "n"))
lines(powerDFsub$datetime, powerDFsub$Voltage)

# -- Add the sub metering line graph w/ borderless legend to the bottom left
plot(powerDFsub$datetime, powerDFsub$Sub_metering_1, type = "n", xlab = "", ylab = "Energy sub metering")
lines(powerDFsub$datetime, powerDFsub$Sub_metering_1, col = "black")
lines(powerDFsub$datetime, powerDFsub$Sub_metering_2, col = "orangered")
lines(powerDFsub$datetime, powerDFsub$Sub_metering_3, col = "dodgerblue2")
legend("topright", col = c("black", "orangered", "dodgerblue2"), lty = c(1,1), legend = c(names(powerDFsub)[7:9]), cex = .7, xjust = 1, bty = "n")

# -- Add the global reactive power line graph to the bottom right
with(powerDFsub, plot(datetime, Global_reactive_power, type = "n"))
lines(powerDFsub$datetime, powerDFsub$Global_reactive_power, lwd = 0.1)

dev.off()
par(defaultPar)