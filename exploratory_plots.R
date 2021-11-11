library(dplyr)
library(ggplot2)
library(sf)
library(tmap)
library(readr)
select <- dplyr::select


# Violin plot ==================================================================

OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")

# Add order for graphing purpose
ord.med <- OCC.NAICS %>%
  group_by(OCC_CODE) %>% summarise(med = median(H_MEAN)) %>%
  arrange(desc(med)) %>% mutate(Ord_Med = row_number()) %>% select(-med)
ord.emp <- OCC.NAICS %>%
  group_by(OCC_CODE) %>% summarise(n = sum(TOT_EMP)) %>%
  arrange(desc(n)) %>% mutate(Ord_Emp = row_number()) %>% select(-n)

OCC.NAICS.ord <- OCC.NAICS  %>%
  left_join(ord.med, by = c("OCC_CODE" = "OCC_CODE")) %>%
  left_join(ord.emp, by = c("OCC_CODE" = "OCC_CODE"))

occup.t <- OCC.NAICS.ord %>%
  group_by(OCC_CODE, OCC_TITLE) %>%
  summarise(Employment = sum(TOT_EMP),
            Median_H = median(H_MEAN),
            Range_H = max(H_MEAN) - min(H_MEAN),
            Median_A = median(A_MEAN),
            Range_A = max(A_MEAN) - min(A_MEAN)) %>%
  arrange(desc(Median_H))

occ.Lega <- OCC.NAICS %>% filter(OCC_CODE=="23-0000") %>% arrange(desc(H_MEAN))
occ.Mana <- OCC.NAICS %>% filter(OCC_CODE=="11-0000") %>% arrange(desc(H_MEAN))
occ.CM <- OCC.NAICS %>% filter(OCC_CODE=="15-0000") %>% arrange(desc(H_MEAN))
occ.En <- OCC.NAICS %>% filter(OCC_CODE=="17-0000") %>% arrange(desc(H_MEAN))
occ.Busi <- OCC.NAICS %>% filter(OCC_CODE=="13-0000") %>% arrange(desc(H_MEAN))


# Violin plot of Mean Hourly Wage
p <- ggplot(OCC.NAICS.ord,
       aes(fct_reorder(OCC_TITLE, Ord_Med, .desc = TRUE), H_MEAN)) +
  geom_violin(scale = "count", width=1.3) +
  coord_flip() +
  stat_summary(fun=median, geom="point", size=1, color="red") +
  labs(title="Hourly Wage by Occupations",
       subtitle="",
       caption="Source: U.S. BUREAU OF LABOR STATISTICS",
       x="Occupations",
       y="Mean Hourly Wage")

png(p, filename = "./figures/figure%02d.png", width = 480, height = 800, units = "px")
print(p)
dev.off()


# Spatial map =======================================================================
# Read in boundary data
zip.boundary <- st_read("./source_data/US_State/cb_2018_us_state_500k.shp",
                        quiet = TRUE) %>%
  select(STUSPS, NAME, geometry)
# Make summary data
state.d <- read_csv("./derived_data/Salary_State.csv") %>%
  group_by(PRIM_STATE) %>%
  summarise(TOT_EMP = sum(TOT_EMP), Mean_Wage = mean(H_MEAN))
# Meta data
sp.d <- zip.boundary %>% right_join(state.d, by = c("STUSPS" = "PRIM_STATE"))
sp.d <- st_make_valid(sp.d)

# Set mode
tmap_mode("view")

# Map Mean_Wage and TOT_EMP
tm_shape(sp.d) +
  tm_polygons(col = c("Mean_Wage", "TOT_EMP"),
              style = "jenks",
              palette = "YlGn") +
  tm_layout(main.title = "Mean Hourly Wage",
            main.title.position = "center",
            main.title.size = 1) +
  tm_facets(ncol = 2, sync = TRUE)
