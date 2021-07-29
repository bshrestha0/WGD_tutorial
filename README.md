# WGD Tutorial
This is a tutorial on how to use wgd, a tool for estimating whole-genome duplication, as described in the paper: Zwaenepoel, A. and Van de Peer, Y., 2019. wgd—simple command line tools for the analysis of ancient whole-genome duplications. Bioinformatics, 35(12), pp.2153-2155 (https://doi.org/10.1093/bioinformatics/bty915)

Some additional resources associated with the tool are available here: 

Supplementary data:- https://oup.silverchair-cdn.com/oup/backfile/Content_public/Journal/bioinformatics/35/12/10.1093_bioinformatics_bty915/1/bty915_supplementary_data.pdf?Expires=1629542673&Signature=Tho74olvAK3Fyf-qAF2-2umnNE5kmbqtardO~FHxfyTg0K7oTuTT3Veh8YuNYGKUhk-l11W2fY~WmwtMngJCkBP44AUawZKkqpadmzGmpKHjA6oeYyWMoE4RQPH0JTtVsmaCXD5X7w3uZ4nW~hTv73F4S2I3KFqWw0r79Fbqd0wAaOpKZh~FSS29z2pTovwXo4MBj~c0Xup8nNP15lB52p5j8h2AD4Lc3gOQe5S1X0LgZzEYUjWeyQGWs8OsdG3QhWmj0PXJA~M7joDb9AV18faRU8VCH3g7vk84pHtxYCga4l4ZT7lgE6jLj3kHf~SfXjDzc2AC3Z87kvSRNmI~gA__&Key-Pair-Id=APKAIE5G5CRDK6RD3PGA

Documentation: https://wgd.readthedocs.io/en/latest/index.html

Associated article: https://doi.org/10.1093/molbev/msz088

## Installation
Installation was straight forward in the Xanadu cluster: 

`git clone https://github.com/arzwa/wgd.git`

`cd wgd`

`pip install --user .`  # if pip is default for pip2 then try pip3.

On proper installation, it will create all executables in the $HOME/.local directory. Make sure to export the executables path to $PATH variable.

Installation on your local computer:  Was only able to install creating conda environment. 

`conda create -n wgd_env python=3.9`  #create conda environment with specific python version

`conda activate wgd_env` #activate the environment

`git clone https://github.com/arzwa/wgd.git`

`cd wgd`

Parameters in setup.py may need to be changed. In my case, I changed pandas==0.24.1 to pandas==1.2.0 prior installing.
Other parameters may need to be changed depending on the error encountered during the installation.
Installation after changing parameters:

`pip install --user .`

On proper installation, all executables will be in: /pathtocondaenvs/wgd_env/bin/ and other required softwares (BLAST, MAFFT/MUSCLE, FastTree, MCL, PAML and I-ADHoRe) will also be installed.

## Gathering data
This tutorial is intended for estimating whole-genome duplication using transcriptomic data. 
For a test run, a non-redundant transcriptomic data can be downloaded for list of flowering plants using plant genomic resource Phytozome:
https://phytozome.jgi.doe.gov/pz/portal.html

### Removing plastid and mitochondrial transcripts
*The commands below will only work for Arabidopsis thaliana!*

If the transcript multifasta file is not wrapped, then use:

`grep -A 1 ">AT[1-9]G" arabidopsis.cds > ath.filtered.cds`

If the multifasta is wrapped, samtools can be used to extract transcripts of interest:

`awk '/AT[1-9]G/ {print $1}' arabidopsis.cds | sed 's/^.//' > id.txt`

`while read line; do samtools faidx arabidopsis.cds $line >> ath.filtered.cds ; done < id.txt`

## Running WGD
### All-vs-all blast + MCL clustering

`wgd mcl --cds --mcl -s ath.filtered.cds  -o ./ -n 8`

### Estimate Ks distribution, FastTree for inferring phylogenetic tree. 
`mkdir Ks_distribution`

`wgd ksd ath.mcl ath.filtered.cds -o ./Ks_distribution -n 8`

#Run I-ADHoRe and get an anchor-point KS distribution and dotplots.

`wgd syn ath.gff ath.mcl -ks ath.mcl.ks.tsv -f gene -a ID`

### Fitting gaussian mixture models (GMM) and Bayesian GMM with 1 to 5 components

`mkdir mixed_models`

`wgd mix Ks_distribution/ath.filtered.cds.ks.tsv -n 1 5 -o ./mixed_models`

`wgd mix --method bgmm Ks_distribution/ath.filtered.cds.ks.tsv -o ./mixed_models`

## Estimate Kernel density interactively
I couldn't run it on the cluster and I have to run it in my local computer.

`bokeh serve &` # running bokeh server

It did not open a web browser and gave a output as shown below.:

![alt text](https://github.com/bshrestha0/WGD_tutorial/blob/main/bokeh_server_log.png)
I copied the URL shown in the log (http://localhost:5006/) in the web browser and execute the following command:

`wgd viz -i -ks ath.mcl.ks.tsv,ath.mcl.ks_anchors.tsv -l full,anchors --interactive `
