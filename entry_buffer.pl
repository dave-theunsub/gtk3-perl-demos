#!/usr/bin/perl
#
# Entry Buffer
#
# GtkEntryBuffer provides the text content in a GtkEntry.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

do_entry_buffer();
Gtk3->main();

sub do_entry_buffer {
    my $window = Gtk3::Dialog->new();
    $window->add_button( 'gtk-close', 1 );
    $window->set_title('GtkEntryBuffer');
    $window->set_resizable(FALSE);
    $window->signal_connect( response => sub { Gtk3->main_quit } );
    $window->signal_connect( destroy  => sub { Gtk3->main_quit } );

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    # This box will hold our label and entries
    my $box = Gtk3::Box->new( 'vertical', 5 );
    $box->set_border_width(5);
    $box->set_homogeneous(FALSE);
    $window->get_content_area()->add($box);

    my $label = Gtk3::Label->new('');
    $label->set_markup( 'Entries share a buffer.'
            . ' Typing in one is reflected in the other.' );
    $box->pack_start( $label, FALSE, FALSE, 0 );

    my $buffer = Gtk3::EntryBuffer->new( undef, 0 );

    # Create our first entry
    my $entry = Gtk3::Entry->new_with_buffer($buffer);
    $box->pack_start( $entry, FALSE, FALSE, 0 );

    # Create our second entry
    my $entry2 = Gtk3::Entry->new_with_buffer($buffer);
    $box->pack_start( $entry2, FALSE, FALSE, 0 );
    $entry2->set_visibility(FALSE);

    $window->show_all();
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
