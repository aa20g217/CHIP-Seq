FROM 812206152185.dkr.ecr.us-west-2.amazonaws.com/latch-base:9a7d-main

#install and setup conda
RUN apt-get update && apt-get install -y git wget
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
   && rm -f Miniconda3-latest-Linux-x86_64.sh

RUN conda config --add channels bioconda --add channels conda-forge --add channels ambermd
RUN python3 -m pip install --upgrade requests

RUN apt-get update -y &&\
    apt-get install -y curl unzip

RUN curl -L https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.4/bowtie2-2.4.4-linux-x86_64.zip/download -o bowtie2-2.4.4.zip &&\
    unzip bowtie2-2.4.4.zip &&\
    mv bowtie2-2.4.4-linux-x86_64 bowtie2

RUN apt-get update -y &&\
    apt-get install -y autoconf samtools

RUN apt-get update -y &&\
    apt-get install -y fastqc

RUN conda install -c bioconda macs2
RUN conda install -c bioconda multiqc
RUN python3 -m pip install pysam

# You can use local data to construct your workflow image.
COPY NRF.py /root/NRF.py

COPY pipeline.sh /root/pipeline.sh
#COPY peakCalling.sh /root/peakCalling.sh
#COPY allignment.sh /root/allignment.sh
#COPY unique.sh /root/unique.sh



# STOP HERE:
# The following lines are needed to ensure your build environement works
# correctly with latch.
COPY wf /root/wf
ARG tag
ENV FLYTE_INTERNAL_IMAGE $tag
RUN python3 -m pip install --upgrade latch
WORKDIR /root
