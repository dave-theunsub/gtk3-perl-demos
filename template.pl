#!/usr/bin/perl
#
# Description
#

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

do_foo();
Gtk3->main();

sub do_foo {
    my $window = Gtk3::Window->new;
    $window->set_title('template');
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );

    my $box = Gtk3::Box->new( 'vertical', 5 );
    $window->add($box);

    $window->show_all;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
