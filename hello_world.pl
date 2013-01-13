#!/usr/bin/perl
#
# Simple Hello World app; mostly for github front page
#

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new;
$window->set_title('Hello World!');
$window->set_default_size( 300, -1 );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

my $box = Gtk3::Box->new( 'vertical', 5 );
$window->add($box);

$box->pack_start( Gtk3::CheckButton->new_with_label('use strict;'),
    FALSE, FALSE, 0 );

$box->pack_start( Gtk3::CheckButton->new_with_label('use warnings;'),
    FALSE, FALSE, 0 );

$box->pack_start( Gtk3::CheckButton->new_with_label('use Gtk3;'),
    FALSE, FALSE, 0 );

my $bbox = Gtk3::ButtonBox->new('horizontal');
$bbox->set_layout('end');
$box->pack_start( $bbox, FALSE, FALSE, 5 );

$bbox->add( Gtk3::Button->new_from_stock('gtk-apply') );
$bbox->add( Gtk3::Button->new_from_stock('gtk-close') );

$window->show_all;

Gtk3->main();

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
