#!/usr/bin/perl -w
use strict;
use common;
use warnings;
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Data::Dumper;

my $query = new CGI;

print $query->header;
print $query->start_html(-title=>$common::TITLE
                       , -style=>{'src'=>"$FULL_DOCS_URL/styles/CoPub_discovery.css"}
                       , -encoding=>'UTF-8'
                       , -script=>{-language=>'JAVASCRIPT',
                                   -src=>"$FULL_DOCS_URL/js/copub.js"}
                        );         

print &common::top();

print qq|
<BR/>
<table border=0 cellspacing=1 width=100%>
   <tr>
   <td width=100% bgcolor=#0094D9 align=center class=h2><B>The <i>R</i>-scaled score</b></td>
   </tr>
</table>
<br/>|;

print"<table border=0 cellspacing=1 width=100%>
  <tr>
    <td>";
  
print "To assign a degree of relation between two keywords, an <i>R</i>-scaled score was calculated, that describes the strength of a co-citation between two keywords given 
       their individual frequencies of occurrence and the number of co-publications between every biological item pair 
       (<a href=\"http://www.ncbi.nlm.nih.gov/sites/entrez?Db=pubmed&Cmd=ShowDetailView&TermToSearch=15760478&ordinalpos=1&itool=EntrezSystem2.PEntrez.Pubmed.Pubmed_ResultsPanel.Pubmed_RVDocSum\" target=\"_blank\">Alako et al</a>).<BR><BR>";

print "The <i>R</i>-scaled score is based on the mutual information measure and was calculated as:<br><br><b>S = pAB/pA*pB</b>,<br><br>in which pA is the number of hits for biological item A 
	divided by the total number of PubMed IDs, pB is the number of hits for biological item B divided by the total number of PubMed IDs, and pAB is the number 
	of co-occurrences between biological item A and biological item B divided by the total number of PubMed IDs.
	<br>The relative score is produced as a log10 conversion<br><br> 
	<b>R = 10log S</b>,<br><br>and the 1-100 scaled-log-transformed relative score (<i>R</i>-scaled score) as<br><br> 
	<b><i>R</i>-scaled score = 1 + 99 * (R-Rmin) / (Rmax-Rmin)</b>,<br><br> 
	where Rmin and Rmax are the lowest and highest R values present in the biological item co-publication list, respectively.
      ";

print "</td></tr></table>";

print qq|
<BR/>
<table border=0 cellspacing=1 width=100%>
   <tr>
   <td width=100% bgcolor=#0094D9 align=center class=h2><B>The Inferred <i>R</i>-scaled score</b></td>
   </tr>
</table>
<br/>|;

print "<p><center>	  
	     <img border=0 src=\"$FULL_DOCS_URL/images/closed_open_discovery.JPG\"/>
             <br></center>
	  <p>The method implemented in CoPub Discovery to score hidden relationships between biomedical concepts is based on the simple assumption that if A and B, and B and C have a relationship there is an 
	     inferred relationship between A and C (see figure above). The strength of the hidden relationship between A and C is calculated using the <i>R</i>-scaled scores between A and B, and 
	     between B and C. This inferred <i>R</i>-scaled (<i>R</i>i) score between A and C is calculated by summation of the <i>R</i>-scaled scores over the intermediates B, taking the lowest score in each pair (AB, BC), 
	     and dividing by the number of intermediates.</p>
       <BR><BR>";

