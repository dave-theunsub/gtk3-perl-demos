#!/usr/bin/perl

package foo;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;

do_foo();

Gtk3->main();

sub do_foo {
    if ( !$window ) {
        # Our main window: it holds everything
        $window = Gtk3::Window->new;
        $window->set_title('template');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );

        # This VBox will be handy to organize objects
        my $box = Gtk3::Box->new( 'vertical', 5 );
        $window->add($box);
    }

    if ( !$window->get_visible ) {
        # Tell everything to display
        $window->show_all;
    } else {
        $window->destroy;
    }
}

    1;
