use 5.006;
use strict;
use warnings;
use Module::Build;

my $class = Module::Build->subclass(
    class => 'Module::Build::WithDebuild',
    code => q{
        sub ACTION_debuild {
            system("debuild -i -us -uc -b");
        }
    },
    );

my $builder = $class->new(
    module_name         => 'Test::SetupTeardown',
    license             => 'restrictive',
    dist_author         => q{Fabrice Gabolde <fabrice.gabolde@uperto.com>},
    dist_version_from   => 'lib/Test/SetupTeardown.pm',
    dist_abstract       => 'Minimalist package to simplify writing unit tests with setup and teardown methods',
    configure_requires => { 'Module::Build' => '0.36_14' },
    build_requires => {
        'Test::More' => 0,
        'Test::Exception' => 0,
    },
    requires => {
        'perl' => 5.006,
        'Test::Builder' => 0,
    },
    add_to_cleanup      => [ 'Test-SetupTeardown-*' ],
    meta_merge          => { resources =>
                             { repository => 'https://bitbucket.org/fgabolde/test-setupteardown' } },
);

$builder->create_build_script();
