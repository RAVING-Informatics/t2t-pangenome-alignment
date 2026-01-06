# ==============================================================================
# Per-gene coverage variability comparison (hg38 vs chm13)
# ------------------------------------------------------------------------------
# Purpose:
#   - Read per-gene summary statistics derived from per-base mosdepth outputs
#     for two references (GRCh38/hg38 and T2T-CHM13/chm13).
#   - Exclude a specified sample.
#   - Compare per-gene SD of depth between references:
#       * Create a wide table with hg38 and chm13 side-by-side
#       * Compute absolute and relative differences (chm13 - hg38)
#   - Generate scatterplots and distribution plots (histograms/densities).
#
# Inputs (TSV):
#   ./data/all.perbase_mosdepth.summary.linear_hg38.tsv
#   ./data/all.perbase_mosdepth.summary.linear_chm13.tsv
#
# Expected key columns in each TSV:
#   - gene      : gene symbol/identifier
#   - sample    : sample name (often with ".hg38" or ".chm13" suffix)
#   - sd_depth  : standard deviation of depth (per gene, per sample)
#
# Outputs (PDF):
#   ./plots/range_perbase_chm13_hg38_cov_2500.pdf
#   ./plots/range_perbase_chm13_hg38_cov_15000.pdf
#
# Notes:
#   - This script currently creates ggplot objects for histogram/density plots
#     but does not explicitly save them. Add ggsave()/pdf() calls if desired.
# ==============================================================================

# ---------------------------- Setup / Libraries -------------------------------
setwd("/Users/00104561/Library/CloudStorage/OneDrive-UWA/Research/Projects/AIM1_DATA-REANALYSIS/benchmark/nmd_genes/")

library(dplyr)
library(stringr)
library(ggplot2)
library(readr)

# Sample to exclude from all downstream comparisons (e.g., failed QC/outlier)
exclude <- "D21-0091"

# ------------------------------- Load data ------------------------------------
# Read hg38 and chm13 per-gene summary TSVs.
# show_col_types = FALSE suppresses readr's column-type printing.
df_hg38  <- read_tsv("./data/all.perbase_mosdepth.summary.linear_hg38.tsv",  show_col_types = FALSE)
df_chm13 <- read_tsv("./data/all.perbase_mosdepth.summary.linear_chm13.tsv", show_col_types = FALSE)

# Exclude the specified sample from both references
df_hg38  <- df_hg38  %>% filter(sample != exclude)
df_chm13 <- df_chm13 %>% filter(sample != exclude)

# ---------------------------- Basic cleaning ----------------------------------
# Add reference label and remove suffix from sample names (so both references
# share the same sample IDs when we pivot_wider()).
df_hg38 <- df_hg38 %>%
  mutate(
    reference = "hg38",
    sample    = str_remove(sample, "\\.hg38$")
  )
summary(df_hg38)

df_chm13 <- df_chm13 %>%
  mutate(
    reference = "chm13",
    sample    = str_remove(sample, "\\.chm13$")
  )
summary(df_chm13)

# Combine into one long-format table with a 'reference' column
df_combined <- bind_rows(df_hg38, df_chm13)
str(df_combined)

# --------------------- Reference-to-reference comparison ----------------------
# Pivot to wide format so each (gene, sample) row has both hg38 and chm13 values.
# This enables direct per-gene per-sample comparisons.
df_wide <- df_combined %>%
  select(gene, sample, reference, sd_depth) %>%
  tidyr::pivot_wider(
    names_from  = reference,
    values_from = sd_depth
  )

# Compute absolute difference and % relative difference vs hg38.
# NOTE: If hg38 == 0, rel_diff will be Inf/NaN; handle if needed.
df_compare <- df_wide %>%
  mutate(
    diff     = chm13 - hg38,
    rel_diff = (chm13 - hg38) / hg38 * 100
  )

# ------------------------------ Scatter plots --------------------------------
# Scatterplot with axes limited to 0..400 (useful to zoom into the bulk).
# NOTE: Labels/title currently mention "Range depth" (might be a carry-over).
scatter_400 <- ggplot(df_compare, aes(x = hg38, y = chm13)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "red") +
  labs(
    x = "SD depth (hg38)",
    y = "SD depth (chm13)",
    title = "Per-gene coverage range comparison: hg38 vs chm13"
  ) +
  scale_y_continuous(limits = c(0, 400)) +
  scale_x_continuous(limits = c(0, 400)) +
  theme_minimal()

# Save the zoomed scatter plot
pdf("./plots/SD_perbase_chm13_hg38_cov_2500.pdf", width = 6, height = 6)
scatter_400
dev.off()

# Full-range scatterplot (no axis limits)
scatter <- ggplot(df_compare, aes(x = hg38, y = chm13)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "red") +
  labs(
    x = "SD depth (hg38)",
    y = "SD depth (chm13)",
    title = "Per-gene coverage SD comparison: hg38 vs chm13"
  ) +
  theme_minimal()

# Save the full-range scatter plot (larger canvas for readability)
pdf("./plots/SD_perbase_chm13_hg38_cov_15000.pdf", width = 12, height = 12)
scatter
dev.off()

# ---------------------- Gene-level averages across samples --------------------
# Average SD per gene within each reference (across all remaining samples),
# then pivot wide and compute chm13-hg38 difference at the gene level.
df_avg <- df_combined %>%
  group_by(gene, reference) %>%
  summarise(mean_sd = mean(sd_depth, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = reference, values_from = mean_sd) %>%
  mutate(diff = chm13 - hg38)

summary(df_combined)

# ------------------------ Distribution visualisations -------------------------
# Histogram overlay of sd_depth by reference.
# NOTE: This plot is not saved unless you add ggsave() or wrap in pdf().
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

# Density curves overlay (outline + fill) for sd_depth by reference.
ggplot(df_combined, aes(x = sd_depth, colour = reference, fill = reference)) +
  geom_density(alpha = 0.25, adjust = 1) +   # adjust >1 = smoother, <1 = more detail
  labs(
    x = "SD depth",
    y = "Density",
    title = "Per-gene coverage SD: density curves"
  ) +
  theme_minimal(base_size = 13)

# Faceted density curves: one panel per reference.
ggplot(df_combined, aes(x = sd_depth, fill = reference)) +
  geom_density(alpha = 0.25, adjust = 1) +
  facet_wrap(~reference, nrow = 1, scales = "fixed") +
  labs(x = "SD depth", y = "Density", title = "Per-reference density curves") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

