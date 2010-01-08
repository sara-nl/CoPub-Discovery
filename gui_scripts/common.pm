package common;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($TMP_DIR $IMAGES_URL $VERSION $MOT $STYLE_URL $DOCS_URL $TITLE $FULL_TMP_DIR $FULL_HTTP $SCRIPT_URL);
use vars qw($DB_CONNECT_STRING $DB_USER $DB_PASSWORD $DB_LIKE $CGI $INSTALL $FULL_DOCS_URL $MAX_ABSTRACTS);
use Exporter;
use Time::localtime;
use Time::Local;
use File::stat;

@ISA = qw(Exporter);
@EXPORT = qw($TMP_DIR $SCRIPT_DIR $DOCS_URL $TITLE $DB_CONNECT_STRING $DB_USER $DB_PASSWORD $SCRIPT_URL $FULL_DOCS_URL);
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

$TMP_DIR="/tmp";
$TMP_SVG_DIR="/tmp";

#$DB_CONNECT_STRING="DBI:mysql:database=copub_sara;host=web.irc.sara.nl";
#$DB_CONNECT_STRING="DBI:mysql:database=copub_sara;host=127.0.0.1;port=3307";
$DB_CONNECT_STRING="DBI:mysql:database=copub_200907;host=localhost;port=3307;mysql_socket=/opt/mysql-5.1/var/mysql.sock";
$DB_USER="copub";
$DB_PASSWORD="bupco";

#my $development;
my $installation = (
    defined( $ENV{'REQUEST_URI'} ) && $ENV{'REQUEST_URI'} =~ /cgi-bin\/(.*)\//
  ) ? $1 : 'develsara';

$RUNNING_MODE = (
    $installation=~m/sara/
  ) ? 'sara' : 'public';
$SCRIPT_DIR = "/var/www/cgi-bin/$installation";
# $SCRIPT_DIR may not be a symbolic link:
$SCRIPT_DIR = `readlink -nf '$SCRIPT_DIR'`;
die "readlink failed: $!" if ($? >> 8);
$SCRIPT_URL = "http://services.nbic.nl/cgi-bin/$installation";
$DOCS_URL = "http://services.nbic.nl/copub/$installation";


$TITLE = "CoPub Discovery";

$VERSION = '1.0beta 2009-12-14';

$MOT = 'Based on Medline abstracts till August 2009';

$MAX_ABSTRACTS = 500;

my $installation2 = $installation;

$installation2=~s/cd.*$//;

$FULL_DOCS_URL = "http://services.nbic.nl/copub/$installation2";

#$FULL_HTTP = "http://iris.oss.intra/cgi-bin/copub_discovery";


sub top {
        
  my $header = qq|  
<div align="center">
  <table border="0" cellspacing="0" width="100\%" cellpadding="0">
    <tr>
      <td width="20\%" bgcolor="#0094D9" align=center valign="middle">
       <a href="http://www2.cmbi.ru.nl/groups/computational-drug-discovery/introduction" target="_blank"><img border="0" src="$FULL_DOCS_URL/images/logo_cmbi.jpg" alt="CMBI logo"/></a>
      </td>
      <td width="60\%" bgcolor="#0094D9" align=center>
        <img border="0" src="$FULL_DOCS_URL/images/copub_discovery_logo.gif"/>
      </td>
      <td width="20\%" bgcolor="#0094D9" align=center valign="middle">
        <a href="http://www.sara.nl" target="_blank"><img border="0" src="$FULL_DOCS_URL/images/logo_sara1.gif" alt="SARA logo"/></a>
      </td>
    </tr>
    <tr bgcolor="#0094D9">
      <td align="left" valign="top">&nbsp;&nbsp;
      </td>
      <td align="center" valign="top"><font size="2" color="#FFFFFF"><b>$MOT</b></font></td>
      <td align="center" valign="top"height=20><font size="2" color="#FFFFFF"><b>Version $VERSION</b></font></td>
    </tr>
    <tr bgcolor="#0094D9">
      <td align="center" valign="top" height=5></td>
      <td align="center" valign="top" height=5></td>
      <td align="center" valign="top" height=5></td>
    </tr>
  </table>
</div>|;

  return $header;

}

sub navigation {
   
   my $html = qq|
 <table border="0" cellspacing="0" width="100\%" cellpadding="0">
    <tr>
      <td width="100\%">
         <div align="center">
	 <div id="nav-menu">
          <ul>
          <li><a href="cd.pl?rm=home">Home</a></li>
          <li><a href="cd.pl?rm=input&mode=closed&sid=x">Closed Discovery</a></li>
          <li><a href="cd.pl?rm=input&mode=open&sid=x">Open Discovery</a></li>
          </ul>
        </div>
      </td>
     </tr>
 </table>|;
 
  return $html;
}

sub title {
   
   my ($mode)=@_;
   
   my $discovery_mode = "Closed Discovery";

   if($mode eq 'open') {
   
      $discovery_mode = "Open Discovery";
   }
 
   my $html = qq|
                 <BR>
		 <div align=center>
                 <table border=0 bordercolor=#808080 cellspacing=1 width=100\%>
                 <tr>
                 <td width=100% bgcolor=#0094D9 align=center class=h2><B>$discovery_mode</b></td>
                 </tr>
		 </table><BR>|;
  
  return $html;
}

