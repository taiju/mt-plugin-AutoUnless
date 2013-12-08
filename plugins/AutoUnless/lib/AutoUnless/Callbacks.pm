package AutoUnless::Callbacks;

use strict;
use warnings;

sub _tag_missing {
  my ( $cb, $ctx, $tag ) = @_;

  return unless $tag =~ 'unless';

  my $if_tag = _unless_tag_to_if( $tag );

  my $v = $ctx->{__handlers}{$if_tag};
  return unless $v;

  my $if_hdlr = _get_if_hdlr( $v );

  my $unless_hdlr_coderef = _if_hdlr_coderef_to_unless( $if_hdlr, $if_tag );

  $ctx->{__handlers}{$tag} =
    MT::Template::Handler->new( $unless_hdlr_coderef, $if_hdlr->type, $if_hdlr->super );
}

sub _unless_tag_to_if {
  my $unless_tag = shift;
  ( my $if_tag = $unless_tag ) =~ s/unless/if/;
  $if_tag;
}

sub _get_if_hdlr {
  my $v = shift;
  # Transfer from MT::Template::Context::handler_for
  ref( $v ) eq 'MT::Template::Handler' ?
    $v :
  ref( $v ) eq 'HASH' ?
    $v->{handler} :
  ref( $v ) eq 'ARRAY' ?
    MT::Template::Handler->new( @$v ) :
  # DEFAULT
    $v;
}

sub _if_hdlr_coderef_to_unless {
  my ( $if_hdlr, $if_tag ) = @_;
  $if_hdlr->type == 2 ?
    sub { !MT->handler_to_coderef( $if_hdlr->code )->( @_ ) } :
  # mt:IfDynamic and mt:IfStatic are special case.
  # Its handler type is 1 (block tag), but use it as conditional tag.
  $if_hdlr->type == 1 && $if_tag eq 'ifdynamic' ?
    sub { shift->slurp( @_ ) } :
  $if_hdlr->type == 1 && $if_tag eq 'ifstatic' ?
    sub { shift->else( @_ ) } :
  # DEFAULT
    $if_hdlr->code;
}

1;
