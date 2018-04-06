package STDF::Simple;

use 5.10.0;
use strict;
use warnings;

use Moo;
use namespace::clean;

use STDF::Simple::stdf_parser;
=head1 NAME

STDF::Simple - Simple STDF parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Parses STDF version 4, returns records in array reference.
This module is useful for reading all records in STDF. All the records are eagerly parsed.
And returns in simple array reference.
 
Perhaps a little code snippet.

    use STDF::Simple;

    my $parser = STDF::Simple->new(std_file => $stdf);
    my $cpu = $parser->cpu;
    my $stdf_ver = $parser->stdf_ver;
    my $stream = $parser->stream;
    while(defiend(my $r = $stream->() ) ) {
        my $rec_name = $r->[0];      # 
        # $r is ArrayRef
        # 0 contains record type name, followed by record fields
        # $r->[1], $r->[2] ... contains record field
    }
    
    ...

=head1 CONSTRUCTOR

new(ARGS)
    Constructs new parser instance.
    
    std_file   required. input STDF file path or opened file handle.

    

=head1 METHODS

=head2 cpu

    Returns CPU type of std_file

=cut

=head2 stdf_ver

    Returns STDF version of the file.
=cut

=head2 stream

    Returns a sub-routine reference (underlying stream that 'next' method uses).
    Invoking the reference returns next object (and moving to next record) or undef if EOF is encountered.
    This method is provided so that user can directly get next record without method call overhead.

=cut

=head2 next

    Returns next record (array reference) in STDF file. undef at EOF.
    Array first element (0th) contains STDF record name or '???' in case of unknown record types.
    Subsequent elements contain STDF record fields (in order) defined in STDF version 4 spec.
        
=cut

has std_file  =>   (
    is  => 'ro',
    required => 1,
);

has excludes =>   (
    is   => 'ro',
    # optional arrayRef of record names to exclude
);

has _parser => (
    is   => 'ro',
    init_arg => undef,
    lazy  => 1,
    builder => 'build_parser',
    handles => {
        cpu   => 'cpu_type',
        stdf_ver => 'stdf_ver',
        
    }
);

has stream => (
    is   => 'ro',
    init_arg => undef,
    lazy    => 1,
    builder => 'build_stream',
    
);

sub next
{
    my $stream = $_[0]->stream;
    &{$stream}();
}
sub build_stream
{
    my $self = shift;
    my $parser = $self->_parser;
    $parser->stream;
}
sub build_parser
{
    my $self = shift;
    my $excludes = $self->excludes;
    my $file = $self->std_file;
    if(!defined($excludes)){
        $excludes = [];
    }
    my $parser = STDF::Simple::stdf_parser->new($file,@$excludes);
    return $parser;
}

=head1 AUTHOR

Nyan, C<< <nyanhtootin at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-stdf-simple at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=STDF-Simple>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc STDF::Simple


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=STDF-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/STDF-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/STDF-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/STDF-Simple/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2018 Nyan.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of STDF::Simple
