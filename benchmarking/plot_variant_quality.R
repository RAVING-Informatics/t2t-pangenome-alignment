library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(patchwork)

setwd("/Users/00104561/Library/CloudStorage/OneDrive-UWA/Research/Projects/AIM1_DATA-REANALYSIS/t2t-realignment/benchmark/variants/cohort/")

#Functions source from "/Users/00104561/Library/CloudStorage/OneDrive-UWA/Research/Projects/AIM1_DATA-REANALYSIS/t2t-realignment/benchmark/variants/individual/parse_quality_scores.R"

# Create the DataFrame
data_lines <- readLines("./bcftools_stats_vqc (1).tsv")
assay <- c("genome", "clinvar", "exome", "mask", "genome", "null", "null", "clinvar", "exome", "mask")
df <- create_quality_dataframe(data_lines)
df_t <- as.data.frame(t(df)) 
df_t <- df_t %>%
  mutate(
    sample_id = sub("\\..*", "", rownames(df_t)),
    genome = if_else(stringr::str_detect(rownames(df_t), "chm13|T2T"), "chm13", "grch38"),
    assay = assay) %>%
  select(sample_id, genome, assay, everything())

rownames(df_t) <- NULL
df_t[df_t == 0] <- NA

masked <- df_t[df_t$assay=="mask", ]
exome <- df_t[df_t$assay=="exome", ]
genome <- df_t[df_t$assay=="genome", ]
clinvar <- df_t[df_t$assay=="clinvar", ]

#plot mask

plot_mask <- masked %>%
  pivot_longer(
    cols = 4:ncol(.),
    names_to = "quality_score",
    values_to = "value"
  )
plot_mask <- plot_mask %>%
  mutate(quality_score = as.numeric(quality_score)) # Convert to numeric

mask_plot<-ggplot(plot_mask, aes(x = quality_score, y = value, group = genome, color = genome)) +
  geom_line(size = 1) +
  labs(
    title = "Genome Mask Variants",
    x = "Quality score",
    y = "Number of variants",
    color = "Genome"
  ) +
  scale_x_continuous(
    breaks = seq(min(plot_df$quality_score, na.rm = TRUE),
                 max(plot_df$quality_score, na.rm = TRUE),
                 by = 10) # Show every 1 quality score step
  ) +
  scale_y_continuous(limits = c(0, 600000)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme_minimal() + 
  theme(legend.position = "none")

#plot exome
plot_exome <- exome %>%
  pivot_longer(
    cols = 4:ncol(.),
    names_to = "quality_score",
    values_to = "value"
  )
plot_exome <- plot_exome %>%
  mutate(quality_score = as.numeric(quality_score)) # Convert to numeric


exome_plot<-ggplot(plot_exome, aes(x = quality_score, y = value, group = genome, color = genome)) +
  geom_line(size = 1) +
  labs(
    title = "Exome Variants",
    x = "Quality score",
    y = "Number of variants",
    color = "Genome"
  ) +
  scale_x_continuous(
    breaks = seq(min(plot_df$quality_score, na.rm = TRUE),
                 max(plot_df$quality_score, na.rm = TRUE),
                 by = 10) # Show every 1 quality score step
  ) +
  scale_y_continuous(limits = c(0, 17000)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme_minimal() +
  theme(legend.position = "none")

#plot genome

plot_genome <- genome %>%
  pivot_longer(
    cols = 4:ncol(.),
    names_to = "quality_score",
    values_to = "value"
  )
plot_genome <- plot_genome %>%
  mutate(quality_score = as.numeric(quality_score)) # Convert to numeric

genome_plot<-ggplot(plot_genome, aes(x = quality_score, y = value, group = genome, color = genome)) +
  geom_line(size = 1) +
  labs(
    title = "Genome-wide Variants",
    x = "Quality score",
    y = "Number of variants",
    color = "Genome"
  ) +
  scale_x_continuous(
    breaks = seq(min(plot_df$quality_score, na.rm = TRUE),
                 max(plot_df$quality_score, na.rm = TRUE),
                 by = 10) # Show every 1 quality score step
  ) +
  scale_y_continuous(limits = c(0, 600000)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme_minimal() +
  theme(legend.position = "none")

#plot genome

plot_clinvar <- clinvar %>%
  pivot_longer(
    cols = 4:ncol(.),
    names_to = "quality_score",
    values_to = "value"
  )
plot_clinvar <- plot_clinvar %>%
  mutate(quality_score = as.numeric(quality_score)) # Convert to numeric

clinvar_plot<-ggplot(plot_clinvar, aes(x = quality_score, y = value, group = genome, color = genome)) +
  geom_line(size = 1) +
  labs(
    title = "ClinVar Variants",
    x = "Quality score",
    y = "Number of variants",
    color = "Genome"
  ) +
  scale_x_continuous(
    breaks = seq(min(plot_df$quality_score, na.rm = TRUE),
                 max(plot_df$quality_score, na.rm = TRUE),
                 by = 10) # Show every 1 quality score step
  ) +
  scale_y_continuous(limits = c(0, 7000)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme_minimal()

genome_plot + mask_plot + exome_plot + clinvar_plot + plot_layout(ncol = 2)
