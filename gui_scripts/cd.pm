package cd;


use lib '/home/verhoes/lib/perl5/';
use common;
use warnings;
use CGI qw/:standard/;
use DBI;
use Data::Dumper;
use CGI::Session;
use base CGI::Application;
use strict;
use IO::File;
use Getopt::Long;
use File::stat;
use Time::Local;
use Time::localtime;
use Literature::CopubBI;
use Literature::LitStat;
use Literature::GenericObject;
use Data::Dumper;

my $cgi_query = new CGI;

sub read_input
{
    our ($buffer, @pairs, $pair, $name, $value, %FORM);

    $buffer = $ENV{'QUERY_STRING'};

    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $FORM{$name} = $value;
    }
    %FORM;
}

sub setup {
     
     my $self = shift;
     $self->start_mode('home');
     $self->mode_param('rm');
     $self->run_modes(
                      # Menu items
                      home     => 'home',
                      input    => 'input_form',
		      ires     => 'intermediates_results',
                      pro      => 'progress',
                      que      => 'queue',
                      res      => 'results',
		      DBsearch => 'concept_DB_search',		
                      DBres    => 'concept_DB_search_results',
		      save     => 'save'
		      );
}

# --------------------------------------------------------------------------------------------------
# Input

sub home {
   
   my $q=new CGI;

   my $html_string = $q->start_html(-title=>$common::TITLE,
                                    -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"});
     
   $html_string .= &common::top();
   
   $html_string .= &common::navigation();

   $html_string .= "<BR><div align=center>
          <table border=0 bordercolor=#808080 cellspacing=1 width=100\%>
                 <tr>
                 <td width=100% bgcolor=#0094D9 align=center class=h2><B>CoPub Discovery description</b></td>
                 </tr>
		 </table>
	  <table border=0 cellspacing=0 width=100% id=AutoNumber1 cellpadding=0>
          <tr>
          <td colspan=3 align=left><font face=Arial size=2><br>
          <p>CoPub* is a text mining tool that detects co-occuring biomedical concepts in abstracts from the <a href=\"http://medline.cos.com/\" target=\"_blank\">Medline</a> literature database. 
             The biomedical concepts included in CoPub are all human, mouse and rat genes, furthermore biological processes, molecular functions and cellular components from Gene Ontology,
             and also liver pathologies, diseases, drugs and pathways. Altogether more than 250,000 search strings are 
             linked with CoPub.</p>
	  <p>Co-occurrence-based methods can also be used to discover new, hidden relationships, assuming that if A and C both are connected with B, A and C might also have a relationship, 
	     even if there is no direct relationship between A and C (see figure below). Hidden literature relationships can be used to confirm a hypothesis about a relationship 
	     between A and C in a so called closed discovery process or to generate, possibly many, novel hypotheses about a relationship between A and C, in a so-called open discovery process. For this purpose, we 
	     developed CoPub Discovery, a tool that uses the CoPub database to mine the literature for new relationships between biomedical concepts.</p>   	     
             <center>	  
	     <img border=0 src=\"$FULL_DOCS_URL/images/closed_open_discovery.JPG\"/>
             <br></center>
	  <p>The method implemented in CoPub Discovery to score hidden relationships between biomedical concepts is based on the simple assumption that if A and B, and B and C have a relationship there is an 
	     inferred relationship between A and C (see figure above). The strength of the hidden relationship between A and C is calculated using the **<i>R</i>-scaled scores between A and B, and 
	     between B and C. This inferred <i>R</i>-scaled (<i>R</i>i) score between A and C is calculated by summation of the <i>R</i>-scaled scores over the intermediates B, taking the lowest score in each pair (AB, BC), 
	     and dividing by the number of intermediates.</p>
	  <p>*Frijters <i>et al.</i> Nucleic Acids Research - Web Server Issue 2008, May 2008 (pmid <a href=\"http://www.ncbi.nlm.nih.gov/sites/entrez?Db=pubmed&Cmd=ShowDetailView&TermToSearch=18442992&ordinalpos=1&itool=EntrezSystem2.PEntrez.Pubmed.Pubmed_ResultsPanel.Pubmed_RVDocSum\" target=\"_blank\">18442992</a>, <a href=\"http://nar.oxfordjournals.org/cgi/reprint/gkn215?ijkey=TDhOYWbZo18T6rF&keytype=ref\" target=\"_blank\">PDF</a>).</p>   
          <p>**Literature-based compound profiling: application to toxicogenomics, Frijters <i>et al.</i> Pharmacogenomics, Nov. 2007, pmid <a href=\"http://www.ncbi.nlm.nih.gov/sites/entrez?Db=pubmed&Cmd=ShowDetailView&TermToSearch=18034617&ordinalpos=1&itool=EntrezSystem2.PEntrez.Pubmed.Pubmed_ResultsPanel.Pubmed_RVDocSum\" target=\"_blank\">18034617</a>).</p>    
	  </font></td></tr>
          </table><BR><BR>
	  ";
	  
   $html_string .= "<table width=100% border=0 cellspacing=4>
                       <tr><td class=h2>CoPub Discovery project</td></tr>
                       <tr>
                       <td width=\"100\%\" height=5></td>
                       </tr> 
                    </table>          
                    <table width=100% border=0 cellspacing=2>
                       <tr>
                       <td align=center><a href=\"http://www2.cmbi.ru.nl/groups/computational-drug-discovery/introduction\" target=\"_blank\"><img border=\"0\" src=\"$FULL_DOCS_URL/images/radboud_logo.gif\" alt=\"Radboud logo\"/></a></td>
                       <td align=left><a href=\"http://www2.cmbi.ru.nl/groups/computational-drug-discovery/introduction\" target=\"_blank\">Computational Drug Discovery (CDD) Group</a>,<br> Centre for Molecular and Biomolecular Informatics (CMBI),<br> Nijmegen Centre for Molecular Life Sciences (NCMLS),<br>Radboud University Nijmegen Medical Centre, <br>Nijmegen, The Netherlands.</td>
                       </tr>
                       <tr>
                       <td height=15></td>
                       <td height=15></td>
                       </tr> 
                       <tr>
                       <td align=center><a href=\"http://www.sara.nl/index_eng.html\" target=\"_blank\"><img border=\"0\" src=\"$FULL_DOCS_URL/images/SARA_logo2.gif\" alt=\"SARA logo\"/></a></td>
                       <td align=left><a href=\"http://www.sara.nl/index_eng.html\" target=\"_blank\">SARA</a> Computing and Network Services, Amsterdam, The Netherlands.</td>
                       </tr>
                       <tr>
                       <td height=15></td>
                       <td height=15></td>
                       </tr> 
                       <tr>
                       <td align=center><a href=\"http://www.nbic.nl\" target=\"_blank\"><img border=\"0\" src=\"$FULL_DOCS_URL/images/NBIC_logo.jpg\" alt=\"NBIC logo\"/></a></td>
                       <td align=left>CoPub Discovery is hosted at <a href=\"http://www.sara.nl/index_eng.html\" target=\"_blank\">SARA</a> with support of the Netherlands Bioinformatics Centre <a href=\"http://www.nbic.nl/\" target=\"_blank\">NBIC</a>.</td>
                       </tr>
                       </table>
                       <br><br>
                     <table width=100% border=0 cellspacing=2>
                       <tr>
                       <td align=center width=400>People involved in the CoPub Discovery project:</td>
                       <td align=left><ul>
                       <li>Raoul Frijters</li>
                       <li>Stefan Verhoeven</li>
                       <li>Wilco Fleuren</li>
		       <li>Pieter van Beek</li>
                       <li>Bart Heupers</li>
                       <li>Jan Polman</li>
                       <li>Rene van Schaik</li>
                       <li>Jacob de Vlieg</li>
		       <li>Wynand Alkema</li>
                       </ul></td>
                       </tr>
                      </table>
                       <p><b>Questions or comments can be sent to <a href=\"mailto:support\@copub.org\">support\@copub.org</a>.</b></p>
                   ";	  
  
   $html_string .= $q->end_html;
  
   return $html_string;
}

sub input_form {
   
   my $q=new CGI;
   
   my %Query_results = read_input();

   my $mode = $Query_results{'mode'};
   my $sid = $Query_results{'sid'};
   my $rm = "input";
  
   $sid=~s/Content.*$//;
   
   my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } ); 
  
   my $session;
   my $error_message="";
  
   my $html_string = $q->start_html(-title=>"CoPub Discovery",
                                    -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"},
				    -onload=>'init()');
     
   $html_string .= &common::top();
   
   $html_string .= &common::navigation();
   
   $html_string .= &common::title($mode); 

   $html_string .= $q->start_multipart_form(-method=> 'post',
			                    -action=> 'cd.pl'); 

   if($sid ne "x") {

      my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );
      
      my $message = $session->param("message");
      
      if($message ne "none") {
      
         $error_message = $message;
      } 
   
   }
    
 	       
   $html_string .= "<div align=center>
                    <table border=0 bordercolor=#808080 cellspacing=0 width=100\%>
                    <tr>";
		  
   $html_string .= &common::input($q,$mode,$error_message); 	 	 
   
   $html_string .= &common::settings($q,$mode);	 
		 
   $html_string .= "</tr></table></div><BR><BR><BR>";
   
   $html_string .= &common::javascript($mode,$rm,$sid,$dbh);

   $html_string .= "<input type=hidden name='rm' VALUE='DBsearch'>";
   $html_string .= "<input type=hidden name='mode' VALUE='$mode'>";
   
   $html_string .= $q->end_html;
  
   return $html_string;
}

