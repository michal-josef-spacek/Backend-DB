use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'DB backend abstract class.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0.03;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Backend-DB';
readme_from 'DB.pm';
recursive_author_tests('xt');
requires 'Class::Utils' => 0;
requires 'Error::Pure' => 0;
requires 'Scalar::Util' => 0;
requires 'perl' => '5.8.0';
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Backend-DB/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Backend-DB';
resources 'repository' => 'git://github.com/michal-josef-spacek/Backend-DB';
test_requires 'Class::Unload' => 0;
test_requires 'English' => 0;
test_requires 'Error::Pure::Utils' => 0;
test_requires 'File::Object' => 0;
test_requires 'Mo' => 0;
test_requires 'Mo::utils' => 0.26;
test_requires 'Schema::Test' => 0;
test_requires 'Test::MockObject' => 0;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.02';

# Run.
WriteAll();
