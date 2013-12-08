#!/usr/bin/env perl

use strict;
use warnings;

use lib qw( t/lib extlib lib );

use Test::More;
use Test::Base;

use MT::Template::Context;
use MT::Builder;
use MT::Test qw( :db :data :cms );

sub build {
  my $tmpl = shift;

  my $ctx = MT::Template::Context->new;

  my $blog = MT::Blog->load(1);
  $ctx->stash('blog', $blog);
  $ctx->stash('blog_id', $blog->id);
  $ctx->stash('builder', MT::Builder->new);

  my $entry  = MT::Entry->load( 1 );

  $ctx->{current_timestamp} = '20040816135142';

  local $ctx->{__stash}{entry} = $entry if $tmpl =~ m/<MTEntry/;
  $ctx->{__stash}{entry} = undef if $tmpl =~ m/MTComments|MTPings/;
  $ctx->{__stash}{entries} = undef if $tmpl =~ m/MTEntries|MTPages/;
  $ctx->stash('comment', undef);

  my $builder = MT::Builder->new;
  my $tokens = $builder->compile( $ctx, $tmpl ) or die $builder->errstr;
  $builder->build( $ctx, $tokens );
}

filters {
  template => [qw( build chomp )],
  built => [qw( chomp )],
};

run_is 'template' => 'built';

done_testing;

__END__

Copy from t/35-tags.dat.
Exclude exist *unless* tag.
All test case changes invert result.

=== mt:UnlessNonEmpty
--- template
<MTUnlessNonEmpty tag="MTDate"><MTElse>nonempty</MTUnlessNonEmpty>
--- built
nonempty
=== mt:UnlessNonZero
--- template
<MTUnlessNonZero tag="MTBlogEntryCount"><MTElse>nonzero</MTUnlessNonZero>
--- built
nonzero
=== mt:BlogUnlessCCLicense 1
--- template
<MTBlogs><MTBlogUnlessCCLicense><MTElse><MTBlogCCLicenseURL>
<MTBlogCCLicenseImage>
<MTCCLicenseRDF></MTBlogUnlessCCLicense></MTBlogs>
--- built -chomp
http://creativecommons.org/licenses/by-nc-sa/2.0/
http://creativecommons.org/images/public/somerights20.gif
<!--
<rdf:RDF xmlns="http://web.resource.org/cc/"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<Work rdf:about="http://narnia.na/nana/">
<dc:title>none</dc:title>
<dc:description>Narnia None Test Blog</dc:description>
<license rdf:resource="http://creativecommons.org/licenses/by-nc-sa/2.0/" />
</Work>
<License rdf:about="http://creativecommons.org/licenses/by-nc-sa/2.0/">
</License>
</rdf:RDF>
-->

=== mt:BlogUnlessCCLicense 2
--- template
<MTBlogUnlessCCLicense><MTElse>1</MTBlogUnlessCCLicense>
--- built
1

=== mt:UnlessIsAncestor
--- template
<MTCategories show_empty="1"><MTUnlessIsAncestor child="subfoo"><MTElse><MTCategoryLabel> is an ancestor to subfoo</MTUnlessIsAncestor></MTCategories>
--- built
foo is an ancestor to subfoosubfoo is an ancestor to subfoo
=== mt:UnlessCommetsActive
--- template
<MTEntries lastn="1"><MTUnlessCommentsActive><MTElse>active</MTUnlessCommentsActive></MTEntries>
--- active
active

=== mt:UnlessCommentsAccepted
--- template
<MTEntries lastn="1"><MTUnlessCommentsAccepted><MTElse>accepted</MTUnlessCommentsAccepted></MTEntries>
--- built
accepted

=== mt:RegistrationNotRequired
--- template
<MTUnlessRegistrationNotRequired>yes<MTElse>no</MTElse></MTUnlessRegistrationNotRequired>

--- built
yes

=== mt:RegistrationRequired
--- template
<MTUnlessRegistrationRequired>yes<MTElse>no</MTElse></MTUnlessRegistrationRequired>
--- built
no

=== mt:BlogUnlessCommentsOpen
--- template
<MTBlogUnlessCommentsOpen>yes<MTElse>no</MTElse></MTBlogUnlessCommentsOpen>
--- built
no

=== mt:UnlessStatic
--- template
<MTUnlessStatic>1</MTUnlessStatic>
--- built

=== mt:UnlessDynamic 
--- template
<MTUnlessDynamic>1</MTUnlessDynamic>
--- built
1

=== mt:UnlessTypeKeyToken
--- template
<MTUnlessTypeKeyToken><MTElse>tokened</MTUnlessTypeKeyToken>
--- built
tokened

=== mt:UnlessCommentsModerated
--- template
<MTUnlessCommentsModerated><MTElse>moderated</MTUnlessCommentsModerated>
--- built
moderated

