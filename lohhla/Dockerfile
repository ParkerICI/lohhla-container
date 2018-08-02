### LOHHLA Container
# A docker container to run LOHHLA 

#We use the polysolver container for portability and for already compiled data. 
FROM sachet/polysolver:v4 
MAINTAINER Danny Wells "danny@parkerici.org"

#Install unix dependencies
RUN apt-get update -y && apt-get install build-essential -y

RUN apt-get -y install libcurl4-openssl-dev gfortran tcl-dev wget lftp -y tabix wget curl unzip gcc python-dev python-setuptools emacs vim git less lynx hdfview zlib1g-dev libncurses5-dev libncursesw5-dev cmake tar gawk valgrind sed hdf5-tools libhdf5-dev hdf5-helpers libhdf5-serial-dev openjdk-7-jdk r-base r-base-dev python-pip python python3 python3-dev python3-pip gfortran libblas3 libblas-dev liblapack3 liblapack-dev libatlas-base-dev libxml2-dev libxslt1-dev libreadline6 libreadline6-dev libjpeg8 libjpeg8-dev libfreetype6 libfreetype6-dev zlib1g-dev openssl libssl-dev pkg-config libffi-dev software-properties-common apt-transport-https ca-certificates sudo

#A strange bug about the link of the fortran library
RUN sudo ln -s /usr/lib/x86_64-linux-gnu/libgfortran.so.3 /usr/lib/libgfortran.so

#Install R packages
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "source('http://bioconductor.org/biocLite.R'); biocLite()"
RUN Rscript -e "update.packages(ask = FALSE, repos=c('https://cloud.r-project.org'))"
RUN Rscript -e "BiocInstaller::biocLite('seqinr',ask=FALSE)"
RUN Rscript -e "install.packages(c('beeswarm','zoo'),dependencies=T )"
RUN Rscript -e "install.packages(c('optparse'),dependencies=T )"
RUN Rscript -e "BiocInstaller::biocLite('Rsamtools',ask=FALSE)"

## Install jellyfish
RUN wget https://github.com/gmarcais/Jellyfish/releases/download/v2.2.6/jellyfish-2.2.6.tar.gz && \
	tar -xvzf jellyfish-2.2.6.tar.gz && \
	cd jellyfish-2.2.6 && \
	./configure --prefix=$HOME && \
	make -j 4 && \
	make install

ENV PATH="/jellyfish-2.2.6/bin:${PATH}"

#Install the proper version of samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
	tar -xjvf samtools-1.3.1.tar.bz2 && \
	cd samtools-1.3.1 && \
	make && \
	sudo make install

#Install the propoer version of bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.26.0/bedtools-2.26.0.tar.gz && \
	tar -zxvf bedtools-2.26.0.tar.gz && \
	cd bedtools2 && \
	make

ENV PATH="/bedtools2/bin:${PATH}"

#Clone LOHHLA and put it into the expected folder
RUN git clone https://bitbucket.org/mcgranahanlab/lohhla.git && \
	mv /lohhla /root/

#We use a specific veresion of novocraft - YOU CAN ONLY USE THIS IF YOU ARE A NON_PROFIT
ADD novocraft /novocraft

ENV PATH="/novocraft:${PATH}"

#Download Picard
RUN wget https://github.com/broadinstitute/picard/releases/download/1.123/picard-tools-1.123.zip && \
	unzip picard-tools-1.123.zip && \
	mv picard-tools-1.123 picard

