# $Id$
package SOAPServices;
use lib '/home/bioasp/bioasp/copub/perllib/lib/perl/5.8.4';
use lib '/home/bioasp/bioasp/copub/perllib/share/perl/5.8.4';
use strict;
use warnings;
use SOAP::Lite;
#use SOAP::MIME;
use Data::Dumper;
use XML::Simple;


# See : http://www.ebi.ac.uk/Tools/webservices/WSDbfetch.html
sub get_medline_abstract
{
  my $pubmed_id = shift;
  my $uri   = 'urn:Dbfetch';
  my $proxy = 'http://www.ebi.ac.uk/ws/services/Dbfetch';

  my $soap = new SOAP::Lite(uri   => $uri,
                            proxy => $proxy);

  my $method = 'fetchData';			    
  my $format = 'medlinexml';
  my $style = 'raw';
  my $query = "medline:$pubmed_id"; 
  my $result = $soap->call($method => $query, $format, $style);
  if ($result->fault) {
    warn $result->faultcode . " " . $result->faultstring . "\n";
    return undef;
  } else {  
    $result  = $result->result;
    my $xml = join("\n", @{$result});
    #$xml = '/home/bioasp/bioasp/copub/project/copubsara/trunk/tools/SOAPLite/result.xml';
    my $ref =  XMLin($xml, ForceArray => ['Author']);
    if( exists($ref->{MedlineCitation})) {
      $ref = $ref->{MedlineCitation};
    } else {
      warn "Invalid XML structure";
      return undef;
    }  
    my $result_ref = {'abstract' => '', 'title' => '', 'create_date' => '', 
                      'journal_title' => '', 'volume' => '', 'issue' => '',
		      'page' => '', 'authors' => ''};
    		      
    $result_ref->{abstract} = $ref->{Article}->{Abstract}->{AbstractText} if exists($ref->{Article}->{Abstract}->{AbstractText} );		      
    $result_ref->{title} = $ref->{Article}->{ArticleTitle} if exists($ref->{Article}->{ArticleTitle} );		      
    my $year = $ref->{DateCreated}->{Year} if exists($ref->{DateCreated}->{Year});
    my $month = $ref->{DateCreated}->{Month} if exists($ref->{DateCreated}->{Month});
    $result_ref->{create_date} = "$year $month"; 
    $result_ref->{journal_title} = $ref->{Article}->{Journal}->{Title} if exists($ref->{Article}->{Journal}->{Title});
    $result_ref->{volume} =  $ref->{Article}->{Journal}->{JournalIssue}->{Volume} if exists($ref->{Article}->{Journal}->{JournalIssue}->{Volume} );
    $result_ref->{issue} =  $ref->{Article}->{Journal}->{JournalIssue}->{Issue} if exists($ref->{Article}->{Journal}->{JournalIssue}->{Issue} );
    $result_ref->{page} =  $ref->{Article}->{Pagination}->{MedlinePgn} if exists( $ref->{Article}->{Pagination}->{MedlinePgn} );
    if(exists($ref->{Article}->{AuthorList}->{Author})) {
      my @authlist;
      foreach my $auth (@{$ref->{Article}->{AuthorList}->{Author}}) {
        my @authnl;
	push(@authnl, $auth->{ForeName}) if exists($auth->{ForeName});
	push(@authnl, $auth->{Initials}) if exists($auth->{Initials});
	push(@authnl, $auth->{LastName}) if exists($auth->{LastName});
	
        my $authstr = exists($auth->{ForeName}) ? $auth->{ForeName} :
                      exists($auth->{Initials}) ? $auth->{Initials} : '';
        $authstr .=  exists($auth->{LastName}) ? $auth->{LastName} : '';
        push(@authlist, join(' ', @authnl));
      }  
      $result_ref->{authors} = join(' ,', @authlist);
    }
    return $result_ref;
  }
}

1;
