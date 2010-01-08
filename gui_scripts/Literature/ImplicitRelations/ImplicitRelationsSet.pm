package Literature::ImplicitRelations::ImplicitRelationsSet;

use strict;
use warnings;

=head1 DESCRIPTION

       This module defines an object which stores sets of hidden relationships between A nodes and C nodes, and their B node intermediates.

=head1 METHODS


=head2 new

  Title: new
  
  Usage: my $inferred_relations_set = Wbt::Literature::ImplicitRelations::ImplicitRelationsSet->new(InferredRelations => \%inferred_relationships_results);
    
         Where the '%inferred_relationships_results'-hash is described as:
     
         my $inferred_relationships_results{'21'} = \%inferred_relationships; (A_node = '21')
	       
	 my $inferred_relationships{'3446'} = $inferred_relationship; (C_node = '3446')
	      
	 my $inferred_relationship = Wbt::Literature::ImplicitRelations::ImplicitRelation->new(A_node_id => 21,
                                                                                               B_node_ids => \@B_nodes,
                                                                                               C_node_id => 3446,
										               relationship_type => 'Unknown',
										               intermediate_count => 12,
											       B_node_literature_count_threshold=>3,
											       B_node_R_scaled_threshold=>0,
											       intermediate_type => '_1_23_',
										               known_R_scaled_score => 0,
										               known_literature_count => 0, 
										               avg_inferred_R_scaled_score => 42,
										               min_inferred_R_scaled_score => 37);
  
  Arguments: InferredRelations: A reference to an hash with hidden relationships results. The key of this hash is node-A and the value is a new hash with C-nodes as keys.
                                The values of this second hash are Literature::ImplicitRelations::ImplicitRelation objects, which describe the hidden relationship between A 
				and C-nodes. The arguments of an Literature::ImplicitRelations::ImplicitRelation object are described in more detail in the 
				Wbt::Literature::ImplicitRelations::ImplicitRelation module.
  
  Return: A Wbt::Literature::ImplicitRelations::ImplicitRelation object.


=head2 print_results_to_file

  Title: print_results_to_file
  
  Usage: $inferred_relations_set->print_results_to_file(sort_on=>'avg_inferred_R_scaled_score',
                                                        output_file_name=>'hidden_relations_results',
							db_cp=>$db_cp);
  
  Arguments: sort_on: sort the results on 'avg_inferred_R_scaled_score' or 'min_inferred_R_scaled_score'.
             output_file_name: name of the output file. 
	     db_cp: database_handler. 
  
  Return: A file with the hidden relationships analysis results.

=cut

sub new {
    my ($caller, %args) = @_;
    my $self = bless {
                 %args
    }, ref $caller || $caller;
    return $self;
}

=head

sub print_results_to_file {

   my ($self,%args)=@_;

   my $sort = $args{sort_on} || "avg_inferred_R_scaled_score";
   my $file_name =  $args{output_file_name} || "hidden_relations";
   my $db_cp = $args{db_cp} || die "Provide a database handle";
      
   $file_name=~s/ /_/g;
   $file_name = $file_name  . ".txt";
 
   open ( OUT, ">" . $file_name ) || die "can't open $file_name";

   print OUT "Implicit Relations\n\n";

   my %results = %{$self->{InferredRelations}};
   
   
   foreach my $A_node_BI (keys %results) {
   

        my $A_node_attributes = $db_cp->get_bi_attributes($A_node_BI);
	my $node_category = $A_node_attributes->category;
	my $node_name = $A_node_attributes->preferred_name;
	
	if($node_category eq 'gene') {
	   
	   my $symbol = $A_node_attributes->symbol;
	   
	   if($symbol ne '') {
	   
	      $node_name = $node_name . " (" . $symbol . ")";
	   }
	}
	
	$node_name=~s/&&/,/g;
	
	print OUT "Input concept (A): " . $node_name . "\n";
	print OUT "Category: " . $node_category . "\n\n";
	
	print OUT "Output concept (C)" . "\t" . "Category" . "\t" . "Relation type" . "\t" . "Known literature count" . "\t" . "Known R-scaled score" . "\t" . "Intermediate count" . "\t" . "Average R-scaled score" . "\t" . "Minimal R-scaled score" . "\n";
      
        my %sort_hash;
	
	my %inferred_relations = %{$results{$A_node_BI}};
	
	foreach my $C_node_BI (keys %inferred_relations) {
	
	        my $C_node = $inferred_relations{$C_node_BI};
		
		
		if($sort eq 'avg_inferred_R_scaled_score'){
		
		   $sort_hash{$C_node_BI} = $C_node->avg_inferred_R_scaled_score;
		}
		
		if($sort eq 'min_inferred_R_scaled_score'){
		
		   $sort_hash{$C_node_BI} = $C_node->min_inferred_R_scaled_score;
		}
		
		if($sort eq 'intermediate_count') {
		
		   $sort_hash{$C_node_BI} = $C_node->intermediate_count;
		}
	
	}
	
	
	foreach my $C_node_BI (sort { $sort_hash{$b} <=> $sort_hash{$a} } keys %sort_hash ) {
    
                my $C_node = $inferred_relations{$C_node_BI};
		my $C_node_attributes = $db_cp->get_bi_attributes($C_node_BI);
		my $C_name = $C_node_attributes->preferred_name;
		
		if($C_node_attributes->category eq 'gene') {
		        
		   if($C_node_attributes->symbol ne '') {
		   
		      $C_name .= " (" . $C_node_attributes->symbol . ")"; 
		   
		   }
		
		}else
		{
		
		  foreach my $alternative_name (@{$C_node_attributes->alternative_names}) {
				
		          $C_name .= " // " . $alternative_name;
		  
		  }
		}
		
		$C_name=~s/&&/,/g;
		
		print OUT $C_name . "\t" . $C_node_attributes->category . "\t" . $C_node->relation_type . "\t" .  $C_node->known_literature_count . "\t" .  $C_node->known_R_scaled_score . "\t" .  $C_node->intermediate_count . "\t" . $C_node->avg_inferred_R_scaled_score . "\t" . $C_node->min_inferred_R_scaled_score . "\n";
	
	}
	
	print OUT "\n\n";
        
   }
   
}

=cut

1;
