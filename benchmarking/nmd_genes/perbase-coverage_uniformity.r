setwd("/Users/00104561/Library/CloudStorage/OneDrive-UWA/Research/Projects/AIM1_DATA-REANALYSIS/benchmark/nmd_genes/")

library(dplyr)
library(stringr)
library(ggplot2)
library(readr)
exclude <- "D21-0091"
df_hg38 <- read_tsv(paste0("./data/all.perbase_mosdepth.summary.linear_hg38.tsv"),  show_col_types = FALSE)
df_chm13 <- read_tsv(paste0("./data/all.perbase_mosdepth.summary.linear_chm13.tsv"),  show_col_types = FALSE)
df_hg38  <- df_hg38  %>% filter(sample != exclude)
df_chm13 <- df_chm13 %>% filter(sample != exclude)

df_hg38 <- df_hg38 %>%
  mutate(reference = "hg38",
         sample = str_remove(sample, "\\.hg38$"))

summary(df_hg38)

df_chm13 <- df_chm13 %>%
  mutate(reference = "chm13",
         sample = str_remove(sample, "\\.chm13$"))

summary(df_chm13)

df_combined <- bind_rows(df_hg38, df_chm13)
str(df_combined)

df_wide <- df_combined %>%
  select(gene, sample, reference, sd_depth) %>%
  tidyr::pivot_wider(
    names_from = reference,
    values_from = sd_depth
  )

df_compare <- df_wide %>%
  mutate(
    diff = chm13 - hg38,
    rel_diff = (chm13 - hg38) / hg38 * 100
  )

scatter_400<- ggplot(df_compare, aes(x = hg38, y = chm13)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "red") +
  labs(
    x = "Range depth (hg38)",
    y = "Range depth (chm13)",
    title = "Per-gene coverage range comparison: hg38 vs chm13"
  ) +
  scale_y_continuous(limits = c(0, 400)) +
  scale_x_continuous(limits = c(0, 400)) +
  theme_minimal()

pdf(paste0("./plots/range_perbase_chm13_hg38_cov_2500.pdf"), width = 6, height = 6)
scatter_400
dev.off()

scatter<- ggplot(df_compare, aes(x = hg38, y = chm13)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "red") +
  labs(
    x = "SD depth (hg38)",
    y = "SD depth (chm13)",
    title = "Per-gene coverage SD comparison: hg38 vs chm13"
  ) +
  theme_minimal()

pdf(paste0("./plots/range_perbase_chm13_hg38_cov_15000.pdf"), width = 12, height = 12)
scatter
dev.off()

df_avg <- df_combined %>%
  group_by(gene, reference) %>%
  summarise(mean_sd = mean(sd_depth, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = reference, values_from = mean_sd) %>%
  mutate(diff = chm13 - hg38)

summary(df_combined)


ggplot(df_combined, aes(x = sd_depth, fill = reference)) +
  geom_histogram(alpha = 0.5, bins = 50, position = "identity") +
  scale_fill_manual(values = c("chm13" = "#1b9e77", "hg38" = "#7570b3")) +
  labs(
    x = "SD depth",
    y = "Frequency",
    title = "Distribution of per-gene coverage SD",
    fill = "Reference"
  ) +
  theme_minimal(base_size = 13)

ggplot(df_combined, aes(x = sd_depth, colour = reference, fill = reference)) +
  geom_density(alpha = 0.25, adjust = 1) +   # adjust >1 = smoother, <1 = more detail
  labs(
    x = "SD depth",
    y = "Density",
    title = "Per-gene coverage SD: density curves"
  ) +
  theme_minimal(base_size = 13)

ggplot(df_combined, aes(x = sd_depth, fill = reference)) +
  geom_density(alpha = 0.25, adjust = 1) +
  facet_wrap(~reference, nrow = 1, scales = "fixed") +
  labs(x = "SD depth", y = "Density", title = "Per-reference density curves") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

