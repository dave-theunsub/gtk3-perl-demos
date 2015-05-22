#!/usr/bin/perl

# GtkStatusbar — Report messages of minor importance to the user
# Perl version by Dave M <dave.nerd@gmail.com>
# Example based on
# https://developer.gnome.org/gnome-devel-demos/stable/statusbar.py.html.en

use strict;
use warnings;
use feature 'state';

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new( 'toplevel' );
$window->set_title( 'Statusbar demo' );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );
$window->set_size_request( 550, 200 );

my $box = Gtk3::Box->new( 'vertical', 5 );
$box->set_border_width( 15 );
$window->add( $box );

my $image = Gtk3::Button->new_from_stock( 'gtk-yes' );
$box->pack_start( $image, FALSE, FALSE, 5 );
$image->signal_connect( clicked => \&handler );

$image = Gtk3::Button->new_from_stock( 'gtk-no' );
$box->pack_start( $image, FALSE, FALSE, 5 );
$image->signal_connect( clicked => \&handler );

$image = Gtk3::Button->new_from_stock( 'gtk-quit' );
$box->pack_start( $image, FALSE, FALSE, 5 );
$image->signal_connect( clicked => sub { Gtk3->main_quit } );

my $statusbar = Gtk3::Statusbar->new;
$box->pack_start( $statusbar, FALSE, FALSE, 5 );

$window->show_all;
Gtk3->main;

sub handler {
    my $button = shift;
    state %clicks;

    my $label  = $button->get_label;
    $clicks{ $label }++;

    my $id     = $statusbar->get_context_id( 'example' );
    $statusbar->push(
        $id,
        sprintf(
            "Statusbar: You clicked the %s button %d %s",
            $label,
            $clicks{ $label },
            $clicks{ $label } == 1 ? 'time' : 'times'
        )
    );

    # Stop the signal emission
    return TRUE;
}
