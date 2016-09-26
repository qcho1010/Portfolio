
# aggregate is not able to calculate several aggregations in parallel easily
permitsAGG = permits %>% group_by(building) %>% 
             summarise(n=n(),south=min(lat),north=max(lat),west=min(lon),east=max(lon)) %>%
             select(building,n,north,south,west,east) %>% mutate(size=(north-south)*(east-west))

crimesAGG  = crimes %>% group_by(building) %>% 
             summarise(n=n(),south=min(lat),north=max(lat),west=min(lon),east=max(lon)) %>%
             select(building,n,north,south,west,east) %>% mutate(size=(north-south)*(east-west))

callsAGG   = calls %>% group_by(building) %>% 
             summarise(n=n(),south=min(lat),north=max(lat),west=min(lon),east=max(lon)) %>%
             select(building,n,north,south,west,east) %>% mutate(size=(north-south)*(east-west))

violationsAGG = violations %>% group_by(building) %>% 
             summarise(n=n(),south=min(lat),north=max(lat),west=min(lon),east=max(lon)) %>%
             select(building,n,north,south,west,east) %>% mutate(size=(north-south)*(east-west))

callsAGG      %>% nrow 
violationsAGG %>% nrow 
crimesAGG     %>% nrow 
permitsAGG    %>% nrow 
#[1] 17502
#[1] 110899
#[1] 57042
#[1] 6355


callsAGG %>% filter(n>1) %>% nrow 
violationsAGG %>% filter(n>1) %>% nrow 
crimesAGG %>% filter(n>1) %>% nrow 
permitsAGG %>% filter(n>1) %>% nrow 
# [1] 1472 buildings with more than one call
# [1] 66135 buildings with more than one violation
# [1] 19606 buildings with more than one crime
# [1] 687 buildings with multiple permits 

callsAGG %>% filter((north-south)>0 | (east-west)>0) %>% nrow 
violationsAGG %>% filter((north-south)>0 | (east-west)>0) %>% nrow 
crimesAGG %>% filter((north-south)>0 | (east-west)>0) %>% nrow 
permitsAGG %>% filter((north-south)>0 | (east-west)>0) %>% nrow 
# [1] 574 of them differ in coords
# [1] 0 of them differ in coords
# [1] 19324 of them differ in coords
# [1] 13 of them differ in coords

# differ in both coordinates:
callsAGG %>% filter(size>0) %>% nrow 
violationsAGG %>% filter(size>0) %>% nrow 
crimesAGG %>% filter(size>0) %>% nrow 
permitsAGG %>% filter(size>0) %>% nrow 
# [1] 546
# [1] 0
# [1] 16866
# [1] 13

# differ in just one coordinate:
callsAGG %>% filter(((north-south)>0 & (east==west)) | ((east-west)>0  & (north==south))) %>% nrow 
violationsAGG %>% filter(((north-south)>0 & (east==west)) | ((east-west)>0  & (north==south))) %>% nrow 
crimesAGG %>% filter(((north-south)>0 & (east==west)) | ((east-west)>0  & (north==south))) %>% nrow 
permitsAGG %>% filter(((north-south)>0 & (east==west)) | ((east-west)>0  & (north==south))) %>% nrow 
# [1] 28
# [1] 0
# [1] 2458
# [1] 0
