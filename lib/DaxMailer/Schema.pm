package DaxMailer::Schema;

# ABSTRACT: DBIC Schema base class

use Moo;
extends 'DBIx::Class::Schema';

use FindBin;
my $sqldir = $FindBin::Dir . "/../sql/";
our $VERSION = 3;

has app => (
    is => 'rw',
);

sub generate_diff {
    my ( $self, $previous_version ) = @_;

    $self->create_ddl_dir(
        [ qw/ PostgreSQL SQLite / ],
        $self->schema_version,
        $sqldir,
        $previous_version
    );
}

sub deploy_or_upgrade {
    my ( $self ) = @_;

    if ( $self->get_db_version ) {
        $self->upgrade;
    }
    else {
        $self->deploy;
    }
}

__PACKAGE__->load_components(qw/ Schema::Versioned Helper::Schema::QuoteNames /);
__PACKAGE__->upgrade_directory($sqldir);
__PACKAGE__->load_namespaces();

1;
