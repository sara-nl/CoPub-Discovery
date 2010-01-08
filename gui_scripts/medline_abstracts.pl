#!/usr/bin/perl -w
#$Id: medline_abstracts.pl 157 2007-02-14 17:03:53Z bart1 $
use FindBin;                # where was script installed?
use lib $FindBin::Bin;      # use that dir for common lib, too
use warnings;
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Ajax;
use DBI;
use Data::Dumper;
use IO::File;
use strict;
use CGI::Session;
use File::stat;
use Literature::CopubBI;
use Literature::LitStat;
use Literature::GenericObject;
use common;
my $query = new CGI;

my $pjx   = new CGI::Ajax( 'get_medline_data' => \&common::get_medline_data );

#$pjx->JSDEBUG(2);
print $pjx->build_html( $query, \&Show_HTML, {-charset=>'UTF-8'} );

sub Show_HTML {
  
  my $html_string = $query->start_html(-title=>$common::TITLE
                                     , -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"}
                                     , -encoding=>'UTF-8'
                                     , -script=>{-language=>'JAVASCRIPT',
                                       -src=>"$FULL_DOCS_URL/js/copub.js"}
                                      );                                        
 
  $html_string .= &common::top();
  
  my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                          { 'RaiseError' => 1 } );
  
  my $BI1 = $query->param('id1');
  my $BI2 = $query->param('id2');
  my $type = $query->param('type');
  my $mode = 0;
  
  
  my %copub_results;
  my $count=0;
  
  my $Retrieve_pubmed_id = $dbh->prepare("SELECT A.literature_id FROM Literature_biologicalitem AS A, Literature_biologicalitem AS B WHERE A.biologicalitem_id = ? AND B.biologicalitem_id = ? AND A.literature_id=B.literature_id ORDER BY A.literature_id DESC LIMIT 500");
  $Retrieve_pubmed_id->execute($BI1,$BI2);
	
  while ( my $Retrieve_pubmed_id_ref = $Retrieve_pubmed_id->fetchrow_hashref() ) {
	
	  my $literature_id = $Retrieve_pubmed_id_ref->{"literature_id"};
	  $copub_results{'copub'}->[$count]=$literature_id;
          $count++;
  }
     
   my $lit_stat_id1_id2 = &common::get_litstats_for_ids($BI1,$BI2,$dbh);
   
   my $R_scaled_id1_id2 = $lit_stat_id1_id2->{R_scaled};
   my $lit_count_id1_id2 = $lit_stat_id1_id2->{literature_count};
   
   my $id1_attributes = &common::get_bi_attributes($BI1,$dbh);
   my $id2_attributes = &common::get_bi_attributes($BI2,$dbh);
   
   my $id1_name = $id1_attributes->{preferred_name};
   my $id2_name = $id2_attributes->{preferred_name};
 
   if($id1_attributes->{category} eq 'gene') {
	   
	   my $symbol = $id1_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $id1_name = $id1_name . " (" . $symbol . ")";
	   }
   }
	
   $id1_name=~s/&&/, /g;
   
   if($id2_attributes->{category} eq 'gene') {
	   
	   my $symbol = $id2_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $id2_name = $id2_name . " (" . $symbol . ")";
	   }
   }
	
   $id2_name=~s/&&/, /g;
   
   my $prefix1="Node A:";
   my $prefix2="Node B:";
   
   if($type eq 'BC') {
   
      $prefix1="Node B:";
      $prefix2="Node C:";     
   }
   
   if($type eq 'AC') {
   
      $prefix1="Node A:";
      $prefix2="Node C:";     
   }
 
   $html_string .= "<BR/>
                    <table width=100% border=0 cellspacing=1>
                    <tr>
                    <td colspan=3 class=h2>Co-publication results</td>
                    </tr>
                    <tr><td colspan=3 height=20 /></td>
                    </tr>";

   
   $html_string .= "<table width=100% border=0 cellspacing=1>
	            <tr>
	            <td width=20 align=left><font face=Verdana size=3></td>
                    <td width=830 align=left valign=top><b><font face=Verdana size=2><b>$prefix1 $id1_name</td>
                    <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                    </tr></table><BR>";
	   
   $html_string .= "<table width=100% border=0 cellspacing=1>
                    <tr>
	            <td width=20 align=left><font face=Verdana size=3></td>
                    <td width=830 align=left valign=top><b><font face=Verdana size=2><b>$prefix2 $id2_name</td>
                    <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                    </tr></table><BR>";
   
  
   $html_string .= "<table width=100% border=0 cellspacing=1>
                    <tr>
                    <td width=20 align=left><font face=Verdana size=3></td>
                    <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Number of co-publications: $lit_count_id1_id2</td>
                    <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                    </tr>
                    <tr>
                    <td width=20 align=left><font face=Verdana size=3></td>
                    <td width=830 align=left valign=top><b><font face=Verdana size=2><b><i>R</i>-scaled score: $R_scaled_id1_id2</td>
                    <td width=100 align=left valign=top><font face=Verdana size=2></td>	
                    </tr> 
                    </table><BR/>";   
 
   $html_string .= "<table width=100% border=0 cellspacing=1>
                     <tr><td colspan=3 height=20></td></tr>
                     <tr>
                     <td colspan=3>Click on the + image to retrieve the abstract from <a href=\"http://www.ebi.ac.uk\" target='_blank'>EMBL-EBI</a> 
                     and highlight the terms, or click the PubMed ID to open the abstract in a external window for <a href=\"http://www.ebi.ac.uk\" target='_blank'>EMBL-EBI</a>.
                    </td>
                    </tr>
                    <tr><td height=10 /></td>
                    <tr>  
                    </tr>";

 if($lit_count_id1_id2 > 500) {
  
  $html_string .= "<tr>
                   <td colspan=2 class=h2>Medline abstracts*</td>
                   </tr>
                   <tr><td colspan=2 height=20 /></td></tr>   
                   <tr>
                   <td colspan=2>* Number of abstracts is limited to the 500 most recent published abstracts.</td>
                   </tr>
                   <tr><td colspan=2 height=20 /></td></tr>
                   <tr>
                   <td colspan=2>Please be patient when clicking on the + image to retrieve Medline abstract from EMBL-EBI.</td>
                   </tr>      
                   <tr><td colspan=2 height=10 /></td></tr>
                   </table>";
 }else
 {

   $html_string .= "<tr>
                    <td colspan=2 class=h2>Medline abstracts</td>
                     </tr>   
                    <tr><td colspan=2 height=20 /></td></tr>
                    <tr>
                    <td colspan=2>Please be patient when clicking on the + image to retrieve Medline abstract from EMBL-EBI.</td>
                    </tr>     
                    <tr><td colspan=2 height=10 /></td></tr></table>";
 }

 $html_string .= "<BR/>
                  <table border=0 cellspacing=1>";
  

  my %abstracts;
  
  foreach my $pubmed_identifier ( @{$copub_results{'copub'}})
  {
    $abstracts{$pubmed_identifier} = &common::get_medline_abstract_info($dbh, $pubmed_identifier);
  }

  my $abstract_count = 0;
  
  foreach my $pubmed_identifier (sort { $abstracts{$b}->{"year"} <=> $abstracts{$a}->{"year"} } keys %abstracts)
  {
    my $title   = $abstracts{$pubmed_identifier}->{'title'};
    my $authors = $abstracts{$pubmed_identifier}->{'authors'};
    my $info    = $abstracts{$pubmed_identifier}->{'info'};
    $title =~ s/]/./;
    $title =~ s/^\[//;

    my $name_pubmed   = "name_" . $pubmed_identifier;
    my $abstract_pubmed = "abstract_" . $pubmed_identifier;
    my $title_pubmed = "title_" . $pubmed_identifier;
    my $img_pubmed = "img_" . $pubmed_identifier;
    my $value = join('|', ($pubmed_identifier, $BI1, $BI2, $mode));
    $abstract_count++;
    
    if($abstract_count > $common::MAX_ABSTRACTS) {
      mmon
      $html_string .= "<tr>
                       <td colspan=5 align-center>More then $common::MAX_ABSTRACTS abstracts selected. The rest will not be shown...
                       </td>
                       <tr>";
      last; 
    } else {
      $html_string .= "<tr>
                       <td width=5\% align=left valign=top>
                       <input type=\"hidden\" ID='$name_pubmed' value = '$value' />
                       <img src='$FULL_DOCS_URL/images/false.png' ID='$img_pubmed' alt='show abstract'
                       onClick=\"get_medline_data( ['$name_pubmed'], [toggleAbstract] );\"/>
                       </td>
                       <td width=10\% align=left valign=top>
                       <B><a href=\"@{[&common::medline_external($pubmed_identifier)]}\" 
                        target='_blank'>$pubmed_identifier</a></B>
                       </td>
                       <td width=85\% align=left valign=top>
                       <table border=0 cellspacing=4>
                       <tr><td style=\"font-weight:bold\"><div id=\"$title_pubmed\">$title</div></td></tr>
                       <tr><td><div id=\"$abstract_pubmed\" /></td></tr>
                       <tr><td>$authors</td></tr>
                       <tr><td>$info</td></tr>        
                       </table>
                       </td>   
                       </tr>
                      <tr><td colspan=3 height=4 /></tr>";    
    }
  }
    
  $html_string .= "</table>"; 
  $html_string .= $query->end_html;

  return $html_string;
}
