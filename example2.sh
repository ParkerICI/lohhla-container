#!/bin/bash

Rscript /root/lohhla/LOHHLAscript.R --patientId example --outputDir /mnt/example-out --normalBAMfile /root/lohhla/example-file/bam/example_BS_GL_sorted.bam --BAMDir /root/lohhla/example-file/bam  --hlaPath /root/lohhla/example-file/hlas --HLAfastaLoc /root/lohhla/data/example.patient.hlaFasta.fa  --CopyNumLoc /root/lohhla/example-file/solutions.txt --mappingStep TRUE --minCoverageFilter 10 --fishingStep TRUE --cleanUp FALSE --gatkDir /picard --novoDir /novocraft