sub input {
   
   my ($q,$mode,$error_message)=@_;
   
   my $input='';
   
   if($mode eq "open") {
   
    $input .= "<td width=50\% valign=top>
                         <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td width=100% bgcolor=#0094D9 align=center class=h3><B>Input</b></td>
			  </tr>
			  <tr>
			  <td width=100% height=10></td>
			  </tr>
			  <tr>
                          <td width=100% align=center><img border=0 src=\"$FULL_DOCS_URL/images/open_discovery.jpg\"/></td>
			  </tr>
			  <tr>
			  <td width=100% align=center><BR><input type=\"button\" name=\"example_open\" id=\"example_open\" value=\"Use Example\" onclick=\"fillExample()\">&nbsp;&nbsp;&nbsp;&nbsp;</td>
			  </tr>
			  <tr>
			  <td class=h1><BR><center><B>Enter a gene or biological term A*</B><BR>
                          </td>
		          </tr>
			     <tr> 
			     <td align=center>
			     <input type=radio id=A_node_category_selection_gene name=A_node_category_selection value=gene> Gene
			     <input type=radio id=A_node_category_selection_keyword name=A_node_category_selection value=keyword> Biological term</td>
			     </tr>
			  <tr>
			  <td class=h1><BR><center>";

    $input .= $q->textfield(-name=>'keyword_A',
		            -id=>'keyword_A',
			    -default=>'',
		            -size=>30,
		            -maxlength=>'50');
   
    $input .= "    </center>
                          </td>
		          </tr>
			  </table>
			  <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td height=20></td>
			  </tr>
			  <tr>
			  <td align=center>
		      ";

  } 
 
  if($mode eq "closed") {

    $input .= "<td width=50\% valign=top>
                         <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td width=100% bgcolor=#0094D9 align=center class=h3><B>Input</b></td>
			  </tr>
			  <tr>
			  <td width=100% height=10></td>
			  </tr>
			  <tr>
                          <td width=100% align=center><img border=0 src=\"$FULL_DOCS_URL/images/closed_discovery.jpg\"/></td>
                          </tr>
			  <tr>
			  <td width=100% align=center><BR><input type=\"button\" name=\"example_closed\" id=\"example_closed\" value=\"Use Example\" onclick=\"fillExample()\">&nbsp;&nbsp;&nbsp;&nbsp;</td>
			  </tr>
			 </table>
			 <table border=0 cellspacing=0 width=100\%> 
			  <tr>
			  <td class=h1><BR><center><B>Enter a gene or biological term A*</B><BR>
			     <input type=radio id=A_node_category_selection_gene name=A_node_category_selection value=gene> Gene
			     <input type=radio id=A_node_category_selection_keyword name=A_node_category_selection value=keyword> Biological term
			     <BR><BR>";

    $input .= $q->textfield(-name=>'keyword_A',
		            -id=>'keyword_A',
			    -default=>'',
		            -size=>30,
		            -maxlength=>'50');
   
    $input .= "    </center>";
			  
			  
    $input .= "   </td>
			  <td class=h1><BR><center><B>Enter a gene or biological term C*</B><BR>
			     <input type=radio id=C_node_category_selection_gene name=C_node_category_selection value=gene> Gene
			     <input type=radio id=C_node_category_selection_keyword name=C_node_category_selection value=keyword> Biological term
			     <BR><BR>";

    $input .= $q->textfield(-name=>'keyword_C',
                            -id=>'keyword_C',
		            -default=>'',
		            -size=>30,
		            -maxlength=>'50');
   
    $input .= "    </center>";
			  
			  
    $input .= "	  </td>
			  </tr>   
			  </table>
			  <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td height=20></td>
			  </tr>
			  <tr>
			  <td align=center>
		      ";


   }

			  
   $input .= $q->submit(-value=>'Search in database'); 
 
   $input .= "<input type=\"button\" name=\"blank\" id=\"blank\" value=\"Reset\" onclick=\"reset_values()\">"; 			  
			  
   $input .= "</td></tr>
                        <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td height=25></td>
			  </tr>
			  <tr>
			  <td align=center><input type=\"text\" id=\"error_message\" size=70 style=\"border:0px solid #000000;text-align:center;color:red;font-family:arial;font-weight:bold;font-size:11pt;\" value=\"$error_message\"\></td>
			  </tr>
                        </table>
			<table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td height=25></td>
			  </tr>
			  <tr>
			  <td align=left>*Human genes (full name or symbol), biological processes, pathways, diseases, drugs or pathologies.</td>
			  </tr><tr>
			  <td height=5></td>
			  </tr>
			  <tr>
			  <td align=left><a href=\"info_r_scaled_score.pl\" target=\"_blank\">**Click here for info on <i>R</i>-scaled and Inferred <i>R</i>-scaled score</a></td>
			  </tr>
                        </table>
                        </td>";
   return $input;
}   

sub settings {
   
   my ($q,$mode)=@_;
   
   my $settings = "<td width=50\% valign=top>
                         <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td width=100% bgcolor=#0094D9 align=center class=h3><B>Settings</b></td>
			  </tr>
			 </table> 
			 <table border=0 cellspacing=0 width=100\%>
			    <tr>
			     <td class=h1 height=15></td>
			     <td class=h1 height=15></td>
			     <td class=h1 height=15></td>
			    </tr>
			    <tr>
			     <td class=h1 width=22 align=left></td>
			     <td class=h1 width=350 align=left><B>B Intermediates</B></td>
			     <td class=h1 width=28></td>
			    </tr>
			    <tr>
			     <td class=h1 width=22 align=left></td>
			     <td class=h1 width=350 align=left><input type=radio id=intermediate_selection_genes name=intermediate_selection value=genes> Genes</td>
			     <td class=h1 width=28></td> 
			    </tr>
			    <tr>
			     <td class=h1 width=22 align=left></td>
			     <td class=h1 width=350 align=left><input type=radio id=intermediate_selection_genes_bioproc name=intermediate_selection value=genes_bioproc> Genes, Biological Processes and Pathways</td>
			     <td class=h1 width=28></td>
			    </tr>
			  </table>";
  if($mode eq "open") {
			  
	$settings .=	 "<table border=0 cellspacing=0 width=100\%>
			    <tr>
			     <td height=15></td>
			     <td height=15></td>
			     <td height=15></td>
			    </tr>
			    <tr>
			     <td width=22 align=left></td>
			     <td class=h1 width=225 align=left><B>C Biomedical Concept Category</B></td>
			     <td class=h1 width=153 align=left></td>
			    </tr>
			    <tr>
			     <td width=22 align=left></td>
			     <td class=h1 width=200 align=left><input type=radio id=c_category_selection_1 name=c_category_selection value=1> Genes</td>
			     <td class=h1 width=178 align=left><input type=radio id=c_category_selection_2 name=c_category_selection value=2> Pathologies</td> 
			    </tr>
			    <tr>
			     <td width=22 align=left></td>
			     <td class=h1 width=200 align=left><input type=radio id=c_category_selection_5 name=c_category_selection value=5> Biological Processes</td>
			     <td class=h1 width=178 align=left><input type=radio id=c_category_selection_3 name=c_category_selection value=3> Diseases</td>
			    </tr>
			    <tr>
			     <td width=22 align=left></td>
			     <td class=h1 width=200 align=left><input type=radio id=c_category_selection_9 name=c_category_selection value=9> Pathways</td>
			     <td class=h1 width=178 align=left><input type=radio id=c_category_selection_11 name=c_category_selection value=11> Drugs</td> 
			    </tr>
			  </table>";
  }			  
			  
       $settings .=	 "<table border=0 cellspacing=0 width=100\%>
			    <tr>
			     <td height=15></td>
			     <td height=15></td>
			     <td height=15></td>
			    </tr>
			    <tr>
			     <td class=h1 width=24 align=left></td>
			     <td class=h1 width=240 align=left><B>B Intermediates Inclusion Criteria</B></td>
			     <td class=h1 width=136 align=left</td>
			    </tr>
			    <tr>
			     <td width=24 align=left></td>
			     <td width=250 align=left>Minimal number of co-publications:</td>
			     <td width=126 align=left>";
			     
	$settings .= 	$q->popup_menu(-name=>'lit_threshold',
                                       -id=>'lit_threshold',
				       -values=>['1','2','3','4','5'],
			               -default=>'3',
			               -rows=>2);	     
			     
	$settings .=	   "</td>
			    </tr>
			    <tr>
			     <td width=24 align=left></td>
			     <td width=250 align=left>Minimal <i>R</i>-scaled score**:</td>
			     <td width=126 align=left>";
	
	$settings .=    $q->popup_menu(-name=>'R_threshold',
                                       -id=>'R_threshold',
				       -values=>['20', '30', '35'],
			               -default=>'20',
			               -rows=>2);
			     
	$settings .=	   "</td>
			    </tr>
			    <tr>
			     <td width=24 align=left></td>
			     <td width=250 align=left>Minimal number of intermediates:</td>
			     <td width=126 align=left>";
			     
	$settings .= $q->popup_menu(-name=>'intermediate_threshold',
                                    -id=>'intermediate_threshold',
				    -values=>['1', '5', '10'],
			            -default=>'5',
			            -rows=>2);
	
	$settings .=	   "</td>
			    </tr>
			    <tr>
			     <td height=15></td>
			     <td height=15></td>
			     <td height=15></td>
			    </tr>";
			    
  if($mode eq "open") {	
 		    
	$settings .= 	   "<tr>
			     <td width=24 align=left></td>
			     <td width=250 align=left>Inferred <i>R</i>-scaled score threshold**:</td>
			     <td width=126 align=left>";
	
	$settings .= $q->popup_menu(-name=>'IR_threshold',
                                    -id=>'IR_threshold',
				    -values=>['None','30','31','32','33','34','35','36','37','38'],
                                    -default=>'32',
                                    -rows=>2); 
			     
	$settings .=	   "</td>
			    </tr>
	                    <tr>
			    <td width=24 align=left></td>
			    <td width=250 align=left>Show:</td>
			    <td width=126 align=left>";
			    
	$settings .= $q->popup_menu(-name=>'show_relationships',
                                    -id=>'show_relationships',
				    -values=>['Only unknown relationships', 'Known and unknown relationships'],
                                    -default=>'Only unknown relationships',
                                    -rows=>2);	 		    
			     
	$settings .=	   "</td>
			    </tr>			    
	                    <tr>
			    <td width=24 align=left></td>
			    <td width=250 align=left>Order by:</td>
			    <td width=126 align=left>";
	
	$settings .= $q->popup_menu(-name=>'order_by',
                                    -id=>'order_by',
				    -values=>['Inferred R-scaled score', 'Number of B-intermediates'],
                                    -default=>'Inferred R-scaled score',
                                    -rows=>2);	     
			     
	$settings .=	   "</td>
			    </tr>		    
			    <tr>
			     <td width=24 align=left></td>
			     <td width=250 align=left>Show top:</td>
			     <td width=126 align=left>";
			     
	$settings .= $q->popup_menu(-name=>'show_number',
                                    -id=>'show_number',
				    -values=>['All', '10', '15', '20', '25', '30', '35', '40', '45', '50'],
			            -default=>'50',
			            -rows=>2);
	
	$settings .=	    "</td>
			    </tr>";
			    
}			    
			    
	$settings .=	"</table> 
                       </td>";	
  
  return $settings;
}

