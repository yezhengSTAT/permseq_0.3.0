.chipMeanCounts_multi = function(priorObject, OutfileLoc="./", Outfile){

  setwd(OutfileLoc)
  ChipSamFile <- NULL
  for(i in 1:length(priorObject[['chipSAM']])){
    temp <- strsplit(as.character(priorObject[['chipSAM']][i]), '/')[[1]]
    ChipSamFile <- c(ChipSamFile, temp[length(temp)])
  }
  #if no uni-reads from sam have been extracted:
  if(length(priorObject[['chipUni']]) == 0){
    for(i in 1:length(ChipSamFile)){
      ChipUniFile <- paste(ChipSamFile[i], '.uni.bed', sep='')
      priorObject[['chipUni']] <- c(priorObject[['chipUni']], paste(OutfileLoc, '/', ChipUniFile, sep=''))
      # Convert SAM to uni-reads BED format      
      script <- 'find_uni_bed.pl'
      Fn.Path <- system.file(file.path("Perl", script), package="permseq")
      CMD <- paste('perl  ', Fn.Path, ' ', priorObject[['chipSAM']][[i]], ' ', OutfileLoc, '/', ChipUniFile, sep='')
      system(CMD, intern=TRUE)
    }
  }
  
  for(i in 1:length(ChipSamFile)){
    # Count number of reads aligned to each nucleotide
    script <- 'count_tags_at_each_nucleotide.pl'
    Fn.Path <- system.file( file.path("Perl", script), package="permseq")
    ChipUniFile <- priorObject[['chipUni']][i]
    ChipUniFileN <- strsplit(ChipUniFile, '/')[[1]]
    ChipUniFileN <- ChipUniFileN[length(ChipUniFileN)]
    ChipUniCountFile <- paste(OutfileLoc, '/', ChipUniFileN, '_count.txt_temp', sep='')
    CMD <- paste('perl  ', Fn.Path, ' ', ChipUniFile, ' ', ChipUniCountFile, sep='')
    system(CMD, intern=TRUE)  
    #split countfiles
    setwd(OutfileLoc)
    outfileLoc <- fileDir <- "./"
    file <- strsplit(ChipUniCountFile, '/')[[1]]
    file <- file[length(file)]
    system( paste("awk -F \"\\t\" \'{close(f);f=$1}{print > \"", dirname(outfileLoc), "/", basename(outfileLoc), paste("/", "/\"f\"", '_', file, "\"}\' ", sep=''), fileDir, file, sep=""))
    
    # Calculate average of ChIP read counts for each group defined by "posLoc_bychr"
    script <- 'mean_chip_multidata.pl'
    Fn.Path <- system.file(file.path("Perl", script), package="permseq")
    chrlist <- names(priorObject[['posLoc_bychr']])
    for(chr in chrlist){
      system(paste('rm -rf ', outfileLoc, '/', chr, '_', Outfile[i], sep=''))
      CMD <- paste('perl  ', Fn.Path,' ', chr, '_', file, ' ', priorObject[['posLoc_bychr']][[chr]], ' ', paste(outfileLoc, '/', chr, '_', Outfile[i], sep=''), ' ', priorObject[['dataNum']], sep='')
      system(CMD, intern=TRUE)
    }
  }
  return(priorObject)
}