sub concept_DB_search {
 
my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                        { 'RaiseError' => 1 } );
 
 my $session = new CGI::Session( "driver:MySQL", undef, { Handle => $dbh } );
 my $sid = $session->id();
 
 my $mode = param('mode');
 my $keyword_A = param('keyword_A');
 my $intermediate_selection = param('intermediate_selection');
 my $lit_threshold = param('lit_threshold');
 my $R_threshold = param('R_threshold');
 my $intermediate_threshold = param('intermediate_threshold');
  
 my $message = "none";
  
 $session->param("mode", $mode);
 $session->param("keyword_A", $keyword_A);
 $session->param("intermediate_selection", $intermediate_selection);
 $session->param("lit_threshold", $lit_threshold);
 $session->param("R_threshold", $R_threshold);
 $session->param("intermediate_threshold",$intermediate_threshold);
 $session->param("message",$message);
 

 if($mode eq 'open') {
 
     my $c_category_selection = param("c_category_selection");
     my $show_number = param("show_number");
     my $A_node_category = param('A_node_category_selection');
     my $show_relationships = param('show_relationships');
     my $order_by = param('order_by');
     my $IR_threshold = param('IR_threshold');
       
     $session->param("A_node_category",$A_node_category); 
     $session->param("show_relationships",$show_relationships);
     $session->param("c_category_selection",$c_category_selection);
     $session->param("show_number",$show_number);
     $session->param("order_by",$order_by);
     $session->param("IR_threshold",$IR_threshold);
    
    if($keyword_A eq '') {
    
       $message = "Keyword field was not filled in...";
    
       $session->param("message",$message);
       $session->param("keyword_A","");
       print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=open&sid=$sid";
    
    }else    
    {
       
       my $character_length = length($keyword_A);
    
       if($character_length < 3) {
       
          $message = "The keyword should be at least three characters long...";
    
          $session->param("message",$message);
	  $session->param("keyword_A","");
    
          print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=open&sid=$sid";
       
       }else
       {
	 
	 my $string_DB_check = &common::check_string_in_DB($keyword_A,$A_node_category,$dbh);
	 
	 if($string_DB_check==0) {
	 
	    $message = "Keyword did not match any string in the database...Please, try again.";
	    $session->param("keyword_A","");
	    $session->param("message",$message);
	       
            print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=open&sid=$sid"; 
	 
	 }else
	 {
	 
	     print "Location: $SCRIPT_URL/cd.pl?rm=DBres&mode=open&sid=$sid";
       
         }
       }
    }
 }
 
 if($mode eq 'closed') {
 
    
    my $keyword_C = param('keyword_C');
    my $A_node_category = param('A_node_category_selection');
    my $C_node_category = param('C_node_category_selection');
	
    $session->param("keyword_C",$keyword_C);
    $session->param("A_node_category",$A_node_category);
    $session->param("C_node_category",$C_node_category);
    
    if($keyword_A eq '' || $keyword_C eq '') {
    
          if($keyword_A eq '' && $keyword_C eq '') 
	  {
	   
	     $message = "Keyword query fields were not filled in...Please try again.";
	     $session->param("keyword_A","");
	     $session->param("keyword_C","");
	  }
    
          if($keyword_A eq '' && $keyword_C ne '') 
	  { 
	     $message = "Keyword A query field was not filled in...Please try again.";
	     $session->param("keyword_A","");
	  }
	  
	  if($keyword_A ne '' && $keyword_C eq '') 
	  { 
	     $message = "Keyword C query field was not filled in...Please try again.";
	     $session->param("keyword_C","");
	  } 
    
       
       $session->param("message",$message);
    
       print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=closed&sid=$sid";
    
    }else
    {
    
       my $character_length_A = length($keyword_A);
       my $character_length_C = length($keyword_C);
    
       if($character_length_A < 3 || $character_length_C < 3) {
    
          if($character_length_A < 3 && $character_length_C < 3) {
	   
	     $message = "Keywords should be at least three characters long...";
	     $session->param("keyword_A","");
	     $session->param("keyword_C","");
	  }
    
          if($character_length_A < 3 && $character_length_C >= 3) {
	   
	     $message = "Keyword A should be at least three characters long...";
	     $session->param("keyword_A","");
	  }
	  
	  if($character_length_A >= 3 && $character_length_C < 3) {
	   
	     $message = "Keyword C should be at least three characters long...";
	     $session->param("keyword_C","");
	  }
    
          $session->param("message",$message);
	  
	  print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=closed&sid=$sid";
       
       }else
       {
	 
	 my $string_DB_check_A = &common::check_string_in_DB($keyword_A,$A_node_category,$dbh);
	 my $string_DB_check_C = &common::check_string_in_DB($keyword_C,$C_node_category,$dbh);
	 
	 if($string_DB_check_A == 0 || $string_DB_check_C == 0) {
	 
	    if($string_DB_check_A == 0 && $string_DB_check_C == 0) {
	    
	       $session->param("keyword_A","");
	       $session->param("keyword_C","");
	       
	       $message = "Both keyword A and C did not match in the database...Please try again.";
	       
	    }
	    
	    if($string_DB_check_A == 0 && $string_DB_check_C != 0) {
	    
	       $session->param("keyword_A","");
	       $message = "Keyword A did not match any string in the database...Please, try again.";
	    
	    }
	    
	    if($string_DB_check_A != 0 && $string_DB_check_C == 0) {
	    
	       $session->param("keyword_C","");
	       $message = "Keyword C did not match any string in the database...Please, try again.";	       
	    }
	    	    
	    $session->param("message",$message);
	    print "Location: $SCRIPT_URL/cd.pl?rm=input&mode=closed&sid=$sid";   
            
	 
	 }else
	 {     
         
	     print "Location: $SCRIPT_URL/cd.pl?rm=DBres&mode=closed&sid=$sid";
       
         }
       }
    
    }
 }
  
}


