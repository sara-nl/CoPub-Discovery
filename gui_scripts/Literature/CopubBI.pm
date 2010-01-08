package Literature::CopubBI;

#POD

use strict;

sub new {
    my ($caller, %args) = @_;
    my $self = bless {
                 %args
    }, ref $caller || $caller;
    return $self;
}


1;
