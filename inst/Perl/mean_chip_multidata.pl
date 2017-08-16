###################################################################
#
#   Calculate average of ChIP read counts for each group defined by prior_infile
#
#   Command arguments: 
#   #   
#   - chip: File recodes the number of reads at each nucleotide generated by count_tags_at_each_nucleotide.pl
#   - prior_infile: File encodes which segments of the genome are in which group.
#   - outfile: Name of output file
#   - data_length: The number of data sets included.
###################################################################
use List::Util qw(first);
use List::Util qw(sum);
    

my ($chip,$prior_infile,$outfile,$data_length)=@ARGV;

my $chr;

my @dna;
my @temp;
for(my $i=0;$i<$data_length;$i++){
 $temp[$i]=0;
 }
my $back=join("_", @temp);


# read in dnase data

 my %total_position;
  my %sum_chip;
 my $initial_pos=0;
 open IN, "$prior_infile" or die "Unable to open $prior_infile";
    while (my $line = <IN>) {
         @dna=();
         $initial_pos=0;
         
	  chomp($line);
          my($data_chrt, @other) =  split( /\t/, $line );
          $chr=$data_chrt;
                    for (my $i=0;$i<scalar(@other)/2;$i++){
             
             
             my $got_big=$other[2*$i+1];
                         my $pos=$initial_pos+$other[2*$i]-1;
             if($got_big ne $back){
               for (my $j = $initial_pos; $j <= $pos; $j++) {
                 $dna[$j] = $got_big;}
                            }
              $initial_pos=$pos+1;
              if ( exists $total_position{$got_big}){
                  $total_position{$got_big}=$total_position{$got_big}+$other[2*$i];}else{
                     $total_position{$got_big}=$other[2*$i];
                    

                                                     }
        

         }
      

}


 # read in chip

 open IN1, "$chip" or die "Cannot open $chip\n";
 my %data;
 my %data_chr_list;

 while (my $line = <IN1>) {
	chomp($line);
       
       my($chrt, $pos, $score) =  split( /\t/, $line );
                  if($chrt eq $chr){
                             if(exists $dna[$pos]){
                                   $sum_chip{$dna[$pos]}=$sum_chip{$dna[$pos]}+$score;
                                   $chip_position{$dna[$pos]}++;}else{
                                                $sum_chip{$back}=$sum_chip{$back}+$score;
                                                $chip_position{$back}++;         
 
                                                                                    }
          }        
 
}
 close IN1;
my  @keys = keys %total_position ;


for ( my $loops = 0; $loops < scalar(@keys); $loops++ )
{    
     if(exists $sum_chip{$keys[$loops]}){ 
      $sum_chip{$keys[$loops]}=$sum_chip{$keys[$loops]}+($total_position{$keys[$loops]}-$chip_position{$keys[$loops]})*0; }else{
      $sum_chip{$keys[$loops]}=($total_position{$keys[$loops]}-$chip_position{$keys[$loops]})*0;

   }          
     

}
open IN, "$outfile";
# if outfile does not exist, output values to outfile; if exists, add them up.
my $line = <IN>;
if($line){
chomp($line);
 my @keys_old = split /\t/, $line; 
 
 
 my $line = <IN>;
 chomp($line);
 my @dnase_counts_old = split /\t/, $line; 
 

 my $line = <IN>;
 chomp($line);
 my @counts_old = split /\t/, $line; 
 
 for(my $i=0;$i<scalar(@dnase_counts_old);$i++){
  if(exists $total_position{$keys_old[$i]}){
  $total_position{$keys_old[$i]}=$total_position{$keys_old[$i]}+$dnase_counts_old[$i];
  
  $sum_chip{$keys_old[$i]}=$sum_chip{$keys_old[$i]}+$counts_old[$i];}else{
  $total_position{$keys_old[$i]}=$dnase_counts_old[$i];
  $sum_chip{$keys_old[$i]}=$counts_old[$i];

  }


   }

}
close IN;


my  @keys = keys %total_position ;
my @counts;
my @dna_counts;
for ( my $loops = 0; $loops < scalar(@keys); $loops++ )
{      
      $dna_counts[$loops]=$total_position{$keys[$loops]};
      

                 $counts[$loops]= $sum_chip{$keys[$loops]};
      
}



 open OUT, ">$outfile" or die "Cannot open $outfile\n";

 print OUT join("\t", @keys)."\n";
 print OUT join("\t", @dna_counts)."\n";
 print OUT join("\t", @counts)."\n";

close OUT;
     