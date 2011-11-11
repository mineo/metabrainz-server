package MetaBrainz::Server;

use Moose;
BEGIN { extends 'Catalyst' }

use aliased 'MusicBrainz::Server::Translation';

__PACKAGE__->config(
    name => 'MetaBrainz::Server',
    default_view => 'Default',
    encoding => 'UTF-8',
    "View::Default" => {
        TEMPLATE_EXTENSION => '.tt',
        PRE_PROCESS => [
            'preprocess.tt'
        ],
        ENCODING => 'UTF-8',
    },
    static => {
        mime_types => {
            json => 'application/json; charset=UTF-8',
        },
        dirs => [ 'static' ],
        no_logs => 1
    }
);

__PACKAGE__->setup(qw(
    Static::Simple
    StackTrace
    Unicode::Encoding
));

__PACKAGE__->model('MB')->inject(
    FileCache => 'MusicBrainz::Server::Data::FileCache',
    static_dir => '/home/ollie/Work/MetaBrainz/root/static'
);

sub gettext  { shift; Translation->instance->gettext(@_) }
sub ngettext { shift; Translation->instance->ngettext(@_) }

sub form
{
    my ($c, $stash, $form_name, %args) = @_;
    die '$c->form required $stash => $form_name as arguments' unless $stash && $form_name;
    $form_name = "MetaBrainz::Server::Form::$form_name";
    Class::MOP::load_class($form_name);
    my $form = $form_name->new(%args, ctx => $c);
    $c->stash( $stash => $form );
    return $form;
}

sub form_posted {
    my $c = shift;
    return $c->req->method eq 'POST';
}

1;