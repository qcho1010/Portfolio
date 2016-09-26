require(dplyr)


########################## collect labelled and unlabelled buildings


# https://cran.r-project.org/web/packages/dplyr/vignettes/two-table.html
#    semi_join(x, y) keeps all observations in x that have a match in y.
#    anti_join(x, y) drops all observations in x that have a match in y.


# this was for submission:
#buildingsLabel1 <- permits %>% distinct(building)
#buildingsLabel0 <- rbind(crimes,calls,violations) %>% distinct(building) %>% anti_join(permits,by="building")

eps = 0.005 / 1000
buildingsLabel1 <- permitsR %>% select(building,lat,lon) %>% distinct(building)
buildingsLabel0 <- violationsR %>% 
                   filter(abs(lat-42.33168) >= eps  & abs(lon - -83.04800) >= eps) %>% 
                   select(building,lat,lon) %>%
                   distinct(building) %>% 
                   anti_join(permitsR,by="building")


buildingsLabel1$label <- 1
buildingsLabel0$label <- 0

buildingsLabel1 %>% nrow
buildingsLabel0 %>% nrow
#[1] 6355
#[1] 102660


########################## build subset of labelled buildings for modelling

set.seed(5)
nBlight <- buildingsLabel1 %>% nrow
buildingsLabel0 = buildingsLabel0 %>% sample_n(nBlight)

buildingsLabelled <- rbind(buildingsLabel1,buildingsLabel0) %>% select(building,lat,lon,label)
remove("buildingsLabel0")
remove("buildingsLabel1")
buildingsLabelled %>% nrow
buildingsLabelled %>% filter(label==1) %>% nrow
buildingsLabelled %>% filter(label==0) %>% nrow
#[1] 12710
#[1] 6355
#[1] 6355

# double check whether there are buildings with label both true and false
buildingsLabelled %>% group_by(building) %>% 
             summarise(n=n()) %>%
             select(building,n) %>% filter(n!=1) %>% nrow 
#[1] 0

write.csv(buildingsLabelled, file="data/buildingsLabelled_50_50.csv", row.names = FALSE)




###### count incidents

# TODO FIX MISUNDERSTANDIG!
# JudgmentAmt is already sum of other amounts!
#
#

incidents <- violationsR %>% 
   select(building,lat,lon,incident,FineAmt,AdminFee,LateFee,StateFee,CleanUpCost,JudgmentAmt) %>% 
   mutate(graffiti =ifelse(regexpr("grap?[hf]f?itt?[iy]",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(defective=ifelse(regexpr("defective",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(debris=ifelse(regexpr("debris",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(waste =ifelse(regexpr("waste",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(vehicle=ifelse(regexpr("vehicle",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(rodents=ifelse(regexpr("rodent",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(maintenance= ifelse(regexpr("maintain",incident,ignore.case=TRUE)>0 |
                              regexpr("mainte?nance",incident,ignore.case=TRUE)>0,1,0)) %>%
   mutate(other=ifelse(graffiti==0&defective==0&debris==0&waste==0&vehicle==0&rodents==0&maintenance==0,1,0)) %>%
   group_by(building) %>% 
   summarise(count=n(),
             graffiti=sum(graffiti),
             defective=sum(defective),
             debris=sum(debris),
             waste=sum(waste),
             vehicle=sum(vehicle),
             rodents=sum(rodents),
             maintenance=sum(maintenance),
             others=sum(other),
             CleanUpCost=sum(CleanUpCost),
             JudgmentAmt=sum(JudgmentAmt))
             
incidents <- incidents %>% arrange(desc(count)) %>% data.frame
incidents %>% head(20)

write.csv(incidents, file="data/incidents_with_keywords.csv", row.names = FALSE)

###### join labelled buildings and incidents to modeldata

modeldata <- buildingsLabelled %>% select(building,lon,lat,label)
modeldata <- modeldata %>% 
             left_join(incidents,by=c("building")) %>% 
             mutate_each(funs(replace(., which(is.na(.)), 0))) %>%
             data.frame
modeldata$ID=1:nrow(modeldata)
             
modeldata %>% nrow
#[1] 12710
modeldata[is.na(modeldata$count),]  %>% nrow
#[1] 0
modeldata[modeldata$count==0,]  %>% nrow
#[1] 3309
modeldata %>% filter(label==1) %>% nrow
#[1] 6355
modeldata %>% filter(label==0) %>% nrow
#[1] 6355
write.csv(modeldata, file="data/modeldata.csv", row.names = FALSE)

