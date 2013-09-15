#!/usr/bin/perl
#
# Example of GtkComboBoxText, a simple, text-only combo box,
# and handling its signal.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new( 'toplevel' );
$window->signal_connect( destroy => sub {Gtk3::main_quit} );
$window->set_title( 'ComboBoxText Example' );
$window->set_default_size( 250, 150 );

my $box = Gtk3::Box->new( 'vertical', 5 );
$window->add( $box );

my $grid = Gtk3::Grid->new;
$box->pack_start( $grid, TRUE, TRUE, 5 );
$grid->set_column_spacing( 5 );
$grid->set_row_spacing( 5 );
$grid->set_column_homogeneous( TRUE );

my $label = Gtk3::Label->new( 'Select a number:' );
$grid->attach( $label, 0, 0, 1, 1 );

my $cb = Gtk3::ComboBoxText->new;
$grid->attach( $cb, 1, 0, 1, 1 );
$cb->signal_connect(
    changed => sub {
        my $text = $cb->get_active_text;
        return unless ( $text );
        set_infobar_text( 'changed', $text );
    }
);

my $button = Gtk3::Button->new_from_stock( 'gtk-apply' );
$grid->attach( $button, 2, 0, 1, 1 );
$button->signal_connect(
    clicked => sub {
        my $text = $cb->get_active_text;
        return unless ( $text );
        set_infobar_text( 'selected', $text );
    }
);

$button = Gtk3::Button->new_from_stock( 'gtk-quit' );
$grid->attach( $button, 3, 0, 1, 1 );
$button->signal_connect( clicked => sub {Gtk3::main_quit} );

my $infobar = Gtk3::InfoBar->new;
$box->pack_start( $infobar, FALSE, FALSE, 5 );

populate_box();

$window->show_all;
Gtk3->main;

sub populate_box {
    for ( 1 .. 15 ) {
        $cb->append_text( $_ );
    }
}

sub set_infobar_text {
    my ( $signal, $fluff ) = @_;

    my $message = '';

    if ( $signal eq 'changed' ) {
        $message = "You changed the value to $fluff."
        . ' Now press apply.';
    } elsif ( $signal eq 'selected' ) {
        $message = "You selected the value $fluff";
    }

    if ( !$infobar->get_content_area->get_children ) {
        $infobar->get_content_area->add( Gtk3::Label->new( $message ) );
    } else {
        for my $c ( $infobar->get_content_area->get_children ) {
            if ( $c->isa( 'Gtk3::Label' ) ) {
                $c->set_text( $message );
            }
        }
    }
    $infobar->show_all;
}

