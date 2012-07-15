#!/usr/bin/perl
#
# Expander
#
# GtkExpander allows to provide additional content that is initially hidden. This is also known as "disclosure triangle".
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

do_expander();
Gtk3->main();

sub do_expander {
    my $window = Gtk3::Dialog->new();
    $window->add_button( 'gtk-close', 1 );
    $window->set_title('GtkExpander');

    $window->set_resizable(FALSE);
    $window->signal_connect( response => sub { Gtk3->main_quit } );
    $window->signal_connect( destroy  => sub { Gtk3->main_quit } );

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my $box = Gtk3::Box->new( 'vertical', 5 );
    $box->set_border_width(5);
    $box->set_homogeneous(FALSE);
    $window->get_content_area()->add($box);

    my $label = Gtk3::Label->new('');
    $label->set_markup(
        'Expander demo.' . ' Click on the triangle for details.' );
    $box->pack_start( $label, FALSE, FALSE, 0 );

    # Create our expander
    my $expander = Gtk3::Expander->new('Details');
    $box->pack_start( $expander, FALSE, FALSE, 0 );
    $expander->signal_connect(
        activate => sub {
            print "Expander has been activated!\n";
        } );

    # This label will show up once expanded
    my $label2 = Gtk3::Label->new('');
    $label2->set_text('Details can be shown or hidden.');
    $expander->add($label2);

    $window->show_all();
}

# This library is free software; you can redistribute it and/or
# # modify it under the terms of the GNU Library General Public License
# # as published by the Free Software Foundation; either version 2.1 of
# # the License, or (at your option) any later version.
