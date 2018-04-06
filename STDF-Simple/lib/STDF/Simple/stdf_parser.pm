
use 5.10.0;
package STDF::Simple::stdf_parser;
use strict;
use warnings;

use Data::Dumper;
use List::Util qw/sum/;
use Scalar::Util qw(openhandle);
use Carp;
use Exporter 'import';

our @EXPORT_OK = qw(
    MIR MRR PCR HBR SBR PMR PGR RDR SDR
    WIR WRR WCR PIR PRR PTR FTR DTR TSR
    BPS EPS 
);
our %EXPORT_TAGS = (
    'record_constants' => [qw(
    MIR MRR PCR HBR SBR PMR PGR RDR SDR
    WIR WRR WCR PIR PRR PTR FTR DTR TSR
    BPS EPS
    
    )],
);

use constant {
    ATR   =>   0 <<8 | 20,
    MIR   =>   1 <<8 | 10,
    MRR   =>   1 <<8 | 20,
    PCR   =>   1 <<8 | 30,
    HBR   =>   1 <<8 | 40,
    SBR   =>   1 <<8 | 50,
    PMR   =>   1 <<8 | 60,
    PGR   =>   1 <<8 | 62,
    RDR   =>   1 <<8 | 70,
    SDR   =>   1 <<8 | 80,
    
    WIR   =>   2 <<8 | 10,
    WRR   =>   2 <<8 | 20,
    WCR   =>   2 <<8 | 30,
    
    PIR   =>   5 <<8 | 10,
    PRR   =>   5 <<8 | 20,
    
    PTR   =>  15 <<8 | 10,
    FTR   =>  15 <<8 | 20,
    
    DTR   =>  50<<8 | 30,
    
    TSR   =>  10<<8 | 30,
    BPS   =>  20<<8 | 10,
    EPS   =>  20<<8 | 20,
    
    UNK   =>  65536,
};

my %RECORDS = (
    ATR()   =>  'ATR',
    MIR()   =>  'MIR',
    MRR()   =>  'MRR',
    PCR()   =>  'PCR',
    HBR()   =>  'HBR',
    SBR()   =>  'SBR',
    PMR()   =>  'PMR',
    PGR()   =>  'PGR',
    RDR()   =>  'RDR',
    SDR()   =>  'SDR',
    WIR()   =>  'WIR',
    WRR()   =>  'WRR',
    WCR()   =>  'WCR',
    PIR()   =>  'PIR',
    PRR()   =>  'PRR',
    PTR()   =>  'PTR',
    FTR()   =>  'FTR',
    DTR()   =>  'DTR',
    TSR()   =>  'TSR',
    BPS()   =>  'BPS',
    EPS()   =>  'EPS',
    
);
# my %RECORDS = (
    # 0   => {
             # 20  => 'ATR',
    # },
    # 1   => { 10 => 'MIR',
             # 20 => 'MRR',
             # 30 => 'PCR',
             # 40 => 'HBR',
             # 50 => 'SBR',
             # 60 => 'PMR',
             # 62 => 'PGR',
             # 70 => 'RDR',
             # 80 => 'SDR'
            # },
    # 2   =>  {
             # 10 => 'WIR',
             # 20 => 'WRR',
             # 30 => 'WCR',
    # },
    # 5   => { 10 => 'PIR',
             # 20 => 'PRR',
           # },
    # 15  =>  { 10 => 'PTR',
              # 20 => 'FTR',
             # },
        # 50  =>  { 30 => 'DTR',
                         # },
    # 10   =>  { 30 => 'TSR' },
    # 20   =>  { 10 => 'BPS' ,
               # 20 => 'EPS',
            # },
    # );

