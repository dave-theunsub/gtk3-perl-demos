#!/usr/bin/perl
#
# GtkLayout
#
# Infinite scrollable area containing child widgets and/or custom drawing
#

package layout;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;
do_layout();

Gtk3->main();

sub do_layout {
    if ( !$window ) {
        $window = Gtk3::Window->new;
        $window->set_title('Catch me');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_default_size( 640, 480 );
        $window->set_border_width(10);

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        my $sw = Gtk3::ScrolledWindow->new( undef, undef );
        $sw->set_policy( 'automatic', 'automatic' );
        $window->add($sw);

        my $layout = Gtk3::Layout->new( undef, undef );
        $layout->set_size( 640, 480 );
        $sw->add($layout);

        my $button = Gtk3::Button->new_from_stock('gtk-quit');
        $button->set_size_request( 100, 50 );
        $layout->put( $button, 100, 120 );

        my $i = 1;

        $button->signal_connect(
            'enter' => sub {
                if ( $i > 14 ) {
                    $_[0]->set_label("Ok, Fine Then.");
                    $_[0]->signal_connect(
                        "clicked" => sub {
                            Gtk3->main_quit;
                        } );
                    return 1;
                } elsif ( $i > 9 ) {
                    $_[0]->set_label("Quit Already!");
                } elsif ( $i > 4 ) {
                    $_[0]->set_label("Perhaps, X");
                } elsif ( $i > 0 ) {
                    $_[0]->set_label("Ha-Ha");
                }
                $_[1][1]->move( $_[0], rand(520), rand(410) );
                $i++;
                1;
            },
            [ $window, $layout ] );

    }

    if ( !$window->get_visible ) {
        $window->show_all;
    } else {
        $window->destroy();
    }
}
