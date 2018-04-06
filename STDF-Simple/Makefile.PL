use 5.10.0;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'STDF::Simple',
    AUTHOR           => q{Nyan <HT_Nyan@utacgroup.com>},
    VERSION_FROM     => 'lib/STDF/Simple.pm',
    ABSTRACT_FROM    => 'lib/STDF/Simple.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.10.0',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        #'ABC'              => '1.6',
        #'Foo::Bar::Module' => '5.0401',
         'Moo'              => 0,
         'namespace::clean' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'STDF-Simple-*' },
);
