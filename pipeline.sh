#fastqc
mkdir /root/results
mkdir /root/results/fastqc_res
fastqc -o /root/results/fastqc_res /root/tempDir/*.fastq.gz  &> /root/results/fastqc_res/fastqcLog.txt

#create index
mkdir /root/results/index
bowtie2/bowtie2-build $1 /root/results/index/refGenBuilld &> /root/results/index/indexingLog.txt

#allign
mkdir /root/results/alignment
for i in /root/tempDir/*.fastq.gz
do
i="$(basename -- $i)"
bowtie2/bowtie2 -x /root/results/index/refGenBuilld -U /root/tempDir/${i} -S /root/results/alignment/${i%%.fastq.gz}.sam &> /root/results/alignment/${i%%.fastq.gz}.txt
done

#sort
for i in /root/results/alignment/*.sam
do
i="$(basename -- $i)"
samtools view -b /root/results/alignment/${i} | samtools sort -O BAM -o /root/results/alignment/${i%%.sam}.bam -
done

#unique reads
for i in /root/results/alignment/*.bam
do
i="$(basename -- $i)"
samtools view -F 4 -h /root/results/alignment/${i} | grep -E '@|NM:' | grep -v 'XS:' | samtools view -b > /root/results/alignment/${i%%.bam}_unique.bam
done

#bai file
for i in /root/results/alignment/*_unique.bam
do
i="$(basename -- $i)"
samtools index /root/results/alignment/${i}
done

#NRF report
mkdir /root/results/NRF
for i in /root/results/alignment/*_unique.bam
do
i="$(basename -- $i)"
echo ${i}
python NRF.py /root/results/alignment/${i} /root/results/NRF/${i%%_unique.bam}_NRF.txt
done

#Peak calling
control=$2
target=$3
#control=""
#control=""

mkdir /root/results/peaks

if [ -z "$control" ]
then
    cd /root/results/alignment/
    target=($target)
    macs2 callpeak -t ${target[*]} -f BAM -n macs2 --fix-bimodal --extsize 147 --outdir /root/results/peaks/ &> /root/results/peaks/peakcallingLog.txt
else
   cd /root/results/alignment/
   control=($control)
   target=($target)

  macs2 callpeak -t ${target[*]} -c ${control[*]} -f BAM -n macs2 --extsize 147 --outdir /root/results/peaks/ --fix-bimodal &> ../peaks/peakcallingLog.txt
fi


mkdir /root/results/multiqc
multiqc /root/results --title "QC-Report" -o /root/results/multiqc
