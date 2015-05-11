package Dist::Zilla::Stash::GitHub;

# ABSTRACT: The great new Dist::Zilla::Stash::GitHub!

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

use Git::Sub;
use Try::Tiny;

sub mvp_aliases { { user => 'username', id => 'username', token => 'password' } }

=attr username

String, read-write-private, required.

The GitHub username.  'user' or 'id' will be accepted as aliases.

=attr password

String, read-write-private, required.

The user's password.  Or, B<preferably>, a distinct identity token.  Seriously.

'token' will be accepted as an alias.

=cut

has username => (
    is      => 'rwp',
    isa     => 'Str',
    builder => sub {
        my $self = shift @_;

        my $user = try { git::config 'github.user' }
            or confess 'Cannot determine github user!';

        return $user;
    },
);

has password => (
    is      => 'rwp',
    isa     => 'Str',
    builder => sub {
        my $self = shift @_;

        # look in the usual gittish places
        my $token
            =  try { git::config 'github.token'    }
            || try { git::config 'github.password' }
            || try { git::config 'github.pass'     }
        ;

        confess 'Cannot find a github token or password!'
            unless $token;

        return $token;
    },
);

with 'Dist::Zilla::Role::Stash::Login';

__PACKAGE__->meta->make_immutable;
!!42;
__END__

=for Pod::Coverage mvp_aliases

=head1 SYNOPSIS

    # in your ~/.dzil/config.ini
    [%GitHub]
    username = RsrchBoy
    password = la la la la la

=head1 DESCRIPTION

Right now, a bog-standard, simple little stash to keep one github token in a
central location...  As everything seems to be looking for one in different
places, or keeping their own somewhere.

Ideally, this will be less zombie-like in the not-too-distant future, and if
the id/token information is not embedded in one's C<~/.dzil/config.ini> it
will be looked for in the usual suspect locations.

=head1 TODO

* "Get smarter" about looking up our github id/token.

* Keep our id/token in a distinct config file (optionally?)

=head1 SEE ALSO

Dist::Zilla::Role::Stash::Login

https://github.com/settings/tokens

=cut
