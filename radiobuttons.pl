#!/usr/bin/perl
#
# GtkRadioButton — A choice from multiple check buttons
#

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new;
$window->set_title( 'GtkRadioButton Demo' );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );
$window->set_default_size( 250, 100 );
$window->set_border_width( 10 );

my $box = Gtk3::Box->new( 'vertical', 6 );
$window->add( $box );

my $button1
    = Gtk3::RadioButton->new_with_label_from_widget( undef, 'Button 1', );
$button1->signal_connect( toggled => \&toggled, 1 );
$box->pack_start( $button1, FALSE, FALSE, 0 );
my $button2
    = Gtk3::RadioButton->new_with_label_from_widget( $button1, 'Button 2', );
$button2->signal_connect( toggled => \&toggled, 2 );
$box->pack_start( $button2, FALSE, FALSE, 0 );
my $button3
    = Gtk3::RadioButton->new_with_label_from_widget( $button1, 'Button 3', );
$button3->signal_connect( toggled => \&toggled, 3 );
$box->pack_start( $button3, FALSE, FALSE, 0 );

$window->show_all;

Gtk3->main();

sub toggled {
    my ( $button, $name ) = @_;
    my $state;

    if ( $button->get_active ) {
        $state = 'on';
    } else {
        $state = 'off';
    }
    print 'Button ', $name, ' was turned ', $state, "\n";
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
