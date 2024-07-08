
#####################################################
#create a fasta file primers.fa containing both primers 
 
echo ">Forward_primer” > primers.fa
echo "TGTAAAACGACGGCCAGTATGTCACCACAAACAGAGACTAAAGC" >> primers.fa
echo ">Reverse_primer” > primers.fa
echo "GGTACMTGGACVRCTGTRTGGACCGGTCATAGCTGTTTCCTG" >> primers.fa

######################################################
FASTQC 
mkdir files_fastqc
 fastqc -o files_fastqc {dir}/*.fastq
cd files_fastqc
multiqc .
 
########################################################
Trimmomatic

#!/bin/bash

# Input and output directories
input_dir={dir}
output_dir={dir}

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Trimmomatic jar file path
trimmomatic_jar={path}

# Loop through all FASTQ files in the input directory
for file in "$input_dir"/*.fastq; do
    # Extract file name without directory path
    filename=$(basename "$file")

    # Construct output file path
    output_file="$output_dir/trimmed_${filename%.fastq}_trimmed.fastq"

    # Run Trimmomatic with adjusted parameters
    java -jar "$trimmomatic_jar" SE "$file" "$output_file" ILLUMINACLIP:primer.fa:5:10:5 SLIDINGWINDOW:5:15
done

######################################################


#Cutadapt 

FPrimer=""

RPrimer=""

for file in *.fastq
        do
                cutadapt -g "${FPrimer}" --discard-untrimmed -o ForwaredTrimmed_${file} "$file"
               sleep 5
               echo

                  cutadapt -a "${RPrimer}" --discard-untrimmed -o VSEARCH_${file} "ForwaredTrimmed_${file}"
               sleep 5
               echo
        done--

###################################################

##################################################
#SeqTK converting fastq files and fasta files


#converting to fasta format

for file in {dir}/*.fastq; do
  seqtk seq -a "$file" > "${file%.fastq}.fasta"
done
 
#merge all fasta files
################################################
VSEARCH DEREP & CLUSTERING


vsearch --derep_fulllength all.merged.fasta --minuniquesize 1  --sizein --sizeout --fasta_width 0 --uc all.merged.derep.uc --output all.merged.derep.fasta

vsearch --cluster_size all.merged.derep.fasta --threads 54 --id 0.98 --strand both --sizein --sizeout --fasta_width 0 --uc all.merged.preclustered.uc --centroids all.merged.preclustered.fasta

vsearch --uchime_denovo all.merged.preclustered.fasta --sizein --sizeout --fasta_width 0 --nonchimeras all.merged.denovo.nonchimeras.fasta

Please also adjust it based on Ross's recommendation about id, which is the percentage of identity.

vsearch --cluster_size all.merged.nonchimeras.fasta --threads 54 --id 0.98 --strand both --sizein --sizeout --fasta_width 0 --uc all.merged.clustered.uc --relabel OTU_ --centroids All.OTUs.Merged.fasta --otutabout All.TAB_OTUs.txt



##############################################
