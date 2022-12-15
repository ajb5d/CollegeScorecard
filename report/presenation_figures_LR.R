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

model_improved <- glm(HIGH_CDR ~ CONTROL + AVGFACSAL + RET_FT4 +  HBCU + PCTPELL + GRAD_DEBT_MDN, family = binomial(), data = train)

roc_improved <- roc(HIGH_CDR ~ predict(model_improved, test), data = test, direction = "<", levels = c(FALSE, TRUE))
fmt <- scales::label_number(accuracy=0.001)

plot_txt <- " Model AUROC: {fmt(roc_improved$auc)}"

roc_data <- roc_improved %>%
    coords %>% 
    mutate(specificity = 1 - specificity) %>%
    arrange(sensitivity, specificity) %>%
    mutate(model = "Improved")

prc_data <- roc_improved %>%
    coords(ret = c("accuracy", "threshold", "precision", "recall")) %>% 
    mutate(model = "Improved")

p1 <- ggplot(roc_data) +
  geom_step(aes(specificity, sensitivity, color = model)) +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  annotate("text", x = 0.50, y = 0.1, label = glue(plot_txt)) + 
  coord_cartesian(expand = FALSE) +
  labs(x = "1 - Specificity", y = "Sensitivity", color = "Model") +
  theme_bw()

p2 <- ggplot(prc_data) +
  geom_step(aes(threshold, accuracy, color = model)) +
  scale_y_continuous(limits = c(0,1), labels = scales::label_percent()) + 
  labs(x = "Threshold (Log-odds)", y="Accuracy", color = "Model") +
  theme_bw()

fig <- (p1 + p2 + plot_layout(guides = "collect") + plot_annotation(title = "Test Set Model Performance")) & theme(legend.position="bottom")  
ggsave(plot = fig, filename = "fig-lr-4.png", width = 12, height = 5.5)
