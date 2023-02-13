#!/usr/bin/env Rscript
library("optparse")
library(ggplot2)
option_list = list(
  make_option(c("-f", "--hmmfile"), type="character", default=NULL, 
              help="hmmscan tblout file", metavar="character"),
  make_option(c("-o", "--output"), type="character", default=NULL, 
              help="output file name", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
if (is.null(opt$hmmfile)){
  print_help(opt_parser)
  stop("All two argument must be supplied (input file).n", call.=FALSE)
}
library(rhmmer)
ex <- read_tblout(opt$hmmfile)
ggplot(ex, aes(domain_name, query_name, size= sequence_score, color=sequence_evalue))+
  geom_point()+
  scale_color_gradient(low="blue", high="red")+
  labs(title =paste0(opt$output, "Pfam Domains"))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
ggsave(paste0(opt$output,".jpeg"), width = 12, height = 15)
