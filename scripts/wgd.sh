#!/bin/bash

#SBATCH --job-name=WGD
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=END
#SBATCH --mem=40G
#SBATCH --mail-user=bikash.shrestha@uconn.edu
#SBATCH -o models_%j.out
#SBATCH -e models_%j.err


module load python/3.6.3
module load mcl/14-137 
module load blast/2.11.0
module load fasttree/2.1.10
module load mafft/7.471
module load paml/4.9

## all-vs-all blast using blastP and MCL clustering
wgd mcl --cds --mcl -s ath.filtered.cds  -o ./ -n 8

#Ks distribution using fastTree
mkdir -p Ks_distribution
wgd ksd -n 8 ./ath.blast.mcl ath.filtered.cds -o ./Ks_distribution

#Fitting GMM or BGMM
mkdir -p mixed_models

wgd mix Ks_distribution/ath.filtered.cds.ks.tsv -n 1 5 -o ./mixed_models
wgd mix --method bgmm Ks_distribution/ath.filtered.cds.ks.tsv -o ./mixed_models

