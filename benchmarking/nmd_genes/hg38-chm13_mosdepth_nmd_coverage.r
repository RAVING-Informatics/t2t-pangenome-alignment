
setwd("~/Library/CloudStorage/OneDrive-UWA/Research/Projects/AIM1_DATA-REANALYSIS/benchmark/nmd_genes")
#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(tidyr)
  library(purrr)
  library(forcats)
  library(ggplot2)
})

# ------------------------------- Config ---------------------------------------
# Input files
path_chm13 <- "./data/mosdepth_nmd.chm13.linear.merged.tsv"
path_hg38  <- "./data/mosdepth_nmd.grch38.linear.merged.tsv"

# Output directory (created if missing)
out_dir <- "plots"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Samples to exclude (by column name); extend as needed
exclude_samples <- c("D21-0091")

# How many genes to show in “top-N” plots
top_n <- 20

# Manual fill colors for reference
ref_colors <- c(hg38 = "#cc99ff", chm13 = "#ff4d94")

# ---------------------------- Helper Functions --------------------------------
assert_readable <- function(p) {
  if (!file.exists(p)) stop("File not found: ", p, call. = FALSE)
}

# Collapse to one row per gene using an unweighted mean across intervals
collapse_gene_simple <- function(df,
                                 key_cols = c("chr", "start", "end", "size", "gene"),
                                 exclude = character()) {
  stopifnot("gene" %in% names(df))

  # Identify sample columns (exclude non-sample + explicitly excluded)
  sample_cols <- setdiff(names(df), key_cols)
  sample_cols <- setdiff(sample_cols, exclude)

  # Collapse to one row per gene
  gene_means <- df %>%
    group_by(gene) %>%
    summarise(
      across(all_of(sample_cols),
             ~ suppressWarnings(as.numeric(.)) %>% mean(na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(gene)

  # Calculate overall mean per sample across all genes
  avg_row <- gene_means %>%
    summarise(
      across(all_of(sample_cols), ~ mean(.x, na.rm = TRUE))
    ) %>%
    mutate(gene = "__AVERAGE__") %>%
    select(gene, everything())

  # Append to main table
  bind_rows(gene_means, avg_row)
}

# Create “joined” table (per-gene means for each ref) and long/summary derivatives
compute_diff_tables <- function(hg38_gene, chm13_gene) {
  samples_hg38 <- setdiff(names(hg38_gene), "gene")
  samples_chm13 <- setdiff(names(chm13_gene), "gene")

  if (!setequal(samples_hg38, samples_chm13)) {
    only_hg38  <- setdiff(samples_hg38, samples_chm13)
    only_chm13 <- setdiff(samples_chm13, samples_hg38)
    msg <- c()
    if (length(only_hg38))  msg <- c(msg, paste0("Only in hg38: ", paste(only_hg38, collapse = ", ")))
    if (length(only_chm13)) msg <- c(msg, paste0("Only in chm13: ", paste(only_chm13, collapse = ", ")))
    stop("Sample columns differ.\n", paste(msg, collapse = "\n"), call. = FALSE)
  }
  samples <- sort(samples_hg38)

  joined <- inner_join(
    hg38_gene  %>% rename_with(~ paste0(.x, ".hg38"),  all_of(samples)),
    chm13_gene %>% rename_with(~ paste0(.x, ".chm13"), all_of(samples)),
    by = "gene"
  )

  # add per-sample diffs (CHM13 - HG38)
  for (s in samples) {
    joined[[paste0(s, ".diff")]] <-
      joined[[paste0(s, ".chm13")]] - joined[[paste0(s, ".hg38")]]
  }

  # 1) wide
  wide_diff <- joined %>%
    select(gene, ends_with(".diff")) %>%
    rename_with(~ str_remove(.x, "\\.diff$"), ends_with(".diff")) %>%
    arrange(gene)

  # 2) long
  long_tbl <- joined %>%
    select(gene, matches("\\.(hg38|chm13|diff)$")) %>%
    pivot_longer(
      cols = -gene,
      names_to = c("sample", ".value"),
      names_pattern = "^(.*)\\.(hg38|chm13|diff)$"
    ) %>%
    arrange(gene, sample)

  # 3) summary
  gene_summary <- long_tbl %>%
    group_by(gene) %>%
    summarise(
      mean_hg38  = mean(hg38,  na.rm = TRUE),
      mean_chm13 = mean(chm13, na.rm = TRUE),
      mean_diff  = mean(diff,  na.rm = TRUE),
      median_diff = median(diff, na.rm = TRUE),
      mean_pct_change = ifelse(is.finite(mean_hg38) & mean_hg38 != 0,
                               100 * (mean_chm13 - mean_hg38) / mean_hg38, NA_real_),
      .groups = "drop"
    ) %>%
    arrange(desc(mean_diff))

  list(joined = joined, wide_diff = wide_diff, long_tbl = long_tbl, gene_summary = gene_summary)
}

save_pdf <- function(plot, file, width = 12, height = 5) {
  ggsave(filename = file.path(out_dir, file), plot = plot, device = cairo_pdf,
         width = width, height = height, units = "in")
}

# ------------------------------- Load Data ------------------------------------
assert_readable(path_chm13)
assert_readable(path_hg38)

chm13_raw <- read_tsv(path_chm13, show_col_types = FALSE)
hg38_raw  <- read_tsv(path_hg38,  show_col_types = FALSE)

key_cols <- c("chr", "start", "end", "size", "gene")

hg38_gene  <- collapse_gene_simple(hg38_raw,  key_cols = key_cols, exclude = exclude_samples)
chm13_gene <- collapse_gene_simple(chm13_raw, key_cols = key_cols, exclude = exclude_samples)

tabs <- compute_diff_tables(hg38_gene, chm13_gene)
joined       <- tabs$joined
wide_diff    <- tabs$wide_diff
long_tbl     <- tabs$long_tbl
gene_summary <- tabs$gene_summary

# ------------------------------- Plots ----------------------------------------
# Faceted boxplots per gene comparing references (subset first N genes for speed)
long_tbl_ref <- long_tbl %>%
  select(-diff) %>%
  pivot_longer(cols = c(hg38, chm13), names_to = "reference", values_to = "coverage") %>%
  mutate(reference = factor(reference, levels = c("hg38", "chm13")))

genes_subset <- head(unique(long_tbl_ref$gene), top_n)
plot_data <- long_tbl_ref %>% filter(gene %in% genes_subset)

p_gene_boxes <-
  ggplot(plot_data, aes(x = reference, y = coverage, fill = reference)) +
  geom_boxplot(outlier.shape = 21, outlier.size = 1.8) +
  scale_fill_manual(values = ref_colors) +
  labs(x = NULL, y = "Coverage across NMD genes") +
  theme_bw(base_size = 12) +
  theme(legend.position = "none",
        strip.text = element_text(size = 9)) +
  facet_wrap(~ gene, scales = "free_y")
save_pdf(p_gene_boxes, "./faceted_gene_boxes_hg38_vs_chm13.pdf", width = 14, height = 8)

#total comparison
total_plot_data <- long_tbl_ref %>% filter(gene %in% "__AVERAGE__")

p_total <-ggplot(total_plot_data, aes(x = reference, y = coverage, fill = reference)) +
  geom_boxplot(outlier.shape = 21, outlier.size = 1.8) +
  scale_fill_manual(values = ref_colors) +
  labs(x = NULL, y = "Coverage across all NMD genes") +
  theme_bw(base_size = 12) +
  theme(legend.position = "none",
        strip.text = element_text(size = 9))
save_pdf(p_total, "./total_hg38_vs_chm13.pdf", width = 14, height = 8)

#mean coverage between two references
total <- total_plot_data %>%
  group_by(reference) %>%
  summarise(
    mean_coverage   = mean(coverage, na.rm = TRUE),
    median_coverage = median(coverage, na.rm = TRUE),
    sd_coverage     = sd(coverage, na.rm = TRUE),
    n = n()
  )
write_tsv(total, file.path(out_dir, "total_avg_hg38_chm13.tsv"))

# Genes better covered in CHM13 (mean_diff > 0), top N by mean_diff
t2t_higher_cov <- gene_summary %>%
  filter(mean_diff > 0) %>%
  arrange(desc(mean_diff)) %>%
  slice_head(n = top_n)

t2t_plot_data <- long_tbl %>%
  semi_join(t2t_higher_cov, by = "gene") %>%
  group_by(gene) %>%
  mutate(mean_diff_gene = mean(diff, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(gene = fct_reorder(gene, mean_diff_gene, .desc = TRUE))

p_t2t_higher <-
  ggplot(t2t_plot_data, aes(x = gene, y = diff)) +
  geom_boxplot() +
  coord_cartesian(clip = "off") +
  labs(x = NULL, y = "Average coverage difference (CHM13 - GRCh38)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_pdf(p_t2t_higher, "./t2t_genes_higher_cov.pdf", width = 12, height = 5)

# Genes better covered in GRCh38 (mean_diff < 0), top N by |mean_diff|
hg38_higher_cov <- gene_summary %>%
  filter(mean_diff < 0) %>%
  mutate(mean_diff_hg38 = -mean_diff) %>%
  arrange(desc(mean_diff_hg38)) %>%
  slice_head(n = top_n)

hg38_plot_data <- long_tbl %>%
  semi_join(hg38_higher_cov, by = "gene") %>%
  group_by(gene) %>%
  mutate(mean_diff_gene = mean(diff, na.rm = TRUE)) %>%
  mutate(diff_hg38 = -diff) %>%
  ungroup() %>%
  mutate(gene = fct_reorder(gene, mean_diff_gene, .desc = FALSE))

p_hg38_higher <-
  ggplot(hg38_plot_data, aes(x = gene, y = diff_hg38)) +
  geom_boxplot() +
  coord_cartesian(clip = "off") +
  labs(x = NULL, y = "Average coverage difference (GRCh38 - CHM13)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_pdf(p_hg38_higher, "./hg38_genes_higher_cov.pdf", width = 12, height = 5)

# Mean-diff overview (sorted by mean_diff in gene_summary)
p_mean_diff_line <-
  ggplot(gene_summary, aes(x = seq_along(mean_diff), y = mean_diff)) +
  geom_line() +
  theme_minimal(base_size = 12) +
  labs(x = NULL, y = "Mean difference (CHM13 - GRCh38)")
save_pdf(p_mean_diff_line, "./gene_mean_diff_line.pdf", width = 10, height = 4)

# Density and histogram of mean_diff
p_density <-
  ggplot(gene_summary, aes(x = mean_diff)) +
  geom_density(alpha = 0.5) +
  theme_minimal(base_size = 12) +
  labs(x = "Mean difference (CHM13 - GRCh38)", y = "Density")
save_pdf(p_density, "./gene_mean_diff_density.pdf", width = 8, height = 4)

p_hist <-
  ggplot(gene_summary, aes(x = mean_diff)) +
  geom_histogram(bins = 30, alpha = 0.6) +
  theme_minimal(base_size = 12) +
  labs(x = "Mean difference (CHM13 - GRCh38)", y = "Count")
save_pdf(p_hist, "./gene_mean_diff_histogram.pdf", width = 8, height = 4)

# ----------------------------- Optional Exports -------------------------------
# Write tidy outputs if you want to inspect downstream
write_tsv(wide_diff,    file.path(out_dir, "wide_diff_per_sample.tsv"))
write_tsv(long_tbl,     file.path(out_dir, "long_tbl_gene_sample.tsv"))
write_tsv(gene_summary, file.path(out_dir, "gene_summary.tsv"))

message("Done. PDFs and TSVs written to: ", normalizePath(out_dir))
