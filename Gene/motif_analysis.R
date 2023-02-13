#!/usr/bin/env Rscript
library("optparse")

option_list = list(
  make_option(c("-x", "--xmlfile"), type="character", default=NULL, 
              help="meme xml file output", metavar="character"),
  make_option(c("-n", "--newick"), type="character", default=NULL, 
              help="Tree in nwk format", metavar="character"),
  make_option(c("-o", "--output"), type="character", default=NULL, 
              help="output file name", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
if (is.null(opt$xmlfile)){
  print_help(opt_parser)
  stop("All two argument must be supplied (input file).n", call.=FALSE)
}
library(ggmotif)
library(ggplot2)
motif_extract <- getMotifFromMEME(data = paste0(opt$xmlfile,".xml"), format="xml")
motif_plot <- motifLocation(data = motif_extract, tree = opt$newick)
motif_plot +
  ggsci::scale_fill_aaas() + ggtitle(opt$output)
ggsave(paste0(opt$output,".png"), width = 20, height = 20)
############## sequence logo ######################
motif.info <- getMotifFromMEME(data = paste0(opt$xmlfile,".txt"), format = "txt")

# show all motif
plot.list <- NULL
library(tidyverse)
for (i in unique(motif.info$motif.num)) {
  motif.info %>%
    dplyr::select(2, 4) %>%
    dplyr::filter(motif.num == i) %>%
    dplyr::select(2) %>%
    ggseqlogo::ggseqlogo() +
    labs(title = i) +
    theme_bw() -> plot.list[[i]]
}

cowplot::plot_grid(plotlist = plot.list, ncol = 1)
ggsave(paste0(opt$output,"_logo.png"), width = 35, height = 15)