=== mt:UnlessRegistrationAllowed
--- template
<MTUnlessRegistrationAllowed><MTElse>allowed</MTUnlessRegistrationAllowed>
--- built
allowed

=== mt:UnlessArchiveTypeEnabled
--- template
<MTUnlessArchiveTypeEnabled type="Category"><MTElse>enabled</MTUnlessArchiveTypeEnabled>
--- built
enabled

=== mt:UnlessCategory
--- template
<MTEntries lastn="1" offset="3"><MTUnlessCategory name="foo"><MTElse>in category</MTUnlessCategory></MTEntries>
--- built
in category

=== mt:UnlessNeedEmail
--- template
<MTUnlessNeedEmail>email needed</MTUnlessNeedEmail>
--- built
email needed

=== mt:UnlessAllowCommentHTML
--- template
<MTUnlessAllowCommentHTML><MTElse>comment html allowed</MTUnlessAllowCommentHTML>
--- built
comment html allowed

=== mt:UnlessCommentsAllowed
--- template
<MTUnlessCommentsAllowed><MTElse>comments allowed</MTUnlessCommentsAllowed>
--- built
comments allowed

=== mt:UnlessPingsActive
--- template
<MTEntries lastn='1'><MTUnlessPingsActive><MTElse>pings active</MTUnlessPingsActive></MTEntries>
--- built
pings active

=== mt:UnlessPingsAccepted
--- template
<MTEntries lastn='1'><MTUnlessPingsAccepted><MTElse>pings accepted</MTUnlessPingsAccepted></MTEntries>
--- built
pings accepted

=== mt:UnlessPingsAllowed
--- template
<MTEntries lastn='1'><MTUnlessPingsAllowed><MTElse>pings allowed</MTUnlessPingsAllowed></MTEntries>
--- built
pings allowed

=== mt:EntryUnlessAllowComments
--- template
<MTEntries lastn='1'><MTEntryUnlessAllowComments><MTElse>entry allows comments</MTEntryUnlessAllowComments></MTEntries>
--- built
entry allows comments

=== mt:EntryUnlessCommentsOpen
--- template
<MTEntries lastn='1'><MTEntryUnlessCommentsOpen><MTElse>entry comments open</MTEntryUnlessCommentsOpen></MTEntries>
--- built
entry comments open

=== mt:EntryUnlessAllowPings
--- template
<MTEntries lastn='1'><MTEntryUnlessAllowPings><MTElse>entry allows pings</MTEntryUnlessAllowPings></MTEntries>
--- built
entry allows pings

=== mt:EntryUnlessExtended
--- template
<MTEntries lastn='1'><MTEntryUnlessExtended><MTElse>entry is extended</MTEntryUnlessExtended></MTEntries>
--- built
entry is extended

=== mt:CommenterUnlessTrusted
--- template
<MTComments lastn='3' glue=','><MTIfNonEmpty tag='CommenterName'><MTCommenterName>: <MTCommenterUnlessTrusted>trusted<MTElse>untrusted</MTElse></MTCommenterUnlessTrusted><MTElse><MTCommentAuthor></MTIfNonEmpty></MTComments>
--- built
Chucky Dee: untrusted,Comment 3: trusted,John Doe: untrusted

=== mt:UnlessExternalUserManagement
--- template
<MTUnlessExternalUserManagement>Not External</MTUnlessExternalUserManagement>
--- built
Not External

=== mt:UnlessFolder 1
--- template
<MTPages id='22'><MTUnlessFolder name='download'>download</MTUnlessFolder></MTPages>
--- built

=== mt:UnlessFolder 2
--- template
<MTPages id='23'><MTUnlessFolder name='download'>download</MTUnlessFolder></MTPages>
--- built
download

=== mt:UnlessImageSupport
--- template
<MTUnlessImageSupport><MTElse>Supported</MTUnlessImageSupport>
--- built
Supported

=== mt:UnlessPingsModerated
--- template
<MTUnlessPingsModerated><MTElse>Moderated</MTUnlessPingsModerated>
--- built
Moderated

=== mt:UnlessRequireCommentEmails
--- template
<MTUnlessRequireCommentEmails>Requied</MTUnlessRequireCommentEmails>
--- built
Requied

=== mt:EntryUnlessCategory
--- template
<MTEntries category="foo" lastn="1"><MTEntryUnlessCategory category='foo'><MTElse><MTCategoryLabel></MTEntryUnlessCategory></MTEntries>
--- built
foo

=== mt:UnlessWebsite
--- template
<MTUnlessWebsite>if<MTElse>else</MTUnlessWebsite>
--- built
if

=== mt:WebsiteUnlessCCLicense
--- template
<MTBlogParentWebsite><MTWebsiteUnlessCCLicense><MTElse>1</MTWebsiteUnlessCCLicense></mt:BlogParentWebsite>
--- built
1

