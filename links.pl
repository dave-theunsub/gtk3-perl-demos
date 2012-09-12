#!/usr/bin/perl
#
# Links
# GtkLabel can show hyperlinks. The default action is to call
# gtk_show_uri() on their URI, but it is possible to override
# this with a custom handler.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $dialog;

my $window = Gtk3::Window->new('toplevel');
$window->set_title('Links');
$window->set_border_width(12);
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

my $label =
    Gtk3::Label->new( 'Some <a href="http://en.wikipedia.org/wiki/Text"'
        . "title=\"plain text\">text</a> may be marked up\n"
        . "as hyperlinks, which can be clicked\n"
        . "or activated via <a href=\"keynav\">keynav</a>\n"
        . "and they work fine with other markup, like when\n"
        . "searching on <a href=\"http://www.google.com/\">"
        . "<span color=\"#0266C8\">G</span><span color=\"#F90101\">o</span>"
        . "<span color=\"#F2B50F\">o</span><span color=\"#0266C8\">g</span>"
        . "<span color=\"#00933B\">l</span><span color=\"#F90101\">e</span>"
        . "</a>." );
$label->set_use_markup(TRUE);
$label->signal_connect(
    'activate-link' => \&activate_link,
    $window
    );
$window->add($label);
$label->show();

$window->show_all();

Gtk3->main();

sub activate_link {
    my ( $label, $uri, $data, $window ) = @_;

    if ( $uri eq 'keynav' ) {
        # Next line does not work; have to set markup manually
        # $dialog = Gtk3::MessageDialog->new_with_markup(
        $dialog =
            Gtk3::MessageDialog->new( $window, 'destroy-with-parent', 'info',
            'ok', );

        # This part should be doable in the initial setup...
        $dialog->set_markup( 'The term <i>keynav</i> is a shorthand for '
                . 'keyboard navigation and refers to the process of using '
                . 'a program (exclusively) via keyboard input.' );
        $dialog->present();
        $dialog->signal_connect( response => \&response_cb );

        return TRUE;
    } else {
        return FALSE;
    }
}

sub response_cb {
    $dialog->destroy();
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
