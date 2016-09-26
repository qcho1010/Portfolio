#require(readr)
## http://blog.rstudio.org/2015/04/09/readr-0-1-0/
## read_csv does not factorize 
## ability to import dates and date times
#
#

options(width = 160, prompt="> ", continue="  ")

tic <- function(){gc(); tic.time <<- proc.time() }
toc <- function(){t <- proc.time() - tic.time; return (unname(t["user.self"]+t["user.child"]+t["sys.self"]+t["sys.child"]))}


#tic(); violations<-read.csv("detroit-blight-violations.csv",na.strings=""); toc()
## [1] 15.6
#parse_datetime("01/01/38440 12:00:00 AM","%m/%d/%Y %H:%M:%S %.%.")
#parse_datetime("01/01/3844 12:00:00 AM","%m/%d/%Y %H:%M:%S %.%.")
#tic(); violations<-read_csv("detroit-blight-violations.csv"); toc()
## [1] 3.2   
#tic();cvars <- lapply(violations, class) == "character";violations[, cvars] <- lapply(violations[, cvars], as.factor);toc()
## [1] 4.536

crimes<-read.csv("data/detroit-crime.csv",na.strings="",stringsAsFactors = FALSE)
calls<-read.csv("data/detroit-311.csv",na.strings="",stringsAsFactors = FALSE)
violations<-read.csv("data/detroit-blight-violations.csv",na.strings="",stringsAsFactors = FALSE)
permits<-read.delim("data/detroit-demolition-permits.tsv",na.strings="",stringsAsFactors = FALSE)

options(width = 160)
options(prompt="> ", continue="  ")

################## parse lat lon

crimes$loctupel <- sub("(.*\n)?(.*\n)?(.*\n)?\\(([-0-9., ]+)\\)$","\\4",crimes$LOCATION,perl=TRUE, useBytes = TRUE)
crimes$lat <- as.double(sub("(-?[0-9.]+).*,.*","\\1",crimes$loctupel,perl=TRUE, useBytes = TRUE))
crimes$lon <- as.double(sub("(.*),( *)(-?[0-9.]+)","\\3",crimes$loctupel,perl=TRUE, useBytes = TRUE))

calls$lon<-calls$lng

permits$loctupel <- sub(".*\n.*\n(.*)","\\1",permits$site_location,perl=TRUE, useBytes = TRUE)
permits$lat <- as.double(sub("\\((-?[0-9.]+).*,.*","\\1",permits$loctupel,perl=TRUE, useBytes = TRUE))
permits$lon <- as.double(sub(".*, *(-?[0-9.]*)\\)","\\1",permits$loctupel,perl=TRUE, useBytes = TRUE))

violations$loctupel <- sub("(.*\n)?(.*\n)?(.*\n)?\\(([-0-9., ]+)\\)$","\\4",violations$ViolationAddress,perl=TRUE, useBytes = TRUE)
violations$lat <- as.double(sub("(-?[0-9.]+).*,.*","\\1",violations$loctupel,perl=TRUE, useBytes = TRUE))
violations$lon <- as.double(sub("(.*),( *)(-?[0-9.]+)","\\3",violations$loctupel,perl=TRUE, useBytes = TRUE))

################## parse amount of dollars in violations

violations$FineAmt <- as.double(gsub("\\$","",violations$FineAmt))
violations$AdminFee <- as.double(gsub("\\$","",violations$AdminFee))
violations$LateFee <- as.double(gsub("\\$","",violations$LateFee))
violations$StateFee <- as.double(gsub("\\$","",violations$StateFee))
violations$CleanUpCost <- as.double(gsub("\\$","",violations$CleanUpCost))
violations$JudgmentAmt <- as.double(gsub("\\$","",violations$JudgmentAmt))

################## parse building

