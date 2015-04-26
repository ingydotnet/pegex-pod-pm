use Test::More;

use lib 'lib';
use Pegex::Pod;

# XXX + Pegex::Pod::Grammar->tree;
sub parse { Pegex::Pod->new->parse(shift) }

# use XXX;
# XXX parse <<'...';
parse <<'...';
=head1 Test Pod

This I<is> a test.
...

pass 'Pod parsed';

done_testing;