sub concept_DB_search_results {

    my $cgi_query= new CGI;

    my %Query_results = read_input();

    my $sid = $Query_results{'sid'};    
    $sid=~s/Content.*$//;    
    my $mode = $Query_results{'mode'};
    my $rm = "DBres";
    
    my $error_message='';
    
    my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

    my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );
    
    my $keyword_A = $session->param('keyword_A');
    my $A_node_category = $session->param('A_node_category');
    my $keyword_C='';
    my $C_BIs_ref='';
    my $C_node_category='';
    
    my $A_BIs_ref = &common::get_biologicalitem_ids_symbols_for_string($keyword_A,$A_node_category,$dbh);
   
    
    if($mode eq 'closed') {
    
       $keyword_C = $session->param('keyword_C');
       $C_node_category = $session->param('C_node_category');
       $C_BIs_ref = &common::get_biologicalitem_ids_symbols_for_string($keyword_C,$C_node_category,$dbh);	  
    
    } 
    
    my $html_string = $cgi_query -> start_html(-title=>$common::TITLE,
                                               -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"},
					       -onload=>'init()');
					       				       
					       				       
     
    $html_string .= $cgi_query->start_multipart_form(-method=> 'post',
			                             -action=> 'cd.pl',
						     -onload=> 'init()'); 

         
    $html_string .= &common::top();
   
    $html_string .= &common::navigation();
    
    $html_string .= &common::title($mode);
    
    $html_string .= "<div align=center>
                    <table border=0 bordercolor=#808080 cellspacing=0 width=100\%>
                    <tr>";
    
    $html_string .= &common::db_output($cgi_query,$mode,$A_BIs_ref,$C_BIs_ref,$sid);
		     
    $html_string .= &common::settings($cgi_query,$mode);
    
    $html_string .= "</tr></table></div><BR><BR><BR>";
    
    $html_string .= &common::javascript($mode,$rm,$sid,$dbh);
     
    $html_string .= "<input type=hidden name='rm' VALUE='que'>";
    $html_string .= "<input type=hidden name='sid' VALUE='$sid'>";
    $html_string .= "<input type=hidden name='mode' VALUE='$mode'>";

    $html_string .= $cgi_query->end_html;
 
    return $html_string;
 
}

