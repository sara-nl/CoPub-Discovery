#!/usr//bin/perl

use common;
use warnings;
use CGI qw/:standard/;
use DBI;
use Data::Dumper;
use strict;
use IO::File;
use Getopt::Long;
use CGI::Session;
use Literature::ImplicitRelations::ImplicitRelation;
use Literature::ImplicitRelations::ImplicitRelationsSet;


my $id;

GetOptions ("id=s" => \$id);

my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

my $session = new CGI::Session( "driver:MySQL", $id, { Handle => $dbh } );

my $A_node = $session->param("A_node");
my $C_node;
my $C_category_selection;
my $show_relationships_type;
my $order_by;
my $IR_threshold;

my $mode = $session->param("mode");

if($mode eq 'closed') {

   $C_node = $session->param("C_node");
}

if($mode eq 'open') {

   $C_category_selection = $session->param("c_category_selection");
   $order_by = $session->param("order_by");
   $IR_threshold = $session->param("IR_threshold");
   $show_relationships_type = $session->param("show_relationships");
   
   if($C_category_selection==1) {
   
      $C_category_selection=23;
   }
   
}

my $literature_threshold_B_node = $session->param("lit_threshold");
my $R_scaled_threshold_B_node = $session->param("R_threshold");
my $threshold_intermediate_count = $session->param("intermediate_threshold");
my $intermediate_selection = $session->param("intermediate_selection");

my @B_categories;

if($intermediate_selection eq 'genes') {

   push(@B_categories,1);

}else
{
   push(@B_categories,1,26);

}


my $implicit_relationships_set;

 
if($mode eq 'closed') {
 
   $implicit_relationships_set = &common::get_inferred_relationships(dbh=>$dbh,
                                                                     A_node => $A_node,
                                                                     B_categories => \@B_categories,
  							             C_node => $C_node,
								     literature_count_threshold_B_node => $literature_threshold_B_node,
						                     R_scaled_threshold_B_node => $R_scaled_threshold_B_node,
							             threshold_intermediate_count => $threshold_intermediate_count,
								    );

}else
{

   my $show_number_raw = $session->param("show_number");
 
   my %show_number_hash =('All' => 100,
                          '10' => 10,
		          '15' => 15,
		          '20' => 20,
		          '25' => 25,
		          '30' => 30,
		          '35' => 35,
		          '40' => 40,
		          '50' => 50,
                         );
  
   my $show_number = $show_number_hash{$show_number_raw}; 
   
   
   $implicit_relationships_set = &common::get_inferred_relationships(dbh=>$dbh,
                                                                     A_node => $A_node,
                                                                     B_categories => \@B_categories,
  							             C_category_id => $C_category_selection,
 						                     literature_count_threshold_B_node => $literature_threshold_B_node,
						                     R_scaled_threshold_B_node => $R_scaled_threshold_B_node,
							             threshold_intermediate_count => $threshold_intermediate_count,
								     show_relationships_type => $show_relationships_type,
								     order_by=>$order_by,
								     IR_threshold=>$IR_threshold, 
							             top_scoring=>$show_number
								    );
 
}


$session->param("implicit_relationships_set", $implicit_relationships_set);



my $finish_file = "finish_" . $id . ".txt";
open( OUT, "> $TMP_DIR/$finish_file" ) || die "can't open $finish_file";
print OUT "finished: " . $id;
close(OUT);
