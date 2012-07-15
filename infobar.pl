#!/usr/bin/perl
#
# Info bar
#
# Info bar widgets are used to report important messages to the user.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant GTK_RESPONSE_OK => -5;

do_infobar();
Gtk3->main();

sub do_infobar {
    my $window = Gtk3::Window->new('toplevel');
    $window->set_title('Info Bars');
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my $box = Gtk3::Box->new( 'vertical', 0 );
    $box->set_border_width(5);
    $box->set_homogeneous(FALSE);
    $window->add($box);

    my $bar = Gtk3::InfoBar->new();
    $bar->set_message_type('info');
    $bar->get_content_area()->add(
        Gtk3::Label->new(
            'This is an info bar with message type GTK_MESSAGE_INFO') );
    $box->pack_start( $bar, FALSE, FALSE, 0 );

    my $bar2 = Gtk3::InfoBar->new();
    $bar2->set_message_type('warning');
    $bar2->get_content_area()->add(
        Gtk3::Label->new(
            'This is an info bar with message type GTK_MESSAGE_WARNING') );
    $box->pack_start( $bar2, FALSE, FALSE, 0 );

    my $bar3 = Gtk3::InfoBar->new();
    $bar3->add_button( 'gtk-ok', GTK_RESPONSE_OK );
    $bar3->signal_connect(
        response => sub {
            on_bar_response( GTK_RESPONSE_OK, $window );
        } );
    $bar3->set_message_type('question');
    $bar3->get_content_area()->add(
        Gtk3::Label->new(
            'This is an info bar with message type GTK_MESSAGE_QUESTION') );
    $box->pack_start( $bar3, FALSE, FALSE, 0 );

    my $bar4 = Gtk3::InfoBar->new();
    $bar4->set_message_type('error');
    $bar4->get_content_area()->add(
        Gtk3::Label->new(
            'This is an info bar with message type GTK_MESSAGE_ERROR') );
    $box->pack_start( $bar4, FALSE, FALSE, 0 );

    my $bar5 = Gtk3::InfoBar->new();
    $bar5->set_message_type('other');
    $bar5->get_content_area()->add(
        Gtk3::Label->new(
            'This is an info bar with message type GTK_MESSAGE_OTHER') );
    $box->pack_start( $bar5, FALSE, FALSE, 0 );

    my $frame = Gtk3::Frame->new('Info Bars');
    $box->pack_start( $frame, FALSE, FALSE, 8 );

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_border_width(8);
    $vbox->set_homogeneous(FALSE);
    $frame->add($vbox);
    $vbox->pack_start( Gtk3::Label->new('An example of different info bars'),
        FALSE, FALSE, 0 );

    $window->show_all();
}

sub on_bar_response {
    my ( $response_id, $window ) = @_;
    my $dialog = Gtk3::MessageDialog->new(
        $window,
        [qw(modal destroy-with-parent)],
        'info',
        'ok',
        'You clicked a button on an info bar.' . ' Your response has id %d',
        $response_id
        );

    # This next line doesn't work
    #$dialog->format_secondary_text(
    #		'Your response has id %d', $response_id );

    $dialog->run();
    $dialog->destroy();
}

# This library is free software; you can redistribute it and/or
# # modify it under the terms of the GNU Library General Public License
# # as published by the Free Software Foundation; either version 2.1 of
# # the License, or (at your option) any later version.
