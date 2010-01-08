package Literature::GenericObject;

use strict;
use warnings;


#POD

=head2 new

    Title      : new
    Usage      : my $gen_obj = Wbt::GenericObject->new(%hash)
    Function   : Blesses a hash as an object. Hash values can now be retrieved using $go->hash_key
    Arguments  : A hash
    Returns    : A generic object

=cut



sub new {
    my ($caller, %args) = @_;
    my $self = bless
    {
                %args
                 }, ref $caller || $caller;
}

1;
