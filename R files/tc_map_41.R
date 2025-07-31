districts <- st_read("../Nepal Shapfiles GADM/gadm36_NPL_3.shp") 

districts <- districts %>% 
  mutate(NAME_3 = tolower(NAME_3)) #district names to lowercase for merging.

c_small <- c_small %>% 
  mutate(distname = tolower(distname))


# merge the two:

districts_joined <- right_join(
  districts, c_small, by = c("NAME_3" = "distname")
)

districts_joined$treatment_s <- factor(districts_joined$treatment_s, 
                                levels = c(1, 0), 
                                labels = c("Treatment E[CDP] = 11.3",
                                           "Control E[CDP] = 3.01"))

# Now let's draw the map.

p1 <- ggplot(districts_joined) +
  geom_sf(aes(fill = treatment_s), size = 0.2) +
  labs(
    title = "Geographical classification of treatment status",
    subtitle = "Treatment Status determined conflict deaths per 10,000 people > 75th percentile",
    caption = "UCDP\n Only those districts with 0 CDP by the end of 1998 A.D.\n CDP : Conflict Deaths per 10,000 peopl (2001 Census Nepal)",
    fill = "Treatment Status"
  ) +
  scale_fill_manual(
   values = c("Treatment E[CDP] = 11.3" = "#EB212E",
               "Control E[CDP] = 3.01" = "pink"),
    name = "Treatment Status"
  )


ggsave("../Second Draft/tc_map_41.jpg", plot = p1, units = c("cm"), 
       bg = "white", height = 20, width = 30)
