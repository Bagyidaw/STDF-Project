package STDF::Record;

use 5.006;
use strict;
use warnings;
use Moo::Role;
use namespace::clean;

=head1 NAME

STDF::Record - The great new STDF::Record!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

This role is purely interface.

    use STDF::Record;

    ...


=head1 METHODS

=head2 rec_name

Retrieve 3 letter record name

=cut


=head2 rec_typ  rec_sub

Returns record typ,sub. 

=cut

=head2  rec_typsub

Returns a unique string (for typ,sub)

=head2 cpu_type

Returns CPU type, refer to STDF spec on cpu type values.

Data in raw_record, rec_header, rec_body are in endian specified by cpu_type.

=cut

=head2 fields

The implementing class should return array reference that contains fields in STDF record.
fields[0] being 1st field in STDF in order as stated in STDF spec V4.
For example, if $r is holding MIR record instance, then

    my $fields = $r->fields;
    $fields->[0]  # will contain SETUP_T, 
    $fields->[1]  # START_T, etc.
    
The representation of type (of each field) is up to implementer-defined.
i.e timestamp may be represented as object.
If STDF record has optional fields at the end, they may be absent in fields.

=cut


=head2 rec_length

Returns length(rec_body) in bytes

=cut

=head2 rec_header

Returns record header (always 4 bytes)

=cut

=head2 rec_body

Returns record body.

=cut

=head2 raw_record

Returns binary record (header+body)

=cut


=head1 AUTHOR

Nyan, C<< <nyanhtootin at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-stdf-record at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=STDF-Record>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc STDF::Record


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=STDF-Record>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/STDF-Record>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/STDF-Record>

=item * Search CPAN

L<http://search.cpan.org/dist/STDF-Record/>

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

requires qw( rec_name    rec_typ    rec_sub     rec_typsub
             cpu_type    rec_length rec_header  rec_body raw_record
);


1; # End of STDF::Record
