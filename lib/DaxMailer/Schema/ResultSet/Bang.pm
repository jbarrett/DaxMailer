package DaxMailer::Schema::ResultSet::Bang;

use Moo;
extends 'DaxMailer::Schema::ResultSet';

use Try::Tiny;
use Text::CSV_XS;

has csv => ( is => 'lazy' );
sub _build_csv {
    Text::CSV_XS->new ({
        sep_char => "\t",
        quote_char => undef
    });
}

sub create_from_post {
    my ( $self, $body ) = @_;
    my ( $category, $subcategory );
    my $bang;

    return unless (
        $body->{bang_site} &&
        $body->{bang_command} &&
        $body->{bang_url} &&
        $body->{bang_cat} &&
        $body->{bang_subcat} &&
        index( $body->{bang_url}, '{{{s}}}' ) >= 0
    );

    try {
        $category = $self->rs('Bang::Category')->find_or_create({
            name   => $body->{bang_cat},
            parent => undef,
        }) or die "Unable to retrieve category";

        $subcategory = $self->rs('Bang::Category')->find_or_create({
            name   => $body->{bang_subcat},
            parent => $category->id,
        }) or die "Unable to retrieve subcategory";

        $bang = $self->create({
            command       => $body->{bang_command},
            url           => $body->{bang_url},
            email_address => $body->{from},
            site_name     => $body->{bang_site},
            comments      => $body->{bang_comments},
            category_id   => $subcategory->id,
        }) or die "Unable to create bang";
    } catch {
        return 0;
    };

    return $bang;
}

sub pending {
    $_[0]->search({ moderated => 0 });
}

sub moderate {
    $_[0]->update({ moderated => 1 });
}

sub tsv {
    my ( $self ) = @_;
    join "\n",
    map {
        $self->csv->combine(
            $_->{command},
            $_->{site_name},
            $_->{url},
            $_->{email_address},
            $_->{category}->{parent_category}->{name},
            $_->{category}->{name},
            $_->{comments},
        );
        $self->csv->string;
    } $self
      ->prefetch({ category => 'parent_category' })
      ->hri
      ->all;
}

1;
