for filename in *.fa; do
echo $filename
SAMPLE=$(echo ${filename} | sed "s/\.fa//")
echo "make directory "${SAMPLE}""
mkdir -p analysis/${SAMPLE}_uniprot;
echo "make blast database of "${filename}""
makeblastdb -dbtype prot -parse_seqids -in $filename
##blast
blastp -db "$filename" -query GLP_pep_AT.fasta -out analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot -num_threads 4 -outfmt 6 -evalue 1e-5


#### blast tabluar to gff3,parsing the blast output in gff3 format

awk '{ if ($3 >= 80) print }' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot > analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter

awk '{ if ($3 >= 80) print $2 }' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_uniprot > analysis/"$SAMPLE"_uniprot/"$SAMPLE"_header.list

awk '{n=$9; $15=n} {p=$10; $16=p} {y=$9; $17=y} {z=$10; $18=z} ($9>$10&&$16>0) {print $2 "\ttBn\tRT\t" $16 "\t" $15 "\t.\t-\t.\tID="$2"_"$9"_"$10} ($10>$9&&$17>0) {print $2 "\ttBn\tRT\t" $17 "\t" $18 "\t.\t+\t.\tID="$2"_"$9"_"$10}' analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_filter.gff3
done


echo "Sequence Extraction"
for filename in *.fa; do
echo $filename
SAMPLE=$(echo ${filename} | sed "s/\.fa//")
seqtk subseq $filename ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_header.list > ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP.fasta
hmmscan --tblout "$SAMPLE".txt pfam/Pfam-A.hmm ./analysis/"$SAMPLE"_uniprot/"$SAMPLE"_GLP.fasta
Rscript pfam\ graph.R -f "$SAMPLE".txt -o "$SAMPLE"
done
