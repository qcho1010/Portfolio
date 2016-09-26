options(width = 160)

calls$count=1
counts=rowsum(calls$count,group=calls$incident) # produces a list with attributes
counts=aggregate(calls$count,by=list(calls$incident),sum) # <- dataframe with columns "Group.1" and "x"
counts=aggregate(calls$count,by=list(calls$incident),sum) # correct dataframe
calls$count=NULL

# http://stackoverflow.com/a/17737308
calls$count=1
counts=aggregate(count ~ incident, calls, FUN = sum, na.rm=TRUE, na.action = na.pass)
head(counts[order(counts$count,decreasing=TRUE),],n=20)
calls$count=NULL

crimes$count=1
counts=aggregate(count ~ incident, crimes, FUN = sum, na.rm=TRUE, na.action = na.pass)
head(counts[order(counts$count,decreasing=TRUE),],n=20)
crimes$count=NULL

violations$count=1
counts=aggregate(count ~ incident, violations, FUN = sum, na.rm=TRUE, na.action = na.pass)
counts$incident=strtrim(counts$incident,120)
head(counts[order(counts$count,decreasing=TRUE),],n=20)
violations$count=NULL

require(dplyr)
# incidents with both violation categories
violations %>% group_by(incident, ViolationCategory) %>% 
   summarise(n=n()) %>% 
   group_by(incident) %>% 
   summarise(c=n()) %>% 
   filter(c>1) %>% 
   select(incident, c) %>% 
   data.frame
# => ViolationCategory is useless

incidentsTAB <- violations %>% group_by(ViolDescription) %>% 
   summarise(n=n()) %>% 
   select(n, ViolDescription) %>% 
   data.frame
nrow(incidentsTAB)
# [1] 298 
# => 298 different descriptions, some of them very similar
# some just differ in double blanks
# => preparation step added

incidentsTAB <- violations %>% group_by(incident) %>% 
   summarise(n=n()) %>% 
   select(n, incident) %>% 
   mutate(graffiti =regexpr("grap?[hf]f?itt?[iy]",incident,ignore.case=TRUE)>0) %>%
   mutate(defective=regexpr("defective",incident,ignore.case=TRUE)>0) %>%
   mutate(waste =regexpr("waste",incident,ignore.case=TRUE)>0) %>%
   mutate(debris=regexpr("debris",incident,ignore.case=TRUE)>0) %>%
   mutate(vehicle=regexpr("vehicle",incident,ignore.case=TRUE)>0) %>%
   mutate(rodents=regexpr("rodent",incident,ignore.case=TRUE)>0) %>%
   mutate(maintenance= regexpr("maintain",incident,ignore.case=TRUE)>0 |
                       regexpr("mainte?nance",incident,ignore.case=TRUE)>0)
nrow(incidentsTAB)
# [1] 289
incidentsTAB %>% mutate(incident=strtrim(incident,60)) %>% data.frame


permits$count=1
counts=aggregate(count ~ incident, permits, FUN = sum, na.rm=FALSE, na.action = na.pass)
head(counts[order(counts$count,decreasing=TRUE),],n=20)
permits$count=1
counts=aggregate(count ~ DESCRIPTION, permits, FUN = sum, na.rm=FALSE, na.action = na.pass)
head(counts[order(counts$count,decreasing=TRUE),],n=50)  # 43 differnet uses. well sorted
permits$count=1
counts=aggregate(count ~ LEGAL_USE, permits, FUN = sum, na.rm=FALSE, na.action = na.pass)
head(counts[order(counts$count,decreasing=TRUE),],n=20)
permits$count=NULL
