source("load_data.R")
library(ggrepel)
library(equatiomatic)
library(pROC)
library(ggpubr)
library(modelr)
library(glue)
library(patchwork)

set.seed(0)
train_rows <- sample.int(nrow(data))[1:floor(nrow(data) * 0.70)]
train <- data[train_rows,]
test <- data[-train_rows,]

fig <- data %>% 
  ggplot(aes(AVGFACSAL, TUITIONFEE_IN)) + 
  geom_point(aes(color = HIGH_CDR), size = 0.5) +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) + 
  stat_cor(label.y.npc = 0, label.x.npc = 0.35) + 
  scale_x_continuous(labels = scales::label_dollar()) + 
  scale_y_continuous(labels = scales::label_dollar()) + 
  facet_wrap(~CONTROL) +
  labs(x = "Average Faculty Salary ($/month)", y = "Tuition and Fees") + 
  theme_bw() + 
  theme(legend.position="bottom") 

ggsave(plot = fig, filename = "fig-lr-1.png", width = 12, height = 5.5)


fig <- data %>%
  select(HIGH_CDR, UGDS, GRAD_DEBT_MDN, TUITIONFEE_IN, ADM_RATE, AVGFACSAL, PCTFLOAN, PCTPELL, RET_FT4, INEXPFTE) %>%
  pivot_longer(-HIGH_CDR) %>%
  group_by(name) %>%
  mutate(decile = cut_number(value, 10, labels=FALSE) %>% as_factor) %>%
  ggplot(aes(x=decile, fill=HIGH_CDR)) + 
  geom_bar(position = "fill", width = 1) + 
  facet_wrap(~name) + 
  scale_y_continuous(labels = scales::label_percent()) + 
  coord_cartesian(expand = FALSE) +
  labs(x = "Decile of Observed Value",
       y = "Proportion of High Default Rate") +
  theme(legend.position="bottom") 

ggsave(plot = fig, filename = "fig-lr-2.png", width = 12, height = 5.5)

fig <- data %>% 
  ggplot(aes(AVGFACSAL, INEXPFTE)) + 
  geom_point(aes(color = HIGH_CDR), size = 0.5) +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) + 
  stat_cor(label.y.npc = 1) + 
  scale_x_continuous(labels = scales::label_dollar()) + 
  scale_y_continuous(labels = scales::label_dollar(), trans = "log10") + 
  labs(x = "Average Faculty Salary ($/month)", y = "Instructional Expeditures per FT Student") + 
  theme_bw() + 
  theme(legend.position="bottom") 

ggsave(plot = fig, filename = "fig-lr-3.png", width = 12, height = 5.5)
