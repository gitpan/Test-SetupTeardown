package Test::SetupTeardown;

use strict;
use warnings;

use Test::Builder;

our $VERSION = 0.002;

sub new {

    my $class = shift;
    my %routines = @_;

    my $self = { tbuilder => Test::Builder->new,
                 setup => $routines{setup},
                 teardown => $routines{teardown} };

    bless $self, $class;
    return $self;

}

sub run_test {

    my ($self, $description, $coderef) = @_;
    my $exception_while_running_block;

    $self->{tbuilder}->note($description);

    # Run setup() routine before each test
    $self->{setup}->() if $self->{setup};

    eval {

        # Catch all exceptions thrown by the block, to be rethrown
        # later after the teardown has had a chance to run
        &$coderef;

    };

    if ($@) {

        # Stash this for now
        $exception_while_running_block = $@;

    }

    # Run teardown routine after each test
    $self->{teardown}->() if $self->{teardown};

    if ($exception_while_running_block) {

        # The teardown has run now, rethrow the exception
        die $exception_while_running_block;

    }

}

1;
__END__
=pod

=head1 NAME

Test::SetupTeardown -- Tiny Test::More-compatible module to group tests in clean environments

=head1 SYNOPSIS

  use Test::SetupTeardown;
  
  my $schema;
  my (undef, $temp_file_name) = tempfile();
  
  sub setup {
      $schema = My::DBIC::Schema->connect("dbi:SQLite:$temp_file_name");
      $schema->deploy;
  }
  
  sub teardown {
      unlink $temp_file_name;
  }
  
  my $environment = Test::SetupTeardown->new(setup => \&setup,
                                             teardown => \&teardown);
  
  $environment->run_test('reticulating splines', sub {
      my $spline = My::Spline->new(prereticulated => 0);
      can_ok($spline, 'reticulate');
      $spline->reticulate;
      ok($spline->is_reticulated, q{... and reticulation state is toggled});
                         });
  
  $environment->run_test(...);

=head1 DESCRIPTION

This module provides very simple support for xUnit-style C<setup> and
C<teardown> methods.  It is intended for developers who want to ensure
their testing environment is in a known-good state before running
their tests, and is left in an known-rather-okay state after.

A similar feature is provided in L<Test::Class>, but not everyone
wants to use that.

=head1 METHODS

=head2 new

  my $environment = Test::SetupTeardown->new(setup => CODEREF,
                                             teardown => CODEREF);

The constructor for L<Test::SetupTeardown>.

Both the C<setup> and C<teardown> arguments are optional (although if
you leave them both out, all you've accomplished is adding a header to
your tests).

=head2 run_test

  $environment->run_test('reticulating splines',
                         sub { ok(...); ... });

This method runs the C<setup> callback, then the tests, then the
C<teardown> callback.  If an exception is thrown in the coderef, it is
caught by C<run_test>, then the C<teardown> runs, then the exception
is thrown again (otherwise you'd get all green on your test report
since the flow would proceed to the C<done_testing;> at the end of
your test file).

No arguments are passed to either the C<setup>, C<teardown> or test
callbacks.  Perl supports closures so this has not been a problem so
far (although it might become one).

The description is displayed before the test results with
L<Test::Builder>'s C<note()> method.

=head1 BUGS AND LIMITATIONS

Currently there is no simple way, short of editing your tests, to
leave traces of your environment when tests have failed so you can go
all forensic on your SQLite database and determine what went wrong.

I'm considering two options:

=over 4

=item * Provide the option to not run the C<teardown> callback when
tests have failed or an exception has been thrown.  Trying to
determine if tests have failed is probably going to be rather hard
since at no point L<Test::SetupTeardown> is aware of what tests
actually B<are>.

=item * Provide named callbacks instead of a single C<teardown> (and,
why not, C<setup>, except I don't really see what you'd use them for).
Then during the test the user can decide which ones to disable
depending on what he wants to autopsy.

=back

=head1 SEE ALSO

L<Test::More>

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012, 2013 SFR

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