crimes$building <- trimws(toupper(crimes$ADDRESS))
permits$building <- trimws(toupper(gsub("  "," ",permits$SITE_ADDRESS, fixed=TRUE, useBytes = TRUE))) # some names contain doubleblanks
violations$STNUM  <- trimws(sub(".*?([0-9]+).?","\\1",violations$ViolationStreetNumber, useBytes = TRUE)) # some numbers are negative
violations$STNAME <- trimws(gsub("  "," ",violations$ViolationStreetName, fixed=TRUE, useBytes = TRUE)) # some names contain doubleblanks
violations$building <- toupper(paste(violations$STNUM,violations$STNAME))

# calls$address is extremely diverse
# "People Mover Column At Beaubien And East Jefferson Next Door To Tom'S Oyster Bar"
getbuilding <- function(d,re,x){
	m=grep(re,d$building,ignore.case = TRUE, useBytes = TRUE)
	d[m,]$building <- sub(re,x,calls$building,ignore.case = TRUE, useBytes = TRUE)[m]
	d[m,]$parsed <- TRUE
	return(d)
}
calls$building <- trimws(toupper(as.character(calls$address)))
calls$parsed   <- FALSE
calls <- getbuilding(calls,"(.*) DETROIT.*","\\1")
calls <- getbuilding(calls,"(.*), MICHIGAN.*","\\1")
calls <- getbuilding(calls,"(.*) DET\\.,.*","\\1")
calls <- getbuilding(calls,"(.*), MI 48[12][0-9][0-9].*","\\1")
calls <- getbuilding(calls,"(.*) DET\\. 48[12][0-9][0-9].*","\\1")
calls <- getbuilding(calls,"([0-9]+ +[A-Z]+)","\\1")
calls <- getbuilding(calls,"([0-9]+)([A-Z]+)","\\1 \\2")
calls <- getbuilding(calls,"([0-9]+ +[0-9]*[A-Z]+)","\\1")
calls <- getbuilding(calls,"(.*?) 48[12][0-9][0-9]$","\\1")
# head(calls[!calls$parsed,]$building,200)
cat("WE CAN'T CATCH ALL MESSY DATA: ",nrow(calls[!calls$parsed,]),"\n")
calls[!calls$parsed,]$building <- NA


############# parse datetime

violations$year   <- as.numeric(gsub("^([0-9]+)/([0-9]+)/([0-9]+).*", "\\3",violations$TicketIssuedDT, useBytes = TRUE))
violations$dt     <- as.Date("1900-1-1")
s=violations$year>30000
violations[s,]$dt <- as.Date(violations[s,]$year,origin="1899-12-30")
s=!violations$year>30000
violations[s,]$dt <- as.Date(gsub("^([0-9]+)/([0-9]+)/([0-9]+).*", "\\3-\\1-\\2", violations[s,]$TicketIssuedDT, useBytes = TRUE))
violations <- violations[violations$year>=2000,]
# summary(violations[violations$year>30000,]$dt) # conversion is somehow reasonable
# summary(violations[violations$year<30000,]$dt)

calls$dt          <- as.Date(gsub("^([0-9]+)/([0-9]+)/([0-9]+).*$", "\\3-\\1-\\2", calls$ticket_created_date_time, useBytes = TRUE))
crimes$dt         <- as.Date(gsub("([0-9]+)/([0-9]+)/([0-9]+).*", "\\3-\\1-\\2", crimes$INCIDENTDATE, useBytes = TRUE))
permits$dt        <- as.Date(gsub("([0-9]+)/([0-9]+)/([0-9]+)", "20\\3-\\1-\\2", permits$PERMIT_APPLIED, useBytes = TRUE))

############# origin and incident

violations$origin = "detroit-blight-violations"
violations$incident = trimws(gsub("  "," ",violations$ViolDescription, fixed=TRUE, useBytes = TRUE))

calls$origin = "detroit-311"
calls$incident = calls$issue_type
crimes$origin = "detroit-crime"
crimes$incident = crimes$CATEGORY
permits$origin = "detroit-demolition-permits"
permits$incident = "Dismantle"

