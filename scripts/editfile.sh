#!/bin/bash

#SBATCH --job-name=myscript
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=END
#SBATCH --mem=10G
#SBATCH --mail-user=bikash.shrestha@uconn.edu
#SBATCH -o edit_%j.out
#SBATCH -e edit_%j.err

module load samtools/1.10

awk '/AT[1-9]G/ {print $1}' arabidopsis.cds | sed 's/^.//' > id.txt

while read line;
	do
	samtools faidx arabidopsis.cds $line >> ath.filtered.cds ;
done < id.txt
