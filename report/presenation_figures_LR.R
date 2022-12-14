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

data %>% 
  ggplot(aes(AVGFACSAL, TUITIONFEE_IN)) + 
  geom_point(aes(color = HIGH_CDR), size = 0.3) +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) + 
  stat_cor(label.y.npc = 0, label.x.npc = 0.35) + 
  scale_x_continuous(labels = scales::label_dollar()) + 
  scale_y_continuous(labels = scales::label_dollar()) + 
  facet_wrap(~CONTROL) +
  labs(x = "Average Faculty Salary ($/month)", y = "Tuition and Fees") + 
  theme_bw() + 
  theme(legend.position="bottom") 