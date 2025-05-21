setwd("/home/suhishan/Documents/Final Sem Research/Conflict/")
library(haven)
library(tidyverse)


conflict <- read_dta("Conflict Data/conflict.dta") %>% 
  filter(year>1995 & year <2007) %>% 
  mutate(district = adm_2)


# See proportion of deaths before 1998 w.r.t to total deaths. 
pre99 <- conflict %>% group_by(district) %>% 
  filter(year<1999) %>% 
  summarize(deaths_pre99 =  sum(best_est) )

pre07 <- conflict %>% group_by(district) %>% 
  filter(year>1998 & year<2007) %>% 
  summarize(deaths_pre07 =  sum(best_est))

total <- merge(pre99, pre07, by= "district", all.y = TRUE) %>% 
  mutate(
    deaths_pre99 = ifelse(is.na(deaths_pre99), 0, deaths_pre99),
    prop_pre99 = round(deaths_pre99/deaths_pre07, 2)
  )



total %>% 
  ggplot(aes(x = prop_pre99, y = deaths_pre07))+
  geom_point(color = "navyblue", shape = 1)

summary(lm(deaths_pre07 ~ deaths_pre99, data = total))
