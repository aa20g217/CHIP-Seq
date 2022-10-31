"""
ChIP-seq data analysis workflow. This workflow includes quality control, alignments, calculation of Non-Redundant Fractions (Unique start positions of uniquely mappable reads / Uniquely mappable reads), and peak calls.
"""
#"SRR1635435_1.fastq.gz SRR1635436_1.fastq.gz"
from pathlib import Path
import subprocess
from flytekit import LaunchPlan, workflow
from latch.types import LatchDir,LatchFile
from latch import large_task
from latch.resources.launch_plan import LaunchPlan
import os,shutil
import glob

@large_task
def runChipPipe(fastq: LatchDir,refGenome: LatchFile,output_dir: LatchDir,controls: str="") -> LatchDir:

    #copy input data
    if os.path.exists("/root/tempDir/"):
        os.remove("/root/tempDir/")
    shutil.copytree(fastq.local_path, "/root/tempDir/")


    #peak calling prep.
    if controls!="":
        all = ' '.join(str(e) for e in os.listdir("/root/tempDir/"))
        target=all.replace(str(controls),"")
        target=target.replace("  "," ")
    else:
        target=' '.join(str(e) for e in os.listdir("/root/tempDir/"))

    target=target.replace(".fastq.gz","_unique.bam")
    controls=controls.replace(".fastq.gz","_unique.bam")

    subprocess.run(["bash","pipeline.sh",refGenome.local_path,controls,target])

    local_output_dir = str(Path("/root/results/").resolve())
    remote_path=output_dir.remote_path
    if remote_path[-1] != "/":
       remote_path += "/"

    return LatchDir(local_output_dir,remote_path)


@workflow
def chipSeqWF(fastq: LatchDir,refGenome: LatchFile,output_dir: LatchDir,controls: str="") -> LatchDir:
    """

    CHIP-Seq
    ----

    ChIP-seq data analysis workflow. This workflow includes quality control, alignments, calculation of Non-Redundant Fractions (Unique start positions of uniquely mappable reads / Uniquely mappable reads), and peak calls.

    __metadata__:
        display_name: CHIP-Seq.
        author:
            name: Akshay
            email: akshaysuhag2511@gmail.com
            github:
        repository:
        license:
            id: MIT

    Args:
        fastq:
          A folder with all fastq.gz files.
          __metadata__:
            display_name: Input

        refGenome:
          A reference genome annotation file (.fa.gz file).
          __metadata__:
            display_name: Reference Genome Annotation

        controls:
          Name of control samples (space separated).
          __metadata__:
            display_name: Control Samples

        output_dir:
          Where to save the report and results?.
          __metadata__:
            display_name: Output Directory
    """
    return runChipPipe(fastq=fastq,refGenome=refGenome,controls=controls,output_dir=output_dir)


LaunchPlan(
    chipSeqWF,
    "Test Data",
    {
        "refGenome": LatchFile("s3://latch-public/test-data/4148/gencode.vM20.transcripts.fa.gz"),
    },
)
