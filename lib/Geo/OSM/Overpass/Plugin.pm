package Geo::OSM::Overpass::Plugin;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my $class = $_[0];
	my $params = $_[1];

	$params = {} unless defined $params;

	my $parent = ( caller(1) )[3] || "N/A";
	my $whoami = ( caller(0) )[3];

	my $self = {
		'engine' => undef
	};
	bless $self => $class;

	if( exists $params->{'engine'} ){ $self->{'engine'} = $params->{'engine'} } else { print STDERR "$whoami (via $parent) : input parameter 'engine' was not specified.\n"; return undef }

	return $self
}
sub	engine { return $_[0]->{'engine'} }
sub	gorun { print STDERR __PACKAGE__."::gorun() : you must override me.\n"; return undef }

# pod starts here

=head1 NAME

Geo::OSM::Overpass::Plugin - parent class for all plugins for L<Geo::OSM::Overpass>

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

This class is only intended to be used as the parent class for all plugins
under L<Geo::OSM::Overpass>. All required for the new plugin is to implement
the C<gorun()> method.

Below is an example of how to create a plugin called
C<Geo::OSM::Overpass::Plugin::NodeInfo> which fetches information about a node
given its id from OpenStreetMap.

    package Geo::OSM::Overpass::Plugin::NodeInfo;

    use Geo::OSM::Overpass::Plugin;
    use parent 'Geo::OSM::Overpass::Plugin';

    # there is no need to overwrite the constructor, only the C<gorun()> method
    sub gorun {
        my $self = $_[0];
        my $nodeid = $_[1];

        # get the Geo::OSM::Overpass object (aka the engine)
        # which will do all the communication work with the server
	# the engine has already been created by the caller of
	# the plugin (gorun() actually)
	# and has been set up with whatever parameters required.
        my $eng = $self->engine();
        die unless defined $eng;

        # form the query, in this case, as XML
        my $q =
	    # this is the preamble provided by the engine
	    # it will output timeout, output format etc.
	    $eng->_overpass_XML_preamble()
	    .
	    "<id-query ref='$nodeid' type='node'/>\n"
	    .
	    # and the postamble to close the query,
	    # again supplied by the engine
	    $eng->_overpass_XML_postamble()
	;
	print "The query is:\n$q\n";
	# <osm-script timeout="23" output="xml">
	#   <id-query ref="3290997140" type="node"/>
	#   <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
	#   <recurse from="_" into="_" type="down"/>
	#   <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="skeleton" n="" order="quadtile" s="" w=""/>
	# </osm-script>

	# now execute the query using the engine
	if( ! $eng->query($q) ){
		print STDERR "Geo::OSM::Overpass::Plugin::NodeInfo::gorun() : call to query() has failed for query:\n$q\n";
		return undef; # failed
	}
	# success, result is already stored in engine via the query() call.
	# Result can be accessed using $eng->last_query_result()
	# if you want to filter out something in the XML result then
	# you can modify result like so
	# (note: last_query_result() returns SCALAR REF to result text):
	${$eng->last_query_result()} =~ s/node/BLIAKO/g;

	return 1; # success (or return anything you like)
    } # end of gorun()
    # and that's it for this module

    # now in main
    package main;
    use Geo::BoundingBox;
    use Geo::OSM::Overpass;
    use Geo::OSM::Overpass::Plugin::NodeInfo;
    my $engine = Geo::OSM::Overpass->new();
    die unless defined $engine;
    my $bbox = Geo::BoundingBox();
    die unless $bbox->bounded_by(35.156119, 33.373826, 35.157053, 33.374185);
    $engine->bbox($bbox);
    my $plug = Geo::OSM::Overpass::Plugin::NodeInfo->new({
	'engine' => $engine
    });
    die unless defined $plug;
    # run the plugin with specified node id as param
    die unless $plug->gorun('3290997140');
    print "results:\n".${$eng->last_query_result()}."\n";
    # prints
    # <?xml version="1.0" encoding="UTF-8"?>
    # <osm version="0.6" generator="Overpass API 0.7.55.7 8b86ff77">
    # <note>The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.</note>
    # <meta osm_base="2019-01-11T11:11:11Z"/>
    #   <node id="3290997140" lat="35.1567148" lon="33.3741831">
    #     <tag k="highway" v="bus_stop"/>
    #     <tag k="name" v="Archbishop Makariou C' Avenue 1"/>
    #   </node>
    # </osm>


=head1 SUBROUTINES/METHODS

=head2 C<< new({'engine' => $eng}) >>

Constructor. A hashref of parameters contains the
only required parameter which is an already created
L<Geo::OSM::Overpass> object. If in your plugin have
no use for this, then call it like C<new({'engine'=>undef})>


=head2 C<< gorun(...) >>

Executes the plugin logic possibly using the supplied
L<Geo::OSM::Overpass> object (aka the engine).

On failure it returns C<undef>. On success it returns 1
or any data structure the plugin author sees fit.


=head2 C<< engine() >>

Returns the L<Geo::OSM::Overpass> object set as
the plugin's engine during construction.

=head1 AUTHOR

Andreas Hadjiprocopis, C<< <bliako at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-geo-osm-overpass-plugin at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geo-OSM-Overpass-Plugin>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geo::OSM::Overpass::Plugin


You can also look for information at:

=over 4

=item * L<Geo::OSM::Overpass> aka the engine.

=item * L<Geo::BoundingBox> a geographical bounding box class.

=item * L<https://www.openstreetmap.org> main entry point

=item * L<https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide> Overp
ass API
query language guide.

=item * L<https://overpass-turbo.eu> Overpass Turbo query language online
sandbox. It can also convert to XML query language.

=item * L<http://overpass-api.de/query_form.html> yet another online sandbox and
converter.

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-OSM-Overpass-Plugin>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-OSM-Overpass-Plugin>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Geo-OSM-Overpass-Plugin>

=item * Search CPAN

L<https://metacpan.org/release/Geo-OSM-Overpass-Plugin>

=back

=head1 DEDICATIONS

Almaz

=head1 ACKNOWLEDGEMENTS

The OpenStreetMap project and all the good people who
thought it, implemented it, collected the data and
publicly host it.

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Andreas Hadjiprocopis.

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

1; # End of Geo::OSM::Overpass::Plugin