sub db_output {
   
   my ($q,$mode,$A_ref,$C_ref,$sid)=@_;
   
   
   my $db_output='';

   
   $db_output .= "<td width=50\% valign=top>
                         <table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td width=100% bgcolor=#0094D9 align=center class=h3><B>Retrieved biological terms</b></td>
			  </tr>
			  <tr>
     			  <td width=100% height=10></td>
			  </tr>";
   if($mode eq "open") {
   
     $db_output .= "<tr>
                       <td width=100% align=center><img border=0 src=\"$FULL_DOCS_URL/images/open_discovery.jpg\"/></td>
                    </tr>";
   
   }else
   {
   
     $db_output .= "<tr>
                       <td width=100% align=center><img border=0 src=\"$FULL_DOCS_URL/images/closed_discovery.jpg\"/></td>
                     </tr>";   
       
   }			  
			  
     $db_output .= "<tr>
     		    <td width=100% height=2></td>
		    </tr>
		    <tr>
		    <td class=h1><BR><center><B>Select node A</B><BR></td>
		    </tr></table><BR>";
   
   $db_output .="<div align='center'>
                 <div style='background:#fff;width:40em;overflow:auto;height:5.5em;border-left:0px solid #404040;border-top:0px solid #404040;border-bottom:0px solid #d4d0c8;border-right:0px solid #d4d0c8;text-align:left;'>\n";
   
   my $count=1;                  			  
    			  
   my %hash_A;
   my @array_A;
   my @array_sort_A; 
     
     foreach my $A_BI (keys %{$A_ref}) { #sort { lc{$a} cmp lc{$b} } 
	
	my $term = $$A_ref{$A_BI}->{preferred_name};
	$term=~s/&&/, /g;
	$term="\L$term"; 
	
	if($$A_ref{$A_BI}->{category_id}==23) {
	
	   my $symbol = $$A_ref{$A_BI}->{symbol};
	   $term .= " (" . $symbol . ")";
	}
      
        if($term ne '') {

	$hash_A{$term}=$A_BI;
        push(@array_A,$term);
        
	}
     }
     
     @array_sort_A = sort { lc($a) cmp lc($b) } @array_A;
 
     foreach my $term (@array_sort_A) {
     	
	my $A_BI = $hash_A{$term};
	
	my $selected='';
	
	if($count==1) {
	
	  $selected="checked"; 
	
	}   
	
	$db_output .= "<label for='A_" . $A_BI . "' style='padding-right:3px;display:block;'><input name='A_radio[]' value='" . $A_BI . "' type='radio' id='A_" . $A_BI . "' " . $selected . ">" . $term . "</label>\n";
        
	$count++;
     }
     
    $db_output .= "</div>";
                      

    if($mode eq "closed") {
			 			  
    $db_output .= "<table border=0 cellspacing=0 width=100\%>
                          <tr>
     			  <td width=100% height=5></td>
			  </tr>
			  <tr>
			  <td class=h1><BR><center><B>Select node C</B><BR></td>
			  </tr></table><BR>";
   
    $db_output .="<div align='center'>
                  <div style='background:#fff;width:40em;overflow:auto;height:5.5em;border-left:0px solid #404040;border-top:0px solid #404040;border-bottom:0px solid #d4d0c8;border-right:0px solid #d4d0c8;text-align:left;'>\n";
   
    my %hash_C;
    my @array_C;
    my @array_sort_C; 
    my $count2=1;                  			  
    			  
     foreach my $C_BI (keys %{$C_ref}) {
	
	my $term = $$C_ref{$C_BI}->{preferred_name};
	$term=~s/&&/, /g;
	$term="\L$term"; 
	
	if($$C_ref{$C_BI}->{category_id}==23) {
	
	   my $symbol = $$C_ref{$C_BI}->{symbol};
	   $term .= " (" . $symbol . ")";
	}
     
        if($term ne '') {
     
        $hash_C{$term}=$C_BI;
        push(@array_C,$term);
	
	}
     }	
	
     @array_sort_C = sort { lc($a) cmp lc($b) } @array_C;
 
     foreach my $term (@array_sort_C) {
     	
	my $C_BI = $hash_C{$term};	
	
	my $selected='';
	
	if($count2==1) {
	
	  $selected="checked"; 
	
	}   
	
	$db_output .= "<label for='C_" . $C_BI . "' style='padding-right:3px;display:block;'><input name='C_radio[]' value='" . $C_BI . "' type='radio' id='C_" . $C_BI . "' " . $selected . ">" . $term . "</label>\n";
        
	$count2++;
     }			  
    
    $db_output .= "</div>
                  ";
    
   } 
			  
   $db_output .= "<table border=0 cellspacing=0 width=100\%>
                          <tr>
     			  <td width=100% height=10></td>
			  </tr>
		  </table>";	  
   
   $db_output .= $q->submit(-value=>'Start hidden relationship analysis');  
    
   my $option_redefine_keyword;
   my $location;
   
   if($mode eq 'open') {
   
      $option_redefine_keyword = "Redefine keyword";
      $location = "cd.pl?rm=input&mode=open&sid=$sid";
      
   }else
   {
   
     $option_redefine_keyword = "Redefine keywords";
     $location = "cd.pl?rm=input&mode=closed&sid=$sid";
   } 
                  
   $db_output .= "<input type=\"button\" name=\"redefine_keyword\" id=\"redefine_keyword\" value=\"$option_redefine_keyword\" onclick=\"parent.location='$location'\">";
			 
   $db_output .= "<br><table border=0 cellspacing=0 width=100\%>
			  <tr>
			  <td height=20></td>
			  </tr>
			  <tr>
			  <td align=left><a href=\"info_r_scaled_score.pl\" target=\"_blank\">**Click here for info on <i>R</i>-scaled and Inferred <i>R</i>-scaled score</a></td>
			  </tr>
                        </table></td>";
   
   return $db_output;
} 

