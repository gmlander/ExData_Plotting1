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

# -- Construct a line graph of global active power on the png device, save as "plot2.png" 
png(file="plot2.png",width= 480, height= 480)
plot(powerDFsub$datetime, powerDFsub$Global_active_power, type = "n", xlab = "", ylab = "Global Active Power (kilowatts)")
lines(powerDFsub$datetime, powerDFsub$Global_active_power)
dev.off()