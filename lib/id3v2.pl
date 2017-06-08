#!/usr/bin/perl
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use MPEG::ID3v2Tag;
use IO::File;
use Getopt::Long;

sub print_help{
   my $prog_name=$_[0];
   my $exit_status=$_[1];

   print "Create an ID3v2 file with TXXX and/or TIT2 tags. \n";
   print "Usage : $prog_name [-h] -o <output> -p <providerId> -a <assetId> <-txxx|-title> \n";
   print "$prog_name -o test.id3 -p test.com -a ad0 -title \n";
   print "$prog_name -o test.id3 -p test.com -a ad0 -txxx \n";

   exit $exit_status;
}

sub main(){
	my $help = '';
    my $output = '';
    my $providerid = '';
    my $assetid = '';
    my $txxx = '';
    my $title = '';

	GetOptions('help|h' => \$help,
               'output|o=s' => \$output,
               'providerid|p=s' => \$providerid,
               'assetid|a=s' => \$assetid,
               'txxx' => \$txxx,
               'title' => \$title);

    #print "output = " . $output . "\n";
    #print "provider Id = " . $providerid . "\n";
    #print "asset Id = " . $assetid . "\n";

	if ($help){
		print_help($0, "0");
	}

	if ($output eq "" or \
        $providerid eq "" or \
        $assetid eq "") {
		print "Bad parameters. \n";
		print_help($0, "-1");
	}

	#Create a tag
	$tag = MPEG::ID3v2Tag->new();
	if ($title){
        $tag->add_frame("TIT2", "$providerid/$assetid") ;
    }
	if ($txxx){
        $tag->add_frame("TXXX", "" , "", "$providerid/$assetid") ;
    }

    $tag->set_padding_size(1);

    open(my $file , '>', $output) or die "Error opening outpout file '$output' $!";
	print $file $tag->as_string();
    close($file);
}

main();