sub queue {

    my $cgi_query= new CGI;
    
    my $sid = param('sid');
    
    my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

    my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );
    
    #my $session = new CGI::Session(undef, $sid, {Directory=>"$FULL_TMP_DIR"});
    
    my $mode = param('mode');
    my $A_node = param('A_radio[]');
    $session->param("A_node", $A_node);
    
    my $intermediate_selection = param('intermediate_selection');
    my $lit_threshold = param('lit_threshold');
    my $R_threshold = param('R_threshold');
    my $intermediate_threshold = param('intermediate_threshold');

    $session->param("intermediate_selection", $intermediate_selection);
    $session->param("lit_threshold", $lit_threshold);
    $session->param("R_threshold", $R_threshold);
    $session->param("intermediate_threshold",$intermediate_threshold);
    
    my $C_node;
    
    if($mode eq 'closed') {
    
       $C_node = param('C_radio[]');
       
       $session->param("C_node", $C_node);
    
    }else
    {
    
       my $c_category_selection = param("c_category_selection");
       my $show_number = param("show_number");
       my $show_relationships = param('show_relationships');
       my $order_by = param("order_by");
       my $IR_threshold = param("IR_threshold");
       
       $session->param("show_relationships",$show_relationships);
       $session->param("c_category_selection",$c_category_selection);
       $session->param("show_number",$show_number);
       $session->param("order_by",$order_by);
       $session->param("IR_threshold",$IR_threshold);
        
    }
    
    my $html_string = $cgi_query -> start_html(-title=>$common::TITLE,
                                               -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"},
					       -onload=>'init()');
 
    
    ######################## submit time #########################
 
    my $start_time = sprintf ('%3$02d:%2$02d:%1$02d',@{localtime(time)});
 
    ##############################################################
    
    my $time=0;

    $session->param("start_time", $start_time);
    $session->param("time", $time);

    my $command = "$SCRIPT_DIR/cd_calculation.pl --id $sid;";
    warn $command;

    $| = 1; # need either this or to explicitly flush stdout, etc. before forking
   if ( !defined( my $pid = fork() ) ) {
	warn "fork error\n";
	exit(1);
   }
   elsif ( $pid == 0 ) {
	# child
	close(STDOUT);
	close(STDIN);
	close(STDERR);

        open(STDOUT, "> /tmp/copub_$sid.stdout");
        open(STDERR, "> /tmp/copub_$sid.stderr");
	print "Starting computation\n";
	exec($command);    # lengthy processing
   }
   else {
	warn "forked child \$pid= $pid\n";
	$session->param( "pid", $pid );
	$session->flush();
   }
    
    $html_string .= "<script language='javascript'>parent.location='$SCRIPT_URL/cd.pl?rm=pro&sid=$sid';</script>";
    
    return $html_string;
 
}

sub progress {

my %Query_results = read_input();

my $sid = $Query_results{'sid'};

my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );

my $time = $session->param("time");
my $mode = $session->param("mode");
my $pid  = $session->param("pid");

my $results_file = "finish_" . $sid . ".txt";

if ( ! -e "/proc/$pid") {

    if(-e "$TMP_DIR/$results_file" ) {
	
       my $finish = "finish_" . $sid . ".txt";
       unlink("$TMP_DIR/$finish");
   
       if($mode eq 'open') {
          print "Location: $SCRIPT_URL/cd.pl?rm=res&sid=$sid", "\n\n";
   
       }else
       {
          my $A_node_BI = $session->param("A_node");
          my $C_node_BI = $session->param("C_node");
          my $query = "sid=$sid&a_node_BI=$A_node_BI&c_node_BI=$C_node_BI";
      
          print "Location: $SCRIPT_URL/cd.pl?rm=ires&$query", "\n\n";
   
       }
   
       exit(0);	
	
    }else
    { 
   
         if($mode eq 'open') {
          print "Location: $SCRIPT_URL/cd.pl?rm=DBres&mode=open&sid=$sid", "\n\n";
   
         }else
         {
          
	  print "Location: $SCRIPT_URL/cd.pl?rm=DBres&mode=closed&sid=$sid", "\n\n";
   
         }
   
    }

}else
{   
   my $q = new CGI;

   my $html_string = "<html><head><title>CoPub Discovery</title>\n";
   $html_string .= "</head><body onload='JavaScript:timedRefresh(5000);'>\n";
   $html_string .= "<script type='text/javascript'>\n";
   $html_string .= "<!--\n";
   $html_string .= "function timedRefresh(timeoutPeriod) {\n";
   $html_string .= "    setTimeout('location.reload(true);',timeoutPeriod);\n";
   $html_string .= "}\n";
   $html_string .= "//-->\n";
   $html_string .= "</script>\n";

   $html_string .= &common::top();
          
   $html_string .= "<BR><BR>";
   $html_string .= "<div align= center>
                    <table border=1 bordercolor=#808080 cellspacing=0 width=1000 id=AutoNumber1>
                    <tr>
                    <td width=100%><BR>";
	   
   $html_string .= "<div align=center>
                  <table border=0 bordercolor=#808080 cellspacing=1 width=950 id=AutoNumber1>
                  <tr>
                  <td width=100% bgcolor=#0094D9 align=center><font face=Verdana size=4 color=#FFFFFF><B>Analysis in progress</font></b></td>
                  </tr></table><BR>";
		  
   $html_string .= "<font face=Verdana size=3><B>Refreshing in 5 seconds, please wait....<BR><BR>";		    	
   
   if($time > 5) {
   
   $html_string .= "<font face=Verdana size=3><B>($time seconds passed since start of analysis)<BR><BR>";		    	
   
   }
   
   $html_string .= "</td></tr></table>";
   
   my $time_temp = $time;
   $time = $time_temp + 5;
   $session->param("time", $time);
   
   $html_string .= $q->end_html;
 } 
}


sub results {

my $cgi_query= new CGI;

my %Query_results = read_input();

my $sid = $Query_results{'sid'};

my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );

my $A_node = $session->param("A_node");
my $C_node;
my $C_category_selection;
my $show_number_raw = $session->param("show_number");

my $res_save="CoPub Discovery analysis results - open discovery\r\n\r\n";
 
