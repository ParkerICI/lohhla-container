## Copyright Parker Institute for Cancer Immunotherapy, 2018

## Lohhla

## Description:
## A workflow to call loss-of-heterozygosity and copy number changes in HLA alleles, using the LOHHLA tool.

## Input requirements:
## - normal_bam: The normal bam
## - tumor_bam: The tumor bam
## - tumor_index: The index of the tumor bam
## - normal_index: The index of the normal bam
## - cellularity: The cellularity (purity) of the tumor bam
## - ploidy: The ploidy of the tumor bam
## - hla: The hla, computed from polysolver, of the sample.
## - sample_name: The name of the sample

## Output:
## - lohhla_summary: The output of lohhla, for each a/b/c allele pair

## Reference: 
## Github: https://bitbucket.org/mcgranahanlab/lohhla
## Paper: https://www.cell.com/cell/abstract/S0092-8674(17)31185-6

# Maintainer:
# Danny Wells <danny@parkerici.org>

## Licensing :
## This script is released under the PICI Informatics License (GPL3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script. 


workflow Lohhla {

  File normal_bam
  File tumor_bam
  File tumor_index
  File normal_index
  File cellularity
  File ploidy
  File hla
  String sample_name

  String? docker

  Int? preempt
  Int preempt_attempts = select_first([preempt, 3])
    


  call CallLohhla {
    input: 
      normal_bam=normal_bam,
      tumor_bam= tumor_bam,
      normal_index = normal_index,
      tumor_index = tumor_index,
      hla=hla,
      sample_name=sample_name,
      ploidy=ploidy,
      cellularity=cellularity,
      docker=docker,
      preempt_attempts = preempt_attempts
  }

  output {
    File hla_loss = CallLohhla.hla_loss
    File integer_cpn=CallLohhla.integer_cpn
  }
}



task CallLohhla {

  #The entire end-to-end task to call lohhla.
  # We also include a step to munge the hlas into a lohhla-specific format
  #As well as create the lohhla-specific table for cellularity and ploidy.

  File normal_bam
  File tumor_bam
  File normal_index
  File tumor_index
  File hla
  String sample_name
  File ploidy
  File cellularity

  #Task parameters - set at the task level, not at the workflow level. 
  Int? mem
  Int machine_mem = select_first([mem,4])

  Int? storage 
  Int disk_space_gb = select_first([storage, 300])

  String? docker = "gcr.io/pici-internal/lohhla:1.0.5"
  Int preempt_attempts

  command <<<    

    #lohhla REQUIRES hla calls be imporated directly from polysolver - same format, same 6/8 digit assignment (presumably, since we are using the complete polysolver fasta.
    python -c "import pandas as pd; df =pd.read_csv('${hla}', header=-1,sep='\t'); ll=df.loc[:,[1,2]].values.flatten(); print ll[0] ; print ll[1]; print ll[2]; print ll[3]; print ll[4]; print ll[5] " > /cromwell_root/hlas

    cat /cromwell_root/hlas

    mkdir /cromwell_root/bams

    mv ${normal_bam} /cromwell_root/bams/normal.bam
    mv ${normal_index} /cromwell_root/bams/normal.bam.bai
    mv ${tumor_bam} /cromwell_root/bams/tumor.bam
    mv ${tumor_index} /cromwell_root/bams/tumor.bam.bai

    p=$( cat ${ploidy} )
    c=$( cat ${cellularity} )

	echo -e "Ploidy\ttumorPurity\ttumorPloidy\ntumor\t2\t$c\t$p">/cromwell_root/ploidy.txt
	Rscript /root/lohhla/LOHHLAscript_b37.R --patientId ${sample_name} --outputDir /cromwell_root/out --normalBAMfile /cromwell_root/bams/normal.bam  --BAMDir /cromwell_root/bams --CopyNumLoc /cromwell_root/ploidy.txt  --hlaPath /cromwell_root/hlas --HLAfastaLoc /home/polysolver/data/abc_complete.fasta --mappingStep TRUE --minCoverageFilter 10 --fishingStep TRUE --cleanUp FALSE --gatkDir /picard --novoDir /novocraft

	outf=$( ls /cromwell_root/out/*.HLAlossPrediction_CI.xls )
    outg=$( ls /cromwell_root/out/*IntegerCPN_CI.xls )

    #Lohhla outputs an "xls" which is actually just a tsv. 
    mv $outf HLAloss_${sample_name}.tsv
    mv $outg IntegerCPN_${sample_name}.tsv

  >>>

  runtime {
    preemptible: preempt_attempts
    docker: "${docker}"
    memory: machine_mem + " GB"
    cpu: "1"
    disks: "local-disk " + disk_space_gb + " SSD"
    bootDiskSizeGb: "12"
  }

  output {
    File hla_loss="HLAloss_${sample_name}.tsv"
    File integer_cpn="IntegerCPN_${sample_name}.tsv"
  }

}

