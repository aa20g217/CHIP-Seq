# CHIP-Seq pipeline

#### **Summary**
This repository contains a latch workflow/pipeline for the analysis of the ChIP-seq data. This pipeline includes the following steps:
* Quality control of the raw data
    - Performed with FastQC
* Alignment to the reference genome
    - Performed with Bowtie2
* Calculation of the non-redundant fraction (NRF) metric
* Peak calling
    - Performed using Macs2

#### **Input**

* Raw Data
    - A folder with all fastq.gz files. An example input data (mouse) is available at https://console.latch.bio/s/343962260275929.
    
* Reference Genome
    - A reference genome annotation file (.fa.gz file). You can load mouse reference genome using load test data feature from latch.
    
* Control samples
    - File name (space separated) of control samples, if available.

#### **Output**
A quality control report, bam files, NRF report, and peak calling results.

#### **Latch workflow link**
https://console.latch.bio/explore/82701/info