my %show_number_hash =('All' => 500,
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

my $mode = $session->param("mode");

if($mode eq 'closed') {

   $C_node = $session->param("C_node");
}


  my $literature_threshold_B_node = $session->param("lit_threshold");
  my $R_scaled_threshold_B_node = $session->param("R_threshold");
  my $threshold_intermediate_count = $session->param("intermediate_threshold");
  my $intermediate_selection = $session->param("intermediate_selection");
  my $show_relationships = $session->param("show_relationships");
  my $order_by = $session->param("order_by");
  my $IR_threshold = $session->param("IR_threshold");
  my $B_nodes;
  my $relationships;
  my $C_category;
  
  
  if($intermediate_selection eq 'genes') {
  
     $B_nodes = "Genes";
  
  }else
  {
  
     $B_nodes = "Genes, Pathways and Biological Processes";
  
  }
  
  if($mode eq 'open') {
  
     $relationships = $session->param('show_relationships');
     
     my %C_categories = ('1' => 'Genes',
                         '2' => 'Pathologies',
		         '3' => 'Diseases',
		         '5' => 'Biological Processes',
		         '9' => 'Pathways',
		         '11' => 'Drugs'  
                         );
    
     $C_category_selection = $session->param("c_category_selection");

     $C_category = $C_categories{$C_category_selection};
     
 
  }
  
  
  my $implicit_relationships_set = $session->param("implicit_relationships_set");
 
  my $html_string = $cgi_query -> start_html(-title=>$common::TITLE,
                                             -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"});
       
    $html_string .= &common::top();
   
    $html_string .= &common::navigation();
    
    $html_string .= &common::title($mode);

  my %results = %{$implicit_relationships_set->{InferredRelations}};


 $html_string .= "<div align=center>
                  <table border=0 bordercolor=#808080 cellspacing=1 width=1150 id=AutoNumber1>
                  <tr>
                  <td width=100% bgcolor=#0094D9 align=center><font face=Verdana size=4 color=#FFFFFF><B>CoPub Discovery analysis results</font></b></td>
                  </tr></table>";   		   
   
 $html_string .= "<BR>";  
   
 
 $html_string .= "<div align= center>
                  <table border=0 bordercolor=#808080 cellspacing=0 width=1150 id=AutoNumber1>
                  <tr>
                  <td width=100%>";

 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>B nodes inclusion criteria</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table>";
		  
 $res_save .= "B node inclusion criteria\r\n\r\n";		  
		  
 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td align=left height=10><font face=Verdana size=2></td>
                  </tr></table>";		  

 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Literature count threshold: $literature_threshold_B_node</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table>";
		  
 $res_save .= "Literature count threshold: $literature_threshold_B_node\r\n";		  
	   
 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2><i>R</i>-scaled threshold: $R_scaled_threshold_B_node</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table>";
		  
 $res_save .= "R-scaled threshold: $R_scaled_threshold_B_node\r\n";		  
	   
 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Intermediate threshold: $threshold_intermediate_count</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table><BR>";
		  
 $res_save .= "Intermediate threshold: $threshold_intermediate_count\r\n\r\n";	  
	   
 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Intermediates used: $B_nodes</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table>";
		  
 $res_save .= "Intermediates used: $B_nodes\r\n";		  

if($mode eq 'open') {

 $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	          <tr>
	          <td width=20 align=left><font face=Verdana size=2></td>
                  <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Selected C category: $C_category</td>
                  <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
                  </tr></table>";	   	   	   	     

 $res_save .= "Selected C category: $C_category\r\n";

    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
           <tr>
           <td width=20 align=left><font face=Verdana size=2></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Show relationships: $relationships</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>     
           </tr></table><BR>";
	   
 $res_save .= "Show relationships: $relationships\r\n\r\n";	   
	   
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
           <tr>
           <td width=20 align=left><font face=Verdana size=2></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Inferred <i>R</i>-scaled score threshold: $IR_threshold</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>     
           </tr></table>";
	   
 $res_save .= "Inferred R-scaled score threshold: $IR_threshold\r\n";	   	   
	   
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=2></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Sorted on: $order_by</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table>";
	   
  $res_save .= "Ordered by: $order_by\r\n";	       
    
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=2></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Show top: $show_number</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table>";
	   
  $res_save .= "Show top: $show_number\r\n\r\n";	   	   

}
  
    $html_string .= "</td></tr></table>";
 

 my $check=0;

 foreach my $A_node_BI (keys %results) {
   
        my $A_node_attributes = &common::get_bi_attributes($A_node_BI,$dbh);
	
	my $node_category = $A_node_attributes->{category};
	my $node_name = $A_node_attributes->{preferred_name};
	
	if($node_category eq 'gene') {
	   
	   my $symbol = $A_node_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $node_name = $node_name . " (" . $symbol . ")";
	   }
	}
	
	$node_name=~s/&&/,/g;
	
	
	my %sort_hash;
	
	my %inferred_relations = %{$results{$A_node_BI}};
	
	my $c_node_count = keys %inferred_relations;
	
	my $sort="min_inferred_R_scaled_score";
	
	if($order_by eq "Number of B-intermediates") {
	
	   $sort="intermediate_count";
	
	}
	
	foreach my $C_node_BI (keys %inferred_relations) {
	
	        my $C_node = $inferred_relations{$C_node_BI};
	
                $sort_hash{$C_node_BI} = $C_node->{$sort};
	
	}
	
	$html_string .= "<div align= center>
               <table border=0 bordercolor=#808080 cellspacing=0 width=1150 id=AutoNumber1>
               <tr>
               <td width=100%><BR>";
	       
	$html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	       <tr>
	       <td width=20 align=left><font face=Verdana size=2></td>
               <td width=830 align=left valign=top><b><font face=Verdana size=2><b><font face=Verdana size=2>Input keyword A: $node_name ($node_category)</td>
               <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
               </tr></table>"; 
	       
	$res_save .= "Input keyword A: $node_name ($node_category)\r\n\r\n";
	                     

        $html_string .= "<BR><div align=center>
                 <table border=0 bordercolor=#808080 cellspacing=1 width=1100 id=AutoNumber1>
                 <tr>
                 <td width=100% bgcolor=#0094D9 align=center><font face=Verdana size=4 color=#FFFFFF><B>Results</font></b></td>
                 </tr></table><BR>"; 
		 
	$res_save .= "Results\r\n\r\n";	  	   
    
    if($c_node_count > 0 ) {
	
    
        $check=1;
    
        $html_string .= "<div align= center>
               <table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	       <tr>
               <td width=30% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>C node</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Category</font></b></td>
               <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Relationship type</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Known lit. count</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Known <i>R</i>-scaled score</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Intermediate count</font></b></td>
               <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Inferred <i>R</i>-scaled score</font></b></td>
               </tr></table>";
	       
	$res_save .= "C node"  . "\t" . "Category" . "\t" . "Relationship type" . "\t" . "Known lit. count" . "\t" . "Known R-scaled score" . "\t" . "Intermediate count" . "\t" . "Inferred R-scaled score" . "\r\n";	       
	       
	foreach my $C_node_BI (sort { $sort_hash{$b} <=> $sort_hash{$a} } keys %sort_hash ) {
    
                my $C_node = $inferred_relations{$C_node_BI};
		
		my $C_node_attributes = &common::get_bi_attributes($C_node_BI,$dbh);
		
		my $C_name = $C_node_attributes->{preferred_name};
		my $C_category = $C_node_attributes->{category};
		my $C_relation_type = $C_node->{relationship_type};
		my $C_known_literature_count = $C_node->{known_literature_count};
		my $C_known_R_scaled_score = $C_node->{known_R_scaled_score};
		my $C_intermediate_count = $C_node->{intermediate_count};
	        my $C_min_inferred_R_scaled_score = $C_node->{min_inferred_R_scaled_score};
		
		if($C_node_attributes->{category} eq 'gene') {
		        
		   if($C_node_attributes->{symbol} ne '') {
		   
		      $C_name .= " (" . $C_node_attributes->{symbol} . ")"; 
		   
		   }
		
		}else
		{
		
		  foreach my $alternative_name (@{$C_node_attributes->{alternative_names}}) {
				
		          $C_name .= " // " . $alternative_name;
		  
		  }
		}
		
		$C_name=~s/&&/,/g;
		
		if($C_category eq "go_bioproc") {
	
	           $C_category = "biological process";
	
	        }
		
		
		my $background;
	        my $row_color=0;
            
	        if($row_color eq 0) {
	   
	          $background = "#D6D6D6"; 
	   
	        }else
	        {
	          $background = "#C7C7C7"; 
	      
	        }
		
	       
	        $html_string .= "<table border=0 width=1150 id=AutoNumber1> 
		       <tr>
                       <td width=100% height=1></td>
	               </tr></table>";	
		
	       if($C_relation_type eq "Unknown") {
	       
		  my $query = "sid=$sid&a_node_BI=$A_node_BI&c_node_BI=$C_node_BI";
		
		   $html_string .= "<div align=center>
                       <table border=0 bordercolor=#808080 cellspacing=1 width=1100 id=AutoNumber1> 
		       <tr>
                       <td width=30% bgcolor=$background align=left><b><font face=verdana size=2><b>$C_name</font></b></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_category</font></b></td>
                       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_relation_type</font></b></td>
	               <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_known_literature_count</font></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_known_R_scaled_score</font></b></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b><a href=\"cd.pl?rm=ires&$query\" target='_blank'>$C_intermediate_count</a></font></b></td>
                       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_min_inferred_R_scaled_score</font></td>
		       </tr>
                       </table>";
		       
		   $res_save .= $C_name  . "\t" . $C_category . "\t" . $C_relation_type . "\t" . $C_known_literature_count . "\t" . $C_known_R_scaled_score . "\t" . $C_intermediate_count . "\t" . $C_min_inferred_R_scaled_score . "\r\n";    
		  
	       }else
               {
		
		my $query = "sid=$sid&a_node_BI=$A_node_BI&c_node_BI=$C_node_BI";
		
		 $html_string .= "<div align=center>
                       <table border=0 bordercolor=#808080 cellspacing=1 width=1100 id=AutoNumber1> 
		       <tr>
                       <td width=30% bgcolor=$background align=left><b><font face=verdana size=2><b>$C_name</font></b></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_category</font></b></td>
                       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_relation_type</font></b></td>
	               <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b><a href=\"$SCRIPT_URL/medline_abstracts.pl?type=AC&id1=$A_node_BI&id2=$C_node_BI\" target='_blank'>$C_known_literature_count</a></font></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_known_R_scaled_score</font></b></td>
		       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b><a href=\"cd.pl?rm=ires&$query\" target='_blank'>$C_intermediate_count</a></font></b></td>
                       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$C_min_inferred_R_scaled_score</font></td>
		       </tr>
                       </table>";
		       
		 $res_save .= $C_name  . "\t" . $C_category . "\t" . $C_relation_type . "\t" . $C_known_literature_count . "\t" . $C_known_R_scaled_score . "\t" . $C_intermediate_count . "\t" . $C_min_inferred_R_scaled_score . "\r\n";    
		        
	       }	  
	       
		       
               if($row_color eq 1) {
	  
	          $row_color = 0;
	  
	       }else
	       {
	  
	          $row_color = 1;
	       }
	  }
	  	   	   			
	#}
    	
	$html_string .= "<BR></td></tr></table><BR>";  
  
	
    }else
    {
    
      if($relationships eq 'Only unknown relationships') {
    
        $html_string .= "<BR><B>No hidden relationships were found...</B><BR><BR><BR>";
      
      }else
      {
      
        $html_string .= "<BR><B>No relationships were found...</B><BR><BR><BR>";
      }
    }
      
   $session->param("res_save", $res_save);   
      
   my $option_redefine_keyword = "Redefine search";
   my $location = "$SCRIPT_URL/cd.pl?rm=DBres&mode=open&sid=$sid";
   
   my $option_save_file = "Save";
   my $location2 = "$SCRIPT_URL/cd.pl?rm=save&sid=$sid&f=res_save";
       
   if($check==1)
   {
      $html_string .= "<input type=\"button\" name=\"save\" id=\"save\" value=\"$option_save_file\" onclick=\"parent.location='$location2'\"></td>";
   }
                  
   $html_string .= "<input type=\"button\" name=\"redefine_search\" id=\"redefine_search\" value=\"$option_redefine_keyword\" onclick=\"parent.location='$location'\"></td>";
		
   
   }
    
  $html_string .= "</center>"; 	
 
  $html_string .= $cgi_query->end_html;
  
  return $html_string;

}


