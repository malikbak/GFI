for filename in *.fa; do
echo $filename
SAMPLE=$(echo ${filename} | sed "s/\.fa//")
echo "make directory "${SAMPLE}""
mkdir -p analysis/${SAMPLE}_uniprot;
echo "make blast database of "${filename}""
makeblastdb -dbtype nucl -parse_seqids -in $filename
##blast
blastn -db "$filename" -query sequence.fasta -out analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot -num_threads 4 -outfmt 6 -evalue 1e-5


#### blast tabluar to gff3,parsing the blast output in gff3 format

awk '{ if ($3 >= 89) print }' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot > analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter

awk '{ if ($3 >= 89) print $2 }' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot > analysis/"$SAMPLE"_uniprot/"$SAMPLE"_header.list

awk '{n=$9; $15=n} {p=$10; $16=p} {y=$9; $17=y} {z=$10; $18=z} ($9>$10&&$16>0) {print $2 "\ttBn\tRT\t" $16 "\t" $15 "\t.\t-\t.\tID="$2"_"$9"_"$10} ($10>$9&&$17>0) {print $2 "\ttBn\tRT\t" $17 "\t" $18 "\t.\t+\t.\tID="$2"_"$9"_"$10}' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter.gff3
done


echo "Sequence Extraction"
for filename in *.fa; do
echo $filename
SAMPLE=$(echo ${filename} | sed "s/\.fa//")
seqtk subseq $filename ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_header.list > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP.fasta
eval "$(conda shell.bash hook)"
conda activate seqkit
seqkit rmdup -n ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP.fasta -o ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_rmdup.fasta
conda activate meme
meme ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_rmdup.fasta -o ./analysis/"$SAMPLE"_uniprot/"$SAMPLE" -nmotifs 3
clustalo -i ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_rmdup.fasta > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_tree.fa
FastTree ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_tree.fa > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_tree.nwk
Rscript motif_analysis.R -x ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"/meme -n ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP_tree.nwk -o "$SAMPLE"
done
