library(dplyr)
library(forcats)
library(ggplot2)
library(ggrepel)
library(sf)
library(tmap)
library(readr)
library(stringr)
select <- dplyr::select


# Violin plot =========================================================================

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

png(p, filename = "./figures/figure01.png", width = 500, height = 850, units = "px")
print(p)
dev.off()


# Spatial map ========================================================================

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


# Employment vs Hourly Wage ==========================================================

d.state <- read_csv("./derived_data/Salary_State.csv")

d.state.all <- d.state %>% filter(OCC_TITLE == "All")
plot.d <- d.state.all %>% select(PRIM_STATE, TOT_EMP, H_MEAN, A_MEAN) %>%
  arrange(H_MEAN)

png(p, filename = "./figures/figure03.png", width = 900, height = 700, units = "px")

ggplot(data = plot.d) +
  aes(x=TOT_EMP, y=H_MEAN, size=TOT_EMP) + geom_point(alpha=0.5, col='blue') +
  geom_label_repel(aes(label = PRIM_STATE),
                   box.padding   = 0.35,
                   point.padding = 0.2,
                   segment.color = 'grey50') +
  xlab("Total Employment") +
  ylab("Mean Hourly Wage") +
  ggtitle("Total Employment and Mean Hourly Wage by State") +
  theme_classic()

dev.off()


# with Automation data ===============================================================
auto.d <- read_csv("./source_data/Automation_by_state.csv")

# Group SOC by major group, sum probability as score, order by score
score_table <- auto.d %>% filter(str_detect(SOC, "-")) %>%
  mutate(group = substr(SOC, 1,2)) %>%
  group_by(group) %>% summarise(tot_score = sum(Probability)) %>%
  arrange(desc(tot_score))

# from Salary data group by OCC
salary_table <- OCC.NAICS %>% mutate(SOC = str_sub(OCC_CODE, 1, 2)) %>%
  group_by(SOC, OCC_TITLE) %>% summarise(emp = sum(TOT_EMP),
                              hourly = mean(H_MEAN), annually = mean(A_MEAN))

# Join two tables
d <- inner_join(score_table, salary_table, by = c("group" = "SOC"))
## Add this table to report.

# Plot correlations
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  Cor <- abs(cor(x, y)) # Remove abs function if desired
  txt <- paste0(prefix, format(c(Cor, 0.123456789), digits = digits)[1])
  if(missing(cex.cor)) {
    cex.cor <- 0.4 / strwidth(txt)
  }
  text(0.5, 0.5, txt,
       cex = 1 + cex.cor * Cor) # Resize the text by level of correlation
}

# Plotting the correlation matrix
d.plot <- d %>% mutate(log_score = log(tot_score)) %>%
  select(log_score, emp, hourly, annually)

png(filename = "./figures/figure04.png", width = 600, height = 600, units = "px")
pairs(d.plot,
      upper.panel = panel.cor,    # Correlation panel
      lower.panel = panel.smooth) # Smoothed regression lines
dev.off()


model <- lm(log_score ~ emp + hourly + annually, data = d.plot)
summary(model)
# there is little association between automation probability and salary
# correlation of 1 between hourly wage and annually wage validates our data

# Plot table
png(p, filename = "./figures/figure05.png", width = 800, height = 600, units = "px")

ggplot(data = d) +
  aes(x=tot_score, y=hourly, size=emp) + geom_point(alpha=0.5, col='blue') +
  geom_label_repel(aes(label = OCC_TITLE),
                   box.padding   = 0.35,
                   point.padding = 0.2,
                   segment.color = 'grey50') +
  xlab("Automation Score") +
  ylab("Mean Hourly Wage") +
  ggtitle("Automation Score and Mean Hourly Wage by Occupation") +
  theme_classic()

dev.off()