# --------------------------------------------------------------------------------------------------
# Intermediates results
sub intermediates_results {
  
my $cgi_query= new CGI;

my %Query_results = read_input();

my $sid = $Query_results{'sid'};
my $A_node_BI = $Query_results{'a_node_BI'};
my $C_node_BI = $Query_results{'c_node_BI'};

my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );

my $mode = $session->param('mode');  
   
    my $html_string = $cgi_query -> start_html(-title=>$common::TITLE,
                                               -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"});
       
    $html_string .= &common::top();
   
    $html_string .= &common::navigation();
    
    $html_string .= &common::title($mode);
    

 my $literature_threshold = $session->param("lit_threshold");
 my $R_scaled_threshold = $session->param("R_threshold");
 my $threshold_intermediate_count = $session->param("intermediate_threshold");
 my $sort = $session->param("sort");
 my $implicit_relationships_set = $session->param("implicit_relationships_set");
 my $ires_save="CoPub Discovery analysis - ";
 
 if($mode eq 'open') {
 
    $ires_save.="open discovery intermediates results\r\n\r\n";
 }else
 { 
    $ires_save.="closed discovery intermediates results\r\n\r\n";
 }
 
 my @all_BIs;
 
 push(@all_BIs,$A_node_BI);
 push(@all_BIs,$C_node_BI);
 

 my %results = %{$implicit_relationships_set->{InferredRelations}};

 my $A_node_attributes = &common::get_bi_attributes($A_node_BI,$dbh);
 
 
 my $A_node_category = $A_node_attributes->{category};
 my $A_node_name = $A_node_attributes->{preferred_name};
	
	if($A_node_category eq 'gene') {
	   
	   my $symbol = $A_node_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $A_node_name = $A_node_name . " (" . $symbol . ")";
	   }
	}
	
 $A_node_name=~s/&&/, /g;
 
 my $C_node_attributes = &common::get_bi_attributes($C_node_BI,$dbh);
 
 my $C_node_category = $C_node_attributes->{category};
 my $C_node_name = $C_node_attributes->{preferred_name};
	
	if($C_node_category eq 'gene') {
	   
	   my $symbol = $C_node_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $C_node_name = $C_node_name . " (" . $symbol . ")";
	   }
	}
	
 $C_node_name=~s/&&/, /g;
 
 my %inferred_relationships = %{$results{$A_node_BI}};
 
 my $node_C;
 my $intermediate_count = 0;
 my $check=0;
 
 if(exists $inferred_relationships{$C_node_BI}) {
 
    $check=1;
    $node_C = $inferred_relationships{$C_node_BI};
    $intermediate_count = $node_C->{intermediate_count};
 
    my $C_min_inferred_R_scaled_score = $node_C->{min_inferred_R_scaled_score};
    my $relationship_type = $node_C->{relationship_type};
    my $relationship_type_show = $node_C->{relationship_type};
    
    if($relationship_type eq 'Known') {
    
        $relationship_type_show = "<a href=\"$SCRIPT_URL/medline_abstracts.pl?type=AC&id1=$A_node_BI&id2=$C_node_BI\" target='_blank'>Known</a>";
    }

    my @B_nodes = @{$node_C->{B_node_ids}};

    $html_string .= "<div align=center>
            <table border=0 bordercolor=#808080 cellspacing=1 width=1150 id=AutoNumber1>
            <tr>
            <td width=100% bgcolor=#0094D9 align=center><font face=Verdana size=4 color=#FFFFFF><B>CoPub Discovery analysis results</font></b></td>
            </tr></table>";   		   
   
    $html_string .= "<BR>";  
 
    $html_string .= "<div align= center>
           <table border=0 bordercolor=#808080 cellspacing=0 width=1150 id=AutoNumber1>
           <tr>
           <td width=100%><BR>";
   
    
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Node A (" . $A_node_category . "): $A_node_name</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table><BR>";
	   
    $ires_save.= "Node A (" . $A_node_category . "): " . $A_node_name . "\r\n\r\n"; 	   
	   
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Node C (" . $C_node_category . "): $C_node_name</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table><BR>";
	   
    $ires_save.= "Node C (" . $C_node_category . "): " . $C_node_name . "\r\n\r\n";  	   
	   
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Relationship type: $relationship_type_show</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table><BR>";
	   
    $ires_save.= "Relationship type: $relationship_type" . "\r\n\r\n";	   	   
	   
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>R-scaled score threshold: $R_scaled_threshold</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table>";

    $ires_save.= "R-scaled score threshold: $R_scaled_threshold" . "\r\n";	   
    
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Literature count threshold: $literature_threshold</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table><BR>";
	   
    $ires_save.= "Literature count threshold: $literature_threshold" . "\r\n\r\n";	   	   
    
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Intermediate count: $intermediate_count</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table>";
    
    $ires_save.= "Intermediate count: $intermediate_count" . "\r\n";
	    
    $html_string .= "<table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	   <tr>
	   <td width=20 align=left><font face=Verdana size=3></td>
           <td width=830 align=left valign=top><b><font face=Verdana size=2><b>Inferred <i>R</i>-scaled score: $C_min_inferred_R_scaled_score</td>
           <td width=100 align=left valign=top><font face=Verdana size=2></td>	   
           </tr></table>";	   	   	   	   	   	   	  
  
    $ires_save.= "Inferred R-scaled score: $C_min_inferred_R_scaled_score" . "\r\n\r\n\r\n";
  
    $html_string .= "<BR></td></tr></table>";
   
	    
    $html_string .= "<div align= center>
           <table border=0 bordercolor=#808080 cellspacing=0 width=1150 id=AutoNumber1>
           <tr>
           <td width=100%><BR>";
	   
    $html_string .= "<div align=center>
                 <table border=0 bordercolor=#808080 cellspacing=1 width=1100 id=AutoNumber1>
                 <tr>
                 <td width=100% bgcolor=#0094D9 align=center><font face=Verdana size=4 color=#FFFFFF><B>Intermediates</font></b></td>
                 </tr></table><BR>";
	  
    $ires_save.= "Intermediates" . "\r\n\r\n";	 	 	   
  
    $html_string .= "<div align= center>
               <table border=0 bordercolor=#808080 cellspacing=0 width=1100 id=AutoNumber1>
	       <tr>
               <td width=40% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Node B</font></b></td>
	       <td width=20% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Category</font></b></td>
               <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF><i>R</i>-scaled A</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Literature A</font></b></td>
               <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF><i>R</i>-scaled C</font></b></td>
	       <td width=10% bgcolor=#0094D9 align=center><b><font face=verdana size=2 color=#FFFFFF>Literature C</font></b></td>
               </tr></table>"; 
 
    $ires_save.= "Node B" . "\t" . "Category" . "\t" . "R-scaled A" . "\t" . "Literature A" . "\t" . "R-scaled C" . "\t" . "Literature C" . "\r\n";
 
     foreach my $B_node_BI (@B_nodes) { 
  
          my $B_node_attributes = &common::get_bi_attributes($B_node_BI,$dbh);
	  
          my $B_node_category = $B_node_attributes->{category};
          my $B_node_name = $B_node_attributes->{preferred_name};
	  my $B_EG_id = $B_node_attributes->{EG_id};
	  
	  my $lit_stat_A_B = &common::get_litstats_for_ids($A_node_BI,$B_node_BI,$dbh);
	  my $lit_stat_B_C = &common::get_litstats_for_ids($B_node_BI,$C_node_BI,$dbh);
	  
	  my $R_scaled_A_B = $lit_stat_A_B->{R_scaled};
	  my $lit_count_A_B = $lit_stat_A_B->{literature_count};
	  my $R_scaled_B_C = $lit_stat_B_C->{R_scaled};
	  my $lit_count_B_C = $lit_stat_B_C->{literature_count};
	
	  push(@all_BIs,$B_node_BI);
	
	if($B_node_category eq 'gene') {
	   
	   my $symbol = $B_node_attributes->{symbol};
	   
	   if($symbol ne '') {
	   
	      $B_node_name = $B_node_name . " (" . $symbol . ")";
	   }
	}
	
        $B_node_name=~s/&&/, /g;
	
	if($B_node_category eq "go_bioproc") {
	
	   $B_node_category = "biological process";
	
	}
	
	my $background;
	my $row_color=0;
            
	if($row_color eq 0) {
	   
	   $background = "#D6D6D6"; 
	   
	}else
	{
	   $background = "#C7C7C7"; 
	      
	}
	
	$html_string .= "<table border=0 width=1150 id=AutoNumber1> 
	       <tr>
               <td width=100% height=1></td>
	       </tr></table>";
	
	$html_string .= "<div align=center>
               <table border=0 bordercolor=#808080 cellspacing=1 width=1100 id=AutoNumber1> 
	       <tr>
               <td width=40% bgcolor=$background align=left><b><font face=verdana size=2><b><a href=\"http://www.ncbi.nlm.nih.gov/sites/entrez?db=gene&cmd=Retrieve&dopt=Graphics&list_uids=$B_EG_id\" target='_blank'>$B_node_name</a></font></b></td>
	       <td width=20% bgcolor=$background align=center><b><font face=verdana size=2><b>$B_node_category</font></b></td>
	       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$R_scaled_A_B</font></b></td>
	       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b><a href=\"$SCRIPT_URL/medline_abstracts.pl?type=AB&id1=$A_node_BI&id2=$B_node_BI\" target='_blank'>$lit_count_A_B</a></font></b></td>
	       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b>$R_scaled_B_C</font></b></td>
	       <td width=10% bgcolor=$background align=center><b><font face=verdana size=2><b><a href=\"$SCRIPT_URL/medline_abstracts.pl?type=BC&id1=$B_node_BI&id2=$C_node_BI\" target='_blank'>$lit_count_B_C</a></font></b></td>
	       </tr>
               </table>";
	
	$ires_save.= $B_node_name . "\t" . $B_node_category . "\t" . $R_scaled_A_B . "\t" . $lit_count_A_B . "\t" . $R_scaled_B_C . "\t" . $lit_count_B_C . "\r\n";       
	       
	if($row_color eq 1) {
	  
	   $row_color = 0;
	  
	}else
	{
	  
	   $row_color = 1;
	}       
	   
     }  	   	   	   	  

}else
{

    $html_string .= "<BR>No hidden relationship was found.<BR>No Intermediates were found...<BR>";

 }  
    $html_string .= "<BR></td></tr></table><BR>";
    
    $session->param("ires_save", $ires_save);
   
    my $option_redefine_keyword = "Redefine search";
    my $location;
    
    my $option_save_file = "Save";
    my $location2;
    
    if($mode eq 'closed') {
    
       $location = "$SCRIPT_URL/cd.pl?rm=DBres&mode=closed&sid=$sid";
       $location2 = "$SCRIPT_URL/cd.pl?rm=save&sid=$sid&f=ires_save";
       
       if($check==1)
       {
          $html_string .= "<input type=\"button\" name=\"save\" id=\"save\" value=\"$option_save_file\" onclick=\"parent.location='$location2'\"></td>";
       }
       
       $html_string .= "<input type=\"button\" name=\"redefine_search\" id=\"redefine_search\" value=\"$option_redefine_keyword\" onclick=\"parent.location='$location'\"></td>";
	           
    }
    
    if($mode eq 'open') {
    
       $location2 = "$SCRIPT_URL/cd.pl?rm=save&sid=$sid&f=ires_save";
       
       $html_string .= "<input type=\"button\" name=\"save\" id=\"save\" value=\"$option_save_file\" onclick=\"parent.location='$location2'\"></td>";
       	           
    }