sub javascript {

 my ($mode,$rm,$sid,$dbh)=@_;

 my $javascript="";
 my $code_init="";
 my $code_example="";
 my $code_reset="";
 my $functions="";

 my $session;														           
 my $intermediate_selection="genes";
 my $intermediate_selection_set="intermediate_selection_" . $intermediate_selection;
 my $intermediate_threshold=5;
 my $lit_threshold=3;
 my $R_threshold=20;
 my $show_relationships="Only unknown relationships";
 my $order_by="Inferred R-scaled score";
 my $IR_threshold=32;
 my $show_number=50;
 my $c_category_selection=1;
 my $c_category_selection_set="c_category_selection_1";
 my $A_node_category_selection="gene";
 my $A_node_category_selection_set="A_node_category_selection_gene";
 my $C_node_category_selection="keyword";
 my $C_node_category_selection_set="C_node_category_selection_keyword";
 my $keyword_A="";
 my $keyword_C="";
   

 if($sid ne "x") {
   
   # $session = new CGI::Session(undef, $sid, {Directory=>"$FULL_TMP_DIR"});

    $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );
    
    $intermediate_selection = $session->param('intermediate_selection');
    $intermediate_selection_set = "intermediate_selection_" . $intermediate_selection;
    $intermediate_threshold = $session->param('intermediate_threshold');
    $lit_threshold = $session->param('lit_threshold');
    $R_threshold = $session->param('R_threshold');
    $A_node_category_selection = $session->param('A_node_category');
    $A_node_category_selection_set="A_node_category_selection_" . $A_node_category_selection;
    $keyword_A = $session->param('keyword_A');
    
    if($mode eq 'open') {
    
       $show_relationships = $session->param('show_relationships');
       $show_number = $session->param('show_number');
       $order_by = $session->param('order_by');
       $IR_threshold = $session->param('IR_threshold');
       $c_category_selection = $session->param('c_category_selection');
       $c_category_selection_set = "c_category_selection_" . $c_category_selection;       
    
    }else
    {
       $C_node_category_selection = $session->param('C_node_category');
       $C_node_category_selection_set="C_node_category_selection_" . $C_node_category_selection;
       $keyword_C = $session->param('keyword_C');
    }
 
 }

 
 if($mode eq 'open') {
 
  
    $code_init .= "document.getElementById(\"$intermediate_selection_set\").checked = \"$intermediate_selection\";
                   document.getElementById(\"$c_category_selection_set\").checked = $c_category_selection;
		   document.getElementById(\"lit_threshold\").value = \"$lit_threshold\";
                   document.getElementById(\"R_threshold\").value = \"$R_threshold\";
		   document.getElementById(\"intermediate_threshold\").value = \"$intermediate_threshold\";
                   document.getElementById(\"show_relationships\").value = \"$show_relationships\";
		   document.getElementById(\"order_by\").value = \"$order_by\";
		   document.getElementById(\"IR_threshold\").value = \"$IR_threshold\";
                   document.getElementById(\"show_number\").value = \"$show_number\";";
 
   if($rm eq 'input') {
   
      $code_init .= "document.getElementById(\"$A_node_category_selection_set\").checked = \"$A_node_category_selection\";
                     document.getElementById(\"keyword_A\").value = \"$keyword_A\";";  
   }
   
   $code_example .= "document.getElementById(\"keyword_A\").value = \"ABCA1\";
                     document.getElementById(\"A_node_category_selection_gene\").checked = \"gene\";
		     document.getElementById(\"intermediate_selection_genes\").checked = \"genes\";
                     document.getElementById(\"c_category_selection_3\").checked = 3;
		     document.getElementById(\"lit_threshold\").value = \"3\";
                     document.getElementById(\"R_threshold\").value = \"20\";
		     document.getElementById(\"intermediate_threshold\").value = \"5\";
                     document.getElementById(\"show_relationships\").value = \"Only unknown relationships\";
		     document.getElementById(\"order_by\").value = \"Inferred R-scaled score\";
		     document.getElementById(\"IR_threshold\").value = \"34\";
		     document.getElementById(\"show_number\").value = \"30\";
		     document.getElementById(\"error_message\").innerText = \"\";";
  
   $code_reset .=   "document.getElementById(\"keyword_A\").value = \"\";
                     document.getElementById(\"A_node_category_selection_gene\").checked = \"gene\";
		     document.getElementById(\"intermediate_selection_genes\").checked = \"genes\";
                     document.getElementById(\"c_category_selection_1\").checked = 1;
		     document.getElementById(\"lit_threshold\").value = \"3\";
                     document.getElementById(\"R_threshold\").value = \"20\";
		     document.getElementById(\"intermediate_threshold\").value = \"5\";
                     document.getElementById(\"show_relationships\").value = \"Only unknown relationships\";
		     document.getElementById(\"order_by\").value = \"Inferred R-scaled score\";
		     document.getElementById(\"IR_threshold\").value = \"32\";
		     document.getElementById(\"show_number\").value = \"30\";
		     document.getElementById(\"error_message\").innerText = \"\";";
		     	     
 
 }else
 {
    
    $code_init .= "document.getElementById(\"$intermediate_selection_set\").checked = \"$intermediate_selection\";
                   document.getElementById(\"lit_threshold\").value = \"$lit_threshold\";
                   document.getElementById(\"R_threshold\").value = \"$R_threshold\";
		   document.getElementById(\"intermediate_threshold\").value = \"$intermediate_threshold\";
		   ";
 
    if($rm eq 'input') {
   
       $code_init .= "document.getElementById(\"$A_node_category_selection_set\").checked = \"$A_node_category_selection\";
                      document.getElementById(\"$C_node_category_selection_set\").checked = \"$C_node_category_selection\";
		      document.getElementById(\"keyword_A\").value = \"$keyword_A\";
		      document.getElementById(\"keyword_C\").value = \"$keyword_C\";";  
    }
    
    $code_example .= "document.getElementById(\"keyword_A\").value = \"ABCA1\";
                      document.getElementById(\"keyword_C\").value = \"cholesterol metabolism\";
		      document.getElementById(\"A_node_category_selection_gene\").checked = \"gene\";
		      document.getElementById(\"C_node_category_selection_keyword\").checked = \"keyword\";
		      document.getElementById(\"intermediate_selection_genes\").checked = \"genes\";
		      document.getElementById(\"lit_threshold\").value = \"3\";
                      document.getElementById(\"R_threshold\").value = \"20\";
		      document.getElementById(\"intermediate_threshold\").value = \"5\";
		      document.getElementById(\"error_message\").innerText = \"\";";
		      
    $code_reset .=   "document.getElementById(\"keyword_A\").value = \"\";
                      document.getElementById(\"keyword_C\").value = \"\";
		      document.getElementById(\"A_node_category_selection_gene\").checked = \"gene\";
		      document.getElementById(\"C_node_category_selection_keyword\").checked = \"keyword\";
		      document.getElementById(\"intermediate_selection_genes\").checked = \"genes\";
		      document.getElementById(\"lit_threshold\").value = \"3\";
                      document.getElementById(\"R_threshold\").value = \"20\";
		      document.getElementById(\"intermediate_threshold\").value = \"5\";
		      document.getElementById(\"error_message\").innerText = \"\";";	       
 }
 
 
  $functions .= "function init() 
                 {
		  $code_init
                 }\n\n";
  
  if($rm eq 'input') {
 
     $functions .= "function fillExample()
                    {
                    $code_example
                    }\n\n";
		    
     $functions .= "function reset_values()
		    {
		    $code_reset
		    }\n\n"; 
 
  }
 
 $javascript .= "<script type=\"text/javascript\" language=\"JavaScript\">
                 <!--\n\n";
                     
 $javascript .= $functions;
 $javascript .= "\n\n//-->
                 </script>";

 return $javascript;

}


sub get_inferred_relationships {

   my (%args)=@_;
   my $dbh = $args{dbh};
   my $literature_count_threshold_B_node = $args{literature_count_threshold_B_node} || 3;
   my $R_scaled_threshold_B_node =  $args{R_scaled_threshold_B_node} || 30;
   my $threshold_intermediate_count = $args{threshold_intermediate_count} || 10;
   my $litstat_table = $args{litstat_table} || "bi_bi_litstat_discovery";
   my $A_BI = $args{A_node};
   my @B_categories = @{$args{B_categories}};
   my $C_category_id = $args{C_category_id} || 0;
   my $top_scoring = $args{top_scoring} || 30;
   my $order_by = $args{order_by} || "Inferred R-scaled score";
   my $IR_threshold = $args{IR_threshold} || 32;
   my @C_categories;
   my $C_BI = $args{C_node} || 0;
   my $show_relationships_type = $args{show_relationships_type} || "Known and unknown relationships"; # or "Only unknown relationships"
   my $B_gene_check=0;
   my $B_other_category_check=0;
   my $intermediate_type;
   my $intermediate_concat;
     
   foreach my $category_id (@B_categories) {
     
     if($category_id==1) {
        
	$B_gene_check=1;
     
     }else
     {
        $B_other_category_check=1;
     }
   
   }
   
   my %selected_C_nodes;
   my %inferred_relationships;
   if($B_gene_check==0 && $B_other_category_check==1) {
      $intermediate_type = "_1_26_";
      $intermediate_concat = "(23,26)";
   }
   if($B_gene_check==1 && $B_other_category_check==0) {
      $intermediate_concat = "(23)";
      $intermediate_type = "_1_";
   }
   if($B_gene_check==1 && $B_other_category_check==1) {
      $intermediate_concat = "(23,26)";
      $intermediate_type = "_1_26_";
   }
   
    
    my $sort="rs_min";
    
    if($order_by eq "Number of B-intermediates") {
    
       $sort = "nr_b";
    }
    
    if($IR_threshold eq "None") {
    
       $IR_threshold=1;
    }
   
    my $copub_discovery_query_open="SELECT * FROM (
                                    SELECT 
                                         ab.biologicalitem_id1 id_a
                                       , avg((ab.R_scaled+cb.R_scaled)/2) rs_avg
                                       , avg(least(ab.R_scaled,cb.R_scaled)) rs_min
                                       , GROUP_CONCAT(ab.biologicalitem_id2) ids_b
                                       , cb.biologicalitem_id1 id_c
                                       , COUNT(ab.biologicalitem_id2) nr_b
                                    FROM 
                                         $litstat_table ab,
                                         $litstat_table cb
                                    WHERE 
                                         ab.biologicalitem_id2=cb.biologicalitem_id2
                                         AND
                                         cb.cat_b IN $intermediate_concat
                                         AND
                                         ab.biologicalitem_id1=$A_BI 
                                         AND 
                                         cb.cat_a_c=$C_category_id 
                                         AND 
                                         ab.literature_count >= $literature_count_threshold_B_node 
                                         AND 
                                         cb.literature_count >= $literature_count_threshold_B_node 
                                         AND 
                                         ab.R_scaled >= $R_scaled_threshold_B_node 
                                         AND 
                                         cb.R_scaled >= $R_scaled_threshold_B_node
                                         GROUP BY id_a, id_c
                                         HAVING nr_b >= $threshold_intermediate_count
					 AND rs_min >= $IR_threshold
                                  ) h
                                  ORDER BY $sort DESC";


   my $copub_discovery_query_closed="SELECT 
                                         ab.biologicalitem_id1 id_a
                                       , avg((ab.R_scaled+cb.R_scaled)/2) rs_avg
                                       , avg(least(ab.R_scaled,cb.R_scaled)) rs_min
                                       , GROUP_CONCAT(ab.biologicalitem_id2) ids_b
                                       , cb.biologicalitem_id1 id_c
                                       , COUNT(ab.biologicalitem_id2) nr_b
                                     FROM 
                                         $litstat_table ab,
                                         $litstat_table cb
                                     WHERE 
                                         ab.biologicalitem_id2=cb.biologicalitem_id2
                                         AND
                                         cb.cat_b IN $intermediate_concat
                                         AND
                                         ab.biologicalitem_id1=$A_BI 
                                         AND 
                                         cb.biologicalitem_id1=$C_BI
                                         AND 
                                         ab.literature_count >= $literature_count_threshold_B_node 
                                         AND 
                                         cb.literature_count >= $literature_count_threshold_B_node 
                                         AND 
                                         ab.R_scaled >= $R_scaled_threshold_B_node 
                                         AND 
                                         cb.R_scaled >= $R_scaled_threshold_B_node
                                         GROUP BY id_a, id_c
                                         HAVING nr_b >= $threshold_intermediate_count";


  
   my $copub_discovery_query = $copub_discovery_query_open;
   
   if($C_BI!=0) {
   
      $copub_discovery_query = $copub_discovery_query_closed;
      
   }
  
   my $results = $dbh->prepare($copub_discovery_query);
   $results->execute();

   my $known_query="SELECT literature_count, R_scaled FROM bi_bi_litstat WHERE biologicalitem_id1=? AND biologicalitem_id2=?";
   my $known = $dbh->prepare($known_query);

   my %inferred_relationships_results;
   
   my $unknown_count=0;
   my $total_count=0;
   
   while (my $res = $results->fetchrow_hashref()) {
          my @ids_b;
          @ids_b=split(',',$res->{'ids_b'});
          my $id_c=$res->{'id_c'};
          my $min_inferred=sprintf("%.1f", $res->{'rs_min'});
          my $avg_inferred=sprintf("%.1f", $res->{'rs_avg'});
      
          my $known_R_scaled = 0;
          my $known_literature_count = 0;
          my $relationship_type = "Unknown";
      
      if($A_BI!=$id_c) {
      
          $known->execute($A_BI,$id_c);
       
          if ($known->rows != 0) {
        
	      my $ref = $known->fetchrow_hashref();
              $known_R_scaled = $ref->{'R_scaled'};
              $known_literature_count = $ref->{'literature_count'};
              $relationship_type="Known";
        
	  }else
	  {
	  
	      $unknown_count++;
	      
	      if($show_relationships_type eq "Only unknown relationships" && $unknown_count<=$top_scoring) { 
     
                my $inferred_relationship = Literature::ImplicitRelations::ImplicitRelation->new(A_node_id => $A_BI,
                                                                                                 B_node_ids => \@ids_b,
                                                                                                 C_node_id => $id_c,
                                                                                                 relationship_type => $relationship_type,
                                                                                                 intermediate_count => scalar @ids_b,
                                                                                                 B_node_literature_count_threshold=> $literature_count_threshold_B_node,
                                                                                                 B_node_R_scaled_threshold=> $R_scaled_threshold_B_node,
                                                                                                 intermediate_type => $intermediate_type,
                                                                                                 known_R_scaled_score => $known_R_scaled,
                                                                                                 known_literature_count => $known_literature_count,
                                                                                                 avg_inferred_R_scaled_score => $avg_inferred,
                                                                                                 min_inferred_R_scaled_score => $min_inferred);
                $inferred_relationships{$res->{'id_c'}}=$inferred_relationship;
              }   
	  }
	  
	  $total_count++;
     
          if($show_relationships_type eq "Known and unknown relationships" && $total_count<=$top_scoring) { 
     
                my $inferred_relationship = Literature::ImplicitRelations::ImplicitRelation->new(A_node_id => $A_BI,
                                                                                                 B_node_ids => \@ids_b,
                                                                                                 C_node_id => $id_c,
                                                                                                 relationship_type => $relationship_type,
                                                                                                 intermediate_count => scalar @ids_b,
                                                                                                 B_node_literature_count_threshold=> $literature_count_threshold_B_node,
                                                                                                 B_node_R_scaled_threshold=> $R_scaled_threshold_B_node,
                                                                                                 intermediate_type => $intermediate_type,
                                                                                                 known_R_scaled_score => $known_R_scaled,
                                                                                                 known_literature_count => $known_literature_count,
                                                                                                 avg_inferred_R_scaled_score => $avg_inferred,
                                                                                                 min_inferred_R_scaled_score => $min_inferred);
                $inferred_relationships{$res->{'id_c'}}=$inferred_relationship;
          } 
   
      }
   }
   
   
   $inferred_relationships_results{$A_BI} = \%inferred_relationships;
   my $inferred_relations_set = Literature::ImplicitRelations::ImplicitRelationsSet->new(InferredRelations => \%inferred_relationships_results);
   
   return $inferred_relations_set;
}

sub get_biologicalitem_ids_symbols_for_string {
    
    my ($string,$category,$db_cp)=@_;
    
    my %bi_ids;
   					 			 
    
    my $category_id = "(23)";
    
    if($category eq "keyword") {
    
       $category_id = "(5,9,2,3,18)";
    }
    
    my $sth=$db_cp->prepare(qq/select distinct t1.biologicalitem_id, t2.stringvalue, t3.category_organism_id
                               from Biologicalitem_strings as t1,
                               Strings as t2,
                               Biologicalitem as t3,
			       Category as t4
                               where t1.string_id=t2.string_id
                               and t1.biologicalitem_id=t3.biologicalitem_id
			       and t3.category_id=t4.category_id
                               and t2.stringvalue LIKE ? AND t3.category_organism_id IN $category_id/);
    
    $sth->execute("%".$string."%");
    
    while(my $href=$sth->fetchrow_hashref){
        
          my $BI_object = get_bi_attributes($href->{biologicalitem_id},$db_cp);
        
          my $keyword_object = Literature::GenericObject->new(biologicalitem_id=>$href->{biologicalitem_id},
	                                                      category_id=>$href->{category_organism_id},
                                                              preferred_name=>$BI_object->{preferred_name},
						              symbol=>$BI_object->{symbol}
	  				     	             );
    
        $bi_ids{$href->{biologicalitem_id}} = $keyword_object;
    }
    
    
    return \%bi_ids;
}

sub check_string_in_DB {

    my ($string,$category,$db_cp)=@_;
    
    my $check; 
          
    my $category_id = "(23)";
    
    if($category eq "keyword") {
    
       $category_id = "(5,9,2,3,18)";
    }
    
    my $sth=$db_cp->prepare(qq/select distinct t1.biologicalitem_id, t2.stringvalue, t3.category_organism_id
                               from Biologicalitem_strings as t1,
                               Strings as t2,
                               Biologicalitem as t3,
			       Category as t4
                               where t1.string_id=t2.string_id
                               and t1.biologicalitem_id=t3.biologicalitem_id
			       and t3.category_id=t4.category_id
                               and t2.stringvalue LIKE ? AND t3.category_organism_id IN $category_id/);
    
    $sth->execute("%".$string."%");
    
    if($sth->rows==0){
        
       $check=0;
       
    }else
    {
    
      $check=1;
    }    

    return $check;
}

sub get_bi_attributes {

    my ($node_BI,$dbh)=@_;

    my $sth=$dbh->prepare(qq/select t2.stringvalue, t1.biologicalitem_stringtype_id 
		             from Biologicalitem_strings as t1, Strings as t2
			     where t1.biologicalitem_id=$node_BI 
			     and t1.string_id=t2.string_id
		        /);
    my $pref_name='';
    my $symbol='';
    my @alt_names;
    
    $sth->execute;
    while (my $href=$sth->fetchrow_hashref){
	   push @alt_names,$href->{stringvalue} if $href->{biologicalitem_stringtype_id} == 2;
	   $pref_name=$href->{stringvalue} if $href->{biologicalitem_stringtype_id} == 1;
	   $symbol=$href->{stringvalue} if $href->{biologicalitem_stringtype_id} == 3;
    }
    
    
    my $sth2=$dbh->prepare(qq/select t2.category 
			      from Biologicalitem as t1, Category as t2
			      where t1.biologicalitem_id=$node_BI
			      and t1.category_id=t2.category_id
		         /);
    my $category;
    
    $sth2->execute;
    while (my $href=$sth2->fetchrow_hashref){
	   $category=$href->{category};
    }
    
    my $sth3=$dbh->prepare(qq/select entrezgene_id
			      from Biologicalitem_entrezgene
			      where biologicalitem_id=?
		         /);
    my $EG_id;
    
    $sth3->execute($node_BI);
    while (my $href=$sth3->fetchrow_hashref){
	   $EG_id=$href->{entrezgene_id};
    }
    
    my $BI=Literature::CopubBI->new(id=>$node_BI,
                                    EG_id=>$EG_id,
				    category=>$category,
				    preferred_name=>$pref_name,
				    alternative_names=>\@alt_names,
				    symbol=>$symbol);
    return $BI;

}

sub get_litstats_for_ids {

     my ($id1,$id2,$dbh)=@_;

     my $href=$dbh->selectrow_hashref(qq/select * 
                                         from bi_bi_litstat
					 where biologicalitem_id1 = $id1
					 and biologicalitem_id2 =  $id2
			             /);

     return Literature::LitStat->new(%$href) if $href;

     warn ("No co-citations found for $id1 and $id2");
     return undef;

}


sub set_property {
  my ($dbh, $id, $property, $value) = @_;
  my $sql = qq|insert into  property(id, property, value, ts) 
               values ('$id', '$property', '$value', now()) 
           on duplicate key update value='$value', ts=now()|;
  return $dbh->do($sql);
}

sub get_property {
  my ($dbh, $id, $property) = @_;
  my @row_ary = $dbh->selectrow_array(qq|SELECT value from property where id="$id" and property="$property"|);
  return @row_ary ? $row_ary[0] : undef;
}
   
  
sub get_medline_abstract_info {
  
  my ($dbh, $pubmed_identifier) = @_;
  my $Retrieve_abstract =
    $dbh->prepare("SELECT title,create_date,journal_title,volume,issue,page,authors FROM LiteratureFn WHERE literature_id = $pubmed_identifier");
  $Retrieve_abstract->execute();
  my $ref_abstract  = $Retrieve_abstract->fetchrow_hashref();
  my $title         = $ref_abstract->{'title'};
  my $create_date   = $ref_abstract->{'create_date'};
  my $journal_title = $ref_abstract->{'journal_title'};
  my $volume        = $ref_abstract->{'volume'};
  my $page          = $ref_abstract->{'page'};
  my $authors;

  if ( exists $ref_abstract->{'authors'} ) {
    $authors = $ref_abstract->{'authors'};
    $authors =~ s/;/, /g;
    $authors =~ s/, $/./;
  } else {
    $authors = "Authors not known";
  }

  my $issue;
  if ( exists $ref_abstract->{'issue'} ) {
    $issue = "(" . $ref_abstract->{'issue'} . ")";
  } else {
    $issue = "";
  }
  my $year = $create_date;
  $year =~ s/-[0-9][0-9]-[0-9][0-9]$//;
  my $month = $create_date;
  $month =~ s/-[0-9][0-9]$//;
  $month =~ s/^[0-9][0-9][0-9][0-9]-//g;
  my $create_date_edit = "$year " . $common::MAP_MONTH{$month};
  my $info             =
     $journal_title . ". "
    . $create_date_edit . ", "
    . $volume
    . $issue . ", "
    . $page;
  my %result = (     
    'title'   => $title,
    'info'    => $info,
    'authors' => $authors,
    'year'    => $year
  );
  $Retrieve_abstract->finish();
  return \%result;
}

sub get_medline_data {
  my $data         = shift;
  return '' if !$data or $data eq '';
  return ($data, '', '') if(index($data, '|') < 0);
  my ($pubmed_id, $gene_bi, $link_bi, $gene_selection) = split('\|', $data);
  
  my $dbh =
    DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
    { 'RaiseError' => 1 } );
  my $ref = &common::get_medline_abstract($dbh, $pubmed_id);   

############################################################################
# The following block uses the original string  positions to find the 
# the hits. That will also find any hits based on regular expressions 
# 
# !!! First retrieve all the hit sequences from the abstract /title , then
# # replace every thing !!! Otherwise you will replace items that have already been replaced.   
#
#
  
  my $gene_bi_concat="(";
  my $link_bi_concat="(";
  
  if($gene_selection==0) {
  
     $gene_bi_concat.=$gene_bi.")";
     $link_bi_concat.=$link_bi.")";
  
  }else
  {
  
     $gene_bi_concat.=$gene_bi.",";

     my $BI_ortho_retrieve = $dbh->prepare("SELECT ortho_biologicalitem_id FROM bi_gene_ortho WHERE biologicalitem_id=$gene_bi");
     $BI_ortho_retrieve->execute();
     
     if($BI_ortho_retrieve->rows!=0) {
     
        while (my $BI_ortho_retrieve_ref = $BI_ortho_retrieve->fetchrow_hashref()) {  
  
               $gene_bi_concat.=$BI_ortho_retrieve_ref->{'ortho_biologicalitem_id'}.",";  
     
        }
     }
     
     $gene_bi_concat=~s/,$/)/;
     
     ### check whether link_bi is a gene
     
     my $link_bi_check = $dbh->prepare("SELECT category_id FROM Biologicalitem WHERE biologicalitem_id=$link_bi");
     $link_bi_check->execute();
     my $link_bi_check_ref = $link_bi_check->fetchrow_hashref();
     
     if($link_bi_check_ref->{'category_id'}==1) {
     
        $link_bi_concat.=$link_bi.",";

        my $BI_ortho_retrieve = $dbh->prepare("SELECT ortho_biologicalitem_id FROM bi_gene_ortho WHERE biologicalitem_id=$link_bi");
        $BI_ortho_retrieve->execute();
     
        if($BI_ortho_retrieve->rows!=0) {
     
            while (my $BI_ortho_retrieve_ref = $BI_ortho_retrieve->fetchrow_hashref()) {  
  
                   $link_bi_concat.=$BI_ortho_retrieve_ref->{'ortho_biologicalitem_id'}.",";  
     
            }
        }
     
        $link_bi_concat=~s/,$/)/;
     
     
     }else
     {
     
        $link_bi_concat.=$link_bi.")";
     }
     
  }
  
  
  my  $sql_gene_id = qq|SELECT DISTINCT string_id FROM Biologicalitem_strings WHERE biologicalitem_id IN $gene_bi_concat|;  
  my @gene_string_ids = db_get_list($dbh, $sql_gene_id);
  
  my $sql_link_id = qq|SELECT DISTINCT string_id FROM Biologicalitem_strings WHERE biologicalitem_id IN $link_bi_concat|;  
  my @link_string_ids = db_get_list($dbh, $sql_link_id);

  my @title_gene_hits = ();
  my @abstract_gene_hits = ();
  my @title_link_hits = ();
  my @abstract_link_hits = ();

  foreach my $string_id( @gene_string_ids) {
    my ($title_hits_ref, $abstract_hits_ref) = 
      &get_hits($dbh, $pubmed_id, $string_id,  $ref->{title},  $ref->{abstract});    
     push( @title_gene_hits,  keys %$title_hits_ref);
     push( @abstract_gene_hits,  keys %$abstract_hits_ref);
  }
  foreach my $string_id( @link_string_ids) {
    my ($title_hits_ref, $abstract_hits_ref) = 
      &get_hits($dbh, $pubmed_id, $string_id,  $ref->{title},  $ref->{abstract});    
    push( @title_link_hits,  keys %$title_hits_ref);
    push( @abstract_link_hits,  keys %$abstract_hits_ref);
  }  

  foreach my $hit (@title_gene_hits) {
    $hit =~ s/([\\\|\(\)\[\]\{\}\^\$\*\+\?\.])/\\$1/g;
    my $colored_string = "<span class=hit_a>$hit</span>"; 
    $ref->{title}=~s/$hit/$colored_string/g; 
  }
  foreach my $hit (@abstract_gene_hits) {
    $hit =~ s/([\\\|\(\)\[\]\{\}\^\$\*\+\?\.])/\\$1/g;
    my $colored_string = "<span class=hit_a>$hit</span>"; 
    $ref->{abstract}=~s/$hit/$colored_string/g; 
  }
  foreach my $hit (@title_link_hits) {
    $hit =~ s/([\\\|\(\)\[\]\{\}\^\$\*\+\?\.])/\\$1/g;
    my $colored_string = "<span class=hit_b>$hit</span>"; 
    $ref->{title}=~s/$hit/$colored_string/g; 
  }
  foreach my $hit (@abstract_link_hits) {
    $hit =~ s/([\\\|\(\)\[\]\{\}\^\$\*\+\?\.])/\\$1/g; 
    my $colored_string = "<span class=hit_b>$hit</span>"; 
    $ref->{abstract}=~s/$hit/$colored_string/g; 
  }

  return ($pubmed_id, $ref->{title}, $ref->{abstract});
}


sub get_medline_abstract {
  my ($dbh, $pubmed_id) = @_;
  
  my $ref;
  if($RUNNING_MODE eq 'sara') {
    my $Retrieve_abstract =
      $dbh->prepare(qq|SELECT abstract,title,create_date,journal_title,volume,issue,page,authors 
                       FROM LiteratureFn WHERE literature_id = $pubmed_id|);
		       
    $Retrieve_abstract->execute();
    $ref  = $Retrieve_abstract->fetchrow_hashref();
    if ( exists $ref->{'authors'} ) {
      $ref->{'authors'} =~ s/;/, /g;
      $ref->{'authors'} =~ s/, $/./;
    } else {
      $ref->{'authors'} = "Authors not known";
    }
    my $abstract;
    if ( ! exists $ref->{'abstract'} ) {
      $ref->{'abstract'} = "No abstract available";
    }
    my $issue;
    if ( exists $ref->{'issue'} ) {
      $ref->{'issue'}  = "(" . $ref->{'issue'} . ")";
    } else {
      $ref->{'issue'} = "";
    }
    my $year = $ref->{'create_date'};
    $year =~ s/-[0-9][0-9]-[0-9][0-9]$//;
    my $month = $ref->{'create_date'};
    $month =~ s/-[0-9][0-9]$//;
    $month =~ s/^[0-9][0-9][0-9][0-9]-//g;
    $ref->{'create_date'} = "$year " . $common::MAP_MONTH{$month};
  } else {
    require 'SOAPServices.pm';
    SOAPServices->import();
    $ref = &SOAPServices::get_medline_abstract($pubmed_id);
  }    
  return $ref;
}

%MAP_MONTH = (
  "01" => "Jan",
  "02" => "Feb",
  "03" => "Mar",
  "04" => "Apr",
  "05" => "May",
  "06" => "Jun",
  "07" => "Jul",
  "08" => "Aug",
  "09" => "Sep",
  "10" => "Oct",
  "11" => "Nov",
  "12" => "Dec"
);


sub get_hits {
  my ($dbh, $pubmed_id, $string_id, $title, $abstract) = @_;
  my %title_hits_item;
  my %abstract_hits_item;
  my $Retrieve_hit =
  $dbh->prepare("SELECT string_occurence_count 
                 FROM Literature_string 
                 WHERE literature_id = $pubmed_id AND string_id=$string_id");
  
  $Retrieve_hit->execute();
  
  if ( $Retrieve_hit->rows != 0 ) {
  
       my $Retrieve_string = $dbh->prepare("SELECT stringvalue,regexp_id 
                                            FROM Strings 
                                            WHERE string_id=$string_id");
  
       $Retrieve_string->execute();
       my $ref_string  = $Retrieve_string->fetchrow_hashref();
       my $string = $ref_string->{'stringvalue'}; 
       my $regexptype = $ref_string->{'regexp_id'};
       
       #lowercase
       $string=lc($string);
       #Remove all spaces before
       $string =~ s/^\s+//;
       #Remove all spaces after
       $string =~ s/\s+$//;

       #symbol transform
       if ($regexptype==2) {
           #Remove all things that can be interpreted as a metacharaters in regexps
           $string =~ s/[\.\+\'\*\[\]\(\)\?\$\|\{\}\^\@]//g;
           #Remove all dashes
           $string =~ s/-//g;
           #Place new dashes
           my $tmptmp = substr($string,0,2);
           for(my $i=2;$i<length($string);$i++) {
               $tmptmp .= '-?'.substr($string,$i,1);
           }
            $string = $tmptmp;
       #non-symbol transform
       } else {
         #Escape all things that can be interpreted as a metacharacters in regexps
         $string =~ s/([\.\+\'\*\[\]\(\)\?\$\|\{\}\^\@])/\\$1/g;
    
         #replace && 
         #only non-symbols have && so we do it here
         
	 #No && then string is returned unmodified.
         if($string=~/&&/) {
         
	 my @string_parts=split('&&',$string);
  
         if (@string_parts==2) {
    
             $string = '(?:(?:'
                      .$string_parts[0].',? '.$string_parts[1]
                      .')|(?:'
                      .$string_parts[1].',? '.$string_parts[0]
                      .'))';  
               # dont do swapping of string_parts when there are 2x && or 3 string parts
               # as it causes a slowdown from 5:40 to 8:30 for 100 abstracts
               #  } elsif (@string_parts=3) {
         } elsif (0) {
            
	    $string = '(?:(?:'
                      .$string_parts[0].',? '.$string_parts[1].',? '.$string_parts[2]
                      .')|(?:'
                      .$string_parts[0].',? '.$string_parts[2].',? '.$string_parts[1]
                      .')|(?:'
                      .$string_parts[1].',? '.$string_parts[0].',? '.$string_parts[2]
                      .')|(?:'
                      .$string_parts[1].',? '.$string_parts[2].',? '.$string_parts[0]
                      .')|(?:'
                      .$string_parts[2].',? '.$string_parts[0].',? '.$string_parts[1]
                      .')|(?:'
                      .$string_parts[2].',? '.$string_parts[1].',? '.$string_parts[0]
                      .'))';
        } else {
           #too many && to swap parts around
           $string = join(',? ',@string_parts);
        }
	
        }
         
         #Replace all whitespaces and dashes with [\s-]
         $string =~ s/\s|-/[\\s-]/g;
	 #add optional 's', to fake plural 
	 $string.='s?'; 
      }
    
    
    #title
    
       while ($title=~m/$string/gi) {
    
              my $start_pos = $-[0];
	      my $stop_pos = $+[0]+1; 
    
              my $string_length = length($title);
              my $left_edge_hit_index  = $start_pos - $string_length;
              my $right_edge_hit_index = $stop_pos - $string_length;
              my $string_preceding_hit = substr( $title, 0, $start_pos ); 
              my $string_following_hit = substr( $title, $stop_pos - 1 );
              my $search_string_length = $stop_pos - $start_pos - 1;
              my $search_string = substr( $title, $left_edge_hit_index, $search_string_length );
              $title_hits_item{$search_string}++;
       }
    
    #abstract
    
       while ($abstract=~m/$string/gi) {
    
              my $start_pos = $-[0];
	      my $stop_pos = $+[0]+1;
  
              my $string_length = length($abstract);
              my $left_edge_hit_index  = $start_pos - $string_length;
              my $right_edge_hit_index = $stop_pos - $string_length;
              my $string_preceding_hit = substr( $abstract, 0, $start_pos );
              my $string_following_hit = substr( $abstract, $stop_pos - 1 );
              my $search_string_length = $stop_pos - $start_pos - 1;
              my $search_string = substr( $abstract, $left_edge_hit_index, $search_string_length );
              $abstract_hits_item{$search_string}++;
      
      }
  
  }
  return (\%title_hits_item, \%abstract_hits_item);
}

sub medline_external {
  my ($pubmed_identifier) = @_;
  return "http://srs.ebi.ac.uk/srsbin/cgi-bin/wgetz?-page+EntryPage+[MEDLINE:$pubmed_identifier]+-view+MedlineFull";
}

sub db_get_list {
  my ($dbh, $query) = @_;
  my @elements; 
  my $sth = $dbh->prepare($query);
  $sth->execute();
  while ( my $ref = $sth->fetchrow_arrayref() ) {
    my $el = $ref->[0];  
      push( @elements, $el);
  }
  return @elements;
}



1;



