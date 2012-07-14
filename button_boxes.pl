#!/usr/bin/perl
#
# Button Boxes
#
# The Button Box widgets are used to arrange buttons with padding.

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

do_button_box();
Gtk3->main();

sub do_button_box {
    my $window = Gtk3::Window->new('toplevel');
    $window->set_title('Button Boxes');
    $window->set_border_width(10);
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );
    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my $box = Gtk3::Box->new( 'vertical', 0 );
    $box->set_homogeneous(FALSE);
    $window->add($box);

    my $frame_horiz = Gtk3::Frame->new('Horizontal Button Boxes');
    $box->pack_start( $frame_horiz, TRUE, TRUE, 10 );

    my $vbox = Gtk3::Box->new( 'vertical', 0 );
    $vbox->set_border_width(10);
    $vbox->set_homogeneous(FALSE);
    $frame_horiz->add($vbox);

    $vbox->pack_start( create_bbox( TRUE, 'Spread', 40, 'spread' ),
        TRUE, TRUE, 0 );

    $vbox->pack_start( create_bbox( TRUE, 'Edge', 40, 'edge' ),
        TRUE, TRUE, 5 );

    $vbox->pack_start( create_bbox( TRUE, 'Start', 40, 'start' ),
        TRUE, TRUE, 5 );

    $vbox->pack_start( create_bbox( TRUE, 'End', 40, 'end' ), TRUE, TRUE, 5 );

    my $frame_vert = Gtk3::Frame->new('Vertical Button Boxes');
    $box->pack_start( $frame_vert, TRUE, TRUE, 10 );

    my $hbox = Gtk3::Box->new( 'horizontal', 0 );
    $hbox->set_border_width(10);
    $hbox->set_homogeneous(FALSE);
    $frame_vert->add($hbox);

    $hbox->pack_start( create_bbox( FALSE, 'Spread', 30, 'spread' ),
        TRUE, TRUE, 0 );

    $hbox->pack_start( create_bbox( FALSE, 'Edge', 30, 'edge' ),
        TRUE, TRUE, 5 );

    $hbox->pack_start( create_bbox( FALSE, 'Start', 30, 'start' ),
        TRUE, TRUE, 5 );

    $hbox->pack_start( create_bbox( FALSE, 'End', 30, 'end' ), TRUE, TRUE,
        5 );

    $window->show_all();
}

sub create_bbox {
    my ( $horiz, $title, $spacing, $layout ) = @_;
    my $frame = Gtk3::Frame->new($title);

    my $bbox;

    if ($horiz) {
        $bbox = Gtk3::ButtonBox->new('horizontal');
    } else {
        $bbox = Gtk3::ButtonBox->new('vertical');
    }
    $bbox->set_border_width(5);
    $frame->add($bbox);

    $bbox->set_layout($layout);
    $bbox->set_spacing($spacing);

    $bbox->add( Gtk3::Button->new_from_stock('gtk-ok') );
    $bbox->add( Gtk3::Button->new_from_stock('gtk-cancel') );
    $bbox->add( Gtk3::Button->new_from_stock('gtk-help') );

    return $frame;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