if(exists $inferred_relationships{$C_node_BI}) {
 
    my $lit_threshold;
    my $R_threshold;
    
    SWITCH: {
		if ($literature_threshold eq "1")      {$lit_threshold = "1"; }
		if ($literature_threshold eq "2")      {$lit_threshold = "2"; }
		if ($literature_threshold eq "3")      {$lit_threshold = "3"; }
		if ($literature_threshold eq "4")      {$lit_threshold = "4"; }
		if ($literature_threshold eq "5")      {$lit_threshold = "5"; }
		if ($R_scaled_threshold eq "20")       {$R_threshold = "20"; }
		if ($R_scaled_threshold eq "30")       {$R_threshold = "30"; }
		if ($R_scaled_threshold eq "35")       {$R_threshold = "35"; }
		
	   }  
   
    my %cd_info;
    
    my $A_node = $A_node_BI;
    my $C_node = $C_node_BI;
    
    $cd_info{$A_node}="A_node";
    $cd_info{$C_node}="C_node";
    
}
   return $html_string;
}

sub save {
   			 
   my %Query_results = read_input();

   my $sid = $Query_results{'sid'};
   my $f = $Query_results{'f'};
   
   my $dbh = DBI->connect( $DB_CONNECT_STRING, $DB_USER, $DB_PASSWORD,
                            { 'RaiseError' => 1 } );

   my $session = new CGI::Session( "driver:MySQL", $sid, { Handle => $dbh } );

   my $file = $session->param($f);
   my $file_name; 
   
   if($f eq "res_save") {
   
      $file_name = "open_discovery_results.txt"; 
   }
   
   if($f eq "ires_save" && $session->param('mode') eq "open") {
   
      $file_name = "open_discovery_intermediates_results.txt"; 
   }
   
   if($f eq "ires_save" && $session->param('mode') eq "closed") {
   
      $file_name = "closed_discovery_intermediates_results.txt"; 
   }
   
   print "Content-Disposition: attachment; filename = $file_name\r\n\r\n";
   
   print $file;
   
}   