sub new {

    my ($class,$file,@exclude)  = @_; 
  #  print "New called with ", join ",",@_;
   # print "\n";
    my %exclude_records = map { $_ =>1} @exclude;
    my $fh;
    my $own_fh = 0;  # true if file handle is owned by me
    if( openhandle($file) ) {
        $fh = $file;
        #print "i got openhandle\n";
    }
    else {
        open( $fh,'<',$file) or croak "Cannot open $file:$!";
        # yes i own filehandle, i can close if i'm done with FH
        $own_fh = 1;
    }
    binmode($fh) or croak "Cannot change binmode:$!";

    my $buf;
    my $nread = read($fh,$buf,6);
    if(!defined($nread)) { croak "Reading from file failed:$!"; }
    if($nread != 6) { croak "Error in reading FAR record";}
    

    my ($typ,$sub,$cpu,$stdf_ver) = unpack("xxCCCC",$buf);
#   print "CPU:$cpu\n";
#   print "STDF: $stdf_ver\n";
    croak "Invalid STDF file: expect FAR as first record. ($typ,$sub,$cpu,$stdf_ver)" if($typ != 0 && $sub != 10);
    croak "Parser unable to parse STDF VERSION:$stdf_ver" if($stdf_ver != 4);
    my $HEADER_TMPL; 
    my $UNSIGN_SHORT;
    my ($SIGN_SHORT,$SIGN_LONG);
    my $UNSIGN_LONG;
    my $REAL;
    if($cpu == 1) {
       $HEADER_TMPL = "nCC";
       $UNSIGN_SHORT = "n";
       $SIGN_SHORT   = "s>";
       $SIGN_LONG    = "l>";
       $UNSIGN_LONG = "N";
       $REAL        = "f>";
    }else {
       $HEADER_TMPL = "vCC";
       $UNSIGN_SHORT = "v";
       $SIGN_SHORT   = "s<";
       $SIGN_LONG    = "l<";
       $UNSIGN_LONG = "V";
       $REAL        = "f<";
    }
    if( unpack("$UNSIGN_SHORT",$buf) != 2) 
    {
        croak "Error in parsing FAR record: wrong FAR record length";
    }
#   my ($len,$typ,$sub);
#   my $data;
    my $BIT = "B";
    my @option_items = (
        #   "C/a" , "C/a",
        #   "B8", "c" , "c" ,"c" ,
        #   $REAL , $REAL ,
            "C/a" , "C/a", "C/a",
            "C/a",
            $REAL, $REAL
            );
    my %size_table = (
            "C/a" => 'str',
            "B8"  => 1,
            "b8"  => 1,
            "c"   => 1,
            $REAL => 4,
            );
    my $done = 0;
    my $num_bytes_read = 6;  # FAR 6 bytes
    my $rec_num        = 1; # FAR count as one
    my $ptr_fixed_template = "$UNSIGN_LONG C2 ${BIT}8 ${BIT}8 $REAL";
    my $ptr_opt_template   = "${BIT}8 c3 $REAL $REAL";
    my $prr_fixed_template = "CC ${BIT}8 ${UNSIGN_SHORT}3 ${SIGN_SHORT}2 $UNSIGN_LONG";
    #my $far = []
    my $parser = sub {
        
        my $buf;
        my ($len,$typ,$sub);
        my $data;
        my $n;
    LOOP : if( $n = read($fh,$buf,4) ) {
        if($n != 4) {
            croak "Parser error while reading record header.\n";
        }
        ($len,$typ,$sub) = unpack($HEADER_TMPL,$buf);
        $num_bytes_read += 4;
        my $actual_read = read($fh,$data,$len);
        
        if(!defined($actual_read) || $actual_read != $len)
        {
            croak "Parsing typ($typ), sub($sub): expects to read $len at record #$rec_num";
        }
        $num_bytes_read += $len;
        $rec_num += 1;
        my $cardinal = $typ << 8| $sub;
        my $name = exists($RECORDS{$cardinal}) ? $RECORDS{$cardinal} :'???';
        if(exists $exclude_records{$name} ) {
            # un-supported record or exclude
            next LOOP; 
        }      
        my @a;
        # PTR
        if($typ == 15 && $sub == 10)
        {
            #read($fh,$data,$len);
            push @a, unpack($ptr_fixed_template,$data);
          
            my $consumed_len = 12;
            my $val;
            if($consumed_len < $len )
            {
                #$val = unpack("x${consumed_len} C/a",$data);
                $val = unpack("C/a",substr($data,$consumed_len));
                $consumed_len += length($val) + 1;
                push @a,$val;
            }
             if($consumed_len < $len )
            {
               # $val = unpack("x${consumed_len} C/a",$data);
                $val = unpack("C/a",substr($data,$consumed_len));
                $consumed_len += length($val) + 1;
                push @a,$val;
            }
            my $remain_len = $len - $consumed_len;
            if($remain_len != 0) {
            #print "PTR remain len: $remain_len\n";
            if($remain_len >= 12) {
                push @a,unpack($ptr_opt_template,substr($data,$consumed_len));
                $consumed_len += 12;
            }
            elsif($remain_len == 8) {
                push @a,unpack("x${consumed_len} ${BIT}8 c3 $REAL",$data);
                $consumed_len += 8;
            }
            elsif($remain_len == 4) {
                push @a,unpack("x${consumed_len} ${BIT}8 c3",$data);
                $consumed_len += 4;
            }
            elsif($remain_len != 0) {
                my @items = qw( ${BIT}8 c c c);
                my $str = join "",@items[0..($remain_len-1)];
                push @a, unpack("x${consumed_len} $str",$data);
                $consumed_len += $remain_len;
            }
            for(1..4) {
               if($consumed_len < $len )
               {
                    $val = unpack("x${consumed_len} C/a",$data);
                    $consumed_len += length($val) + 1;
                    push @a,$val;
                }
                else { last; }
            }
            $remain_len = $len - $consumed_len;
            if($remain_len == 8) {
                push @a,unpack("x${consumed_len} $REAL $REAL",$data);
                $consumed_len += 8;
            }
            elsif($remain_len == 4) {
                push @a, unpack("x${consumed_len} $REAL",$data);
                $consumed_len += 4;
            }
                  
          #  print "Num of fields:",scalar(@a),"|";
          #  print join "|",@a;
          #  print "\n";
         }
        }
        # FTR
        elsif($typ == 15 && $sub == 20) {
            @a = unpack("$UNSIGN_LONG C2 ${BIT}8",$data);
           
            my $consumed = 7;
            my $len = length($data);
            if($len > $consumed) {
                push @a,unpack("x${consumed} ${BIT}8",$data);
                $consumed += 1;
                push @a,unpack("x${consumed} ${UNSIGN_LONG}4 ${SIGN_LONG}2 $SIGN_SHORT",$data);
                $consumed += 26;
            }
            my ($rtn_icnt,$pgm_icnt);
            if($len > $consumed ) {
                $rtn_icnt = unpack("x${consumed} $UNSIGN_SHORT",$data);
                push @a,$rtn_icnt;
                $consumed += 2;
            }
            if($len > $consumed) {
                $pgm_icnt = unpack("x${consumed} $UNSIGN_SHORT",$data);
                push @a,$pgm_icnt;
                $consumed += 2;
            }
           # print "RTN_ICNT: $rtn_icnt\n";
          #  print "PGM_ICNT: $pgm_icnt\n";
      
            if( $len > $consumed && $rtn_icnt) {
                my @rtn_indx = unpack("x${consumed} ${UNSIGN_SHORT}$rtn_icnt",$data);
                push @a,[@rtn_indx];
                $consumed += 2* $rtn_icnt;
                my @rtn_stat = unpack("x${consumed} C${rtn_icnt}",$data);
                push @a,[@rtn_stat];
                $consumed += $rtn_icnt;
                
              #  print "RTN_INDX: ",join(",",@rtn_indx),"\n";
              #  print "RTN_STAT: ",join(",",@rtn_stat),"\n";
            }
            
            #print "FTR:",join("|",@a);
          # print "\n";
        }
        # PIR
        elsif($typ == 5 && $sub == 10) {
            #read($fh,$data,$len);
             @a = unpack("CC",$data);
          #  print join "|",@a;
          #  print "\n";
        }
        # PRR
        elsif($typ == 5 && $sub == 20) {
        #  read($fh,$data,$len);
          @a = unpack($prr_fixed_template,$data);
          my $consumed_len = 17;
          my $val;
          if($consumed_len < $len )
          {
                $val = unpack("x${consumed_len} C/a",$data);
                $consumed_len += length($val) + 1;
                push @a,$val;
          }
          if($consumed_len < $len )
          {
                $val = unpack("x${consumed_len} C/a",$data);
                $consumed_len += length($val) + 1;
                push @a,$val;
          }
         
          if($consumed_len < $len) {
                #print "it is not zero", length($remain_data),"\n";
                 my $count = unpack("x${consumed_len} C",$data);
            # #   print "count $count\n";
                # if($count ) {
                    # my $repair_info = unpack("x(${BIT}8)[$count]",$data);
                    # push @a,$repair_info;
                # }
                #my @bit_v = unpack("x${consumed_len} C/C",$data);
                my $bit_vector = substr($data,$consumed_len+1,$count);
                if(length($bit_vector) != $count) {
                    die "Error in parsing PRR record: PART_FIX field.\n";
                }
                push @a, $bit_vector;
            }

        }
        # BPS
        elsif($typ == 20 && $sub == 10) {
            if(length($data)) {
                @a = unpack("C/a",$data);
            }
        }
        # EPS
        elsif($typ == 20 && $sub == 20) {
            unless(length($data) == 0) {
                die "Error in parsing EPS.\n";
            }
            #@a = ();
        }
         # DTR 
        elsif($typ == 50 && $sub == 30) {
        #   read($fh,$data,$len);
            push @a,unpack("C/a",$data);
        }
        #MIR 
        elsif($typ == 1 && $sub == 10) {
            @a = unpack("${UNSIGN_LONG}2 C4 $UNSIGN_SHORT C (C/a)5",$data);
            $a[3] = chr($a[3]);
            $a[4] = chr($a[4]);
            $a[5] = chr($a[5]);
            $a[7] = chr($a[7]);
            #print "mir len:$len\n";
            my $consumed_len = 15+ sum (map { length($a[$_]) + 1 } ( 8 .. 12));
            #print "Consumed: $consumed_len\n";
            my $remain_data = substr($data,$consumed_len);
            for(1..25) {
                if(length($remain_data) ==0) { last; }
                my $str= unpack("C/a",$remain_data);
                push @a,$str;
                $remain_data = substr($remain_data,length($str)+1);
            }
        #   print join "|",@a;
        #   print "\n";
        #   print "# of fields: ",scalar(@a),"\n";
            
        }
        # ATR
        elsif($typ == 0 && $sub == 20) {
            push @a,unpack("$UNSIGN_LONG C/a",$data);
        }
        # WIR
        elsif($typ == 2 && $sub == 10)
        {
            @a = unpack("CC$UNSIGN_LONG",$data);
            if($len > 6)
            {
                push @a, unpack("x6C/a",$data);      
            }
        }
        # WRR
        elsif($typ == 2 && $sub == 20) {
            @a = unpack("C2 ${UNSIGN_LONG}6",$data);
            my $consumed = 26;
            my $len = length($data);
            while($consumed < $len) {
                my $str = unpack("x${consumed} C/a",$data);
                $consumed += 1 + length($str);
                push @a,$str;
            }
           
        }
        # WCR
        elsif($typ == 2 && $sub == 30) {
            @a = unpack("${REAL}3 CC ${SIGN_SHORT}2 CC",$data);
            @a[4,7,8] = map { chr($_) } @a[4,7,8];
        
        }
        # MRR
        elsif($typ == 1 && $sub ==20) { 
            #read($fh,$data,$len);
            @a = unpack("$UNSIGN_LONG ",$data);
            if($len > 4) {
                 my $val = unpack("x4 C",$data);
                 $val = chr($val);
                 push @a,$val;
            }
            if($len > 5) {
                my $remain_data = substr($data,5); 
                for(1..2) {
                     if(length($remain_data)==0) { last;}
                     my $str = unpack("C/a",$remain_data);
                     push @a, $str;
                     $remain_data = substr($remain_data,1+length($str) );
                }
            }
            #print "MRR:", join "|",@a;
            #print "\n";
        }
         # SDR
        elsif($typ == 1 && $sub == 80){ 
        #   read($fh,$data,$len);
            @a = unpack("C2 ",$data);
            my @sites = unpack("xxC/C",$data);
            #push @a,join ",",@sites;
            push @a,scalar(@sites),[@sites];
            my $remain_data = substr($data,2+ 1 + scalar(@sites));
            for(1..16) {
                if(length($remain_data) == 0) { last;}
                my $str = unpack("C/a",$remain_data);
                push @a,$str;
                $remain_data = substr($remain_data,1+length($str));
            }
            # print "Sites: ",join ",",@sites;
            # print "\n";
            # print join "|",@a;
            #print "\n";
           
            
        }
        #HBR or SBR
        elsif($typ == 1 && ($sub == 40 || $sub ==50)) {
        #   read($fh,$data,$len);
            @a = unpack("C2 $UNSIGN_SHORT $UNSIGN_LONG C",$data);
        #   print ($sub ==40 ? "Hbin":"Sbin");
        #   print " : length:$len\n";
            if($len> 9) { my $name = unpack("x9 C/a",$data); push @a,$name; }
            
            #print join "|",@a;
            #print "\n";
        }
        # PCR
        elsif($typ == 1 && $sub ==30) {
        #   read($fh,$data,$len);
            @a = unpack("CC ${UNSIGN_LONG}5",$data);
        #   print join "|",@a; 
        #   print "\n";
            
        }
        # PMR
        elsif($typ == 1 && $sub == 60) {
            @a = unpack("${UNSIGN_SHORT}2 (C/a)3 CC",$data);
        }
        # PGR
        elsif($typ == 1 && $sub == 62) {
            @a = unpack("${UNSIGN_SHORT} C/a",$data);
            my $consumed = length($a[1])+1 + 2;
            my @pmr_indx = unpack("x${consumed} $UNSIGN_SHORT /$UNSIGN_SHORT ",$data);
           # print "PMR: ",join "|",@pmr_indx;
           # print "\n";
            push @a,[@pmr_indx];
        }
        # TSR
        elsif($typ == 10 && $sub ==30) {
        #    read($fh,$data,$len);
            @a = unpack("C3 ${UNSIGN_LONG}4",$data);
            $a[2] = chr($a[2]);
            my $consumed_len = 19;
            my $val;
            if($consumed_len < $len )
            {
                $val = unpack("x${consumed_len} C/a",$data);
                $consumed_len += length($val) + 1;
                push @a,$val;
            }
            if($consumed_len < $len )
            {
                $val = unpack("x${consumed_len} C/a",$data);
                $consumed_len += length($val) + 1;
                push @a,$val;
            }
            if($consumed_len < $len )
            {
                $val = unpack("x${consumed_len} C/a",$data);
                $consumed_len += length($val) + 1;
                push @a,$val;
            }
            for my $item ( "${BIT}8",$REAL,$REAL,$REAL,$REAL,$REAL) {
                if($consumed_len >= $len) { last; }
                $val = unpack("x${consumed_len} $item",$data);
                push @a,$val;
                $consumed_len += $size_table{$item};
            }
        }
      # records not implemented yet..
     else {
            # return raw data so client might have a chance to parse it
            return [$name,$typ,$sub,$data];
       }
       #unshift @a,$RECORDS{$typ}{$sub};
       unshift @a,$name;
       return [@a];
       
       #return [@a];
    }
    close($fh) if($own_fh);
    if(!defined($n)) {
        die "Read Error in parsing\n";
    }
#   return [@output];
    return undef;
    };
    my $obj = {
        CPU_TYPE   => $cpu,
        STDF_VER   => $stdf_ver,
        _PARSER    => $parser,
        BYTES_READ => \$num_bytes_read,
        REC_NUM    => \$rec_num,
    };
    bless($obj,$class);
    return $obj;
}

sub bytes_read
{
    my $self = shift;
    my $ref_num_bytes = $self->{BYTES_READ};
    return $$ref_num_bytes;
}

sub rec_num
{
    my $self = shift;
    my $ref_rec_num = $self->{REC_NUM};
    return $$ref_rec_num;
}
sub stream
{
    my $self = shift;
    return $self->{_PARSER};
}

sub cpu_type
{
    my $self = shift;
    return $self->{CPU_TYPE};
}

sub stdf_ver
{
    my $self = shift;
    return $self->{STDF_VER};
}

## essential methods
#  get_record  -> returns record/undef if no more
#  record - mir,sdr, ..,  implements record.
#  record methods - type, typ,sub, len,raw_data,raw_header

## performance matters... unpacking each field by sub call too high cost
#  required fixed fields must be unpacked in one call...

# Record factory 
# new factory($info) - info contains FAR, some other info..that is applicable for all records
# factory->new($binary_str) -> STDF::record (mir,sdr,...)
1;

