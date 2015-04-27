package Pegex::Pod;

use Mo;
use Pegex::Parser;

sub parse {
    my ($self, $pod) = @_;
    my $parser = Pegex::Parser->new(
        grammar => Pegex::Pod::Grammar->new,
        receiver => Pegex::Pod::AST->new,
        # debug => 1,
    );
    return $parser->parse($pod);
}

package Pegex::Pod::Grammar;
use base 'Pegex::Grammar';

use constant text => <<'...';
%grammar pod
%version 0.0.1

Pod: (
  | over-back
  | for
  | begin-end
  | head
  | pod
  | encoding
  | cut
  | verbatim-paragraph
  | paragraph
)*

# verbatim paragraph is a paragraph that begins with horizontal whitespace
verbatim-paragraph: TODO
#   {
#     ^^\h+? \S.+? <blank-line>
#   }

# paragraph is a stream of text and/or format codes
# beginning with a non-whitespace char (and not =) or a format code
paragraph: ( text | format-codes )+ EOL blank-line?
# / ( NS ANY* EOL )+ blank-line? /

# blank line is a stream of whitespace surrounded by newlines
blank-line: / SPACE* EOL /
#   {
#     \n\h*?[\n|$]
#   }

# tokens for matching streams of text
name: TODO
#   {
#     <-[\s\>\/\|]>+
#   }

text: / ( (: (!: EOL EOL | WORD LANGLE ) ANY )+ ) /

multiline-text: / ( [^ '>' ]+ ) /

section: TODO
#   {
#     <-[\v\>\/\|]>+
#   }

# command paragraphs
pod: TODO #      { ^^\=pod <blank-line> }
cut: TODO #      { ^^\=cut <blank-line> }
encoding: TODO # { ^^\=encoding \h <name> \h* <blank-line> }

# list processing
over-back: TODO
# { <over>
# [
#     <item> | <paragraph> | <verbatim-paragraph> | <for> |
#     <begin-end> | <pod> | <encoding> | <over-back>
# ]*
# <back>
# }

over: TODO #     { ^^\=over [\h<[0..9]>]? <blank-line> }
item: TODO #
# { ^^\=item \h+ <name>
# [
#     [ \h+ <paragraph>  ]
#     | [ \h* <blank-line> <paragraph>? ]
# ]
# }
back: TODO #      { ^^\=back <blank-line> }

# format processing
# TODO check the name matches for the begin/end pair
begin-end: TODO # { <begin> .*? <end> }
begin: TODO #     { ^^\=begin \h+ <name> <blank-line>}
end: TODO #       { ^^\=end \h+ <name>  <blank-line>  }
for: TODO #       { ^^\=for \h <name> \h+ <paragraph> }

# headers
head:
  / '=head' ([1-4]) SPACE+ / paragraph

# basic formatting codes
# TODO enable formatting within formatting
format-codes:
  | italic
  | bold
  | code
  | link
italic: / 'I<' multiline-text '>' /
bold:   / 'B<' multiline-text '>' /
code:   / 'C<' multiline-text '>' /

# links are more complicated
link: TODO
# { L\<
#     [
#     [ <url>  ]
#     | [ <text> \| <url> ]
#     | [ <name> \| <section> ]
#     | [ <name> [ \|? \/ <section> ]? ]
#     | [ \/ <section> ]
#     | [ <text> \| <name> \/ <section> ]
#     ]
# \>
# }
url: TODO #           { [ https? | ftp ] '://' <-[\v\>\|]>+ }

TODO: /XXX/;
...

package Pegex::Pod::AST;
use base 'Pegex::Tree';

# sub final {
#     use XXX;
#     XXX @_;
# }

sub got_head {
    my ($self, $got) = @_;
    { "head$got->[0]" => $got->[1]{para} };
}

sub got_paragraph {
    my ($self, $got) = @_;
    { para => $self->flatten($got) };
}

sub got_text {
    my ($self, $got) = @_;
    { text => $got };
}

sub got_italic {
    my ($self, $got) = @_;
    { italic => $got };
}

1;
