#!/usr/bin/env perl

use strict;
use warnings;

use lib 'blib/lib';

use Test::More;

use Geo::OSM::Overpass;
use Geo::OSM::Overpass::Plugin;

my $num_tests = 0;

my $op = Geo::OSM::Overpass->new();
ok(defined $op, 'Geo::OSM::Overpass->new()'.": called") or BAIL_OUT('Geo::OSM::Overpass->new()'.": failed, can not continue."); $num_tests++;

my $plug = Geo::OSM::Overpass::Plugin->new({
	'engine' => $op
});
ok(defined $plug->engine(), "checking engine()"); $num_tests++;
ok($plug->engine() eq $op, "checking engine()"); $num_tests++;

ok(defined($plug) && 'Geo::OSM::Overpass::Plugin' eq ref $plug, 'Geo::OSM::Overpass::Plugin->new()'.": called") or BAIL_OUT('Geo::OSM::Overpass::Plugin->new()'." : call has failed, can not continue."); $num_tests++;
ok(! defined $plug->gorun(), "checking gorun() : it must fail"); $num_tests++;

# END
done_testing($num_tests);
