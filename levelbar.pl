#!/usr/bin/perl

# GtkLevelBar — A bar that can used as a level indicator
# Perl version by Dave M <dave.nerd@gmail.com>, 2015

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new( 'toplevel' );
$window->set_title( 'LevelBar demo' );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );
$window->set_size_request( 350, 200 );

my $box = Gtk3::Box->new( 'vertical', 5 );
$box->set_border_width( 15 );
$window->add( $box );

my $label = Gtk3::Label->new;
$label->set_text( 'Enter your new password' );
$label->set_alignment( 0.0, 0.5 );
$box->pack_start( $label, FALSE, FALSE, 5 );

my $visibility = FALSE;
my $buffer = Gtk3::EntryBuffer->new( undef, -1 );
$buffer->signal_connect( 'inserted-text' => \&handler );
$buffer->set_max_length( 20 );

my $entry = Gtk3::Entry->new_with_buffer( $buffer );
$box->pack_start( $entry, FALSE, FALSE, 5 );
$entry->set_visibility( $visibility );

my $checkbutton = Gtk3::CheckButton->new_with_label( 'Show characters' );
$box->pack_start( $checkbutton, FALSE, FALSE, 5 );
$checkbutton->signal_connect(
    toggled => sub {
        if ( $checkbutton->get_active() ) {
            $entry->set_visibility( TRUE );
        } else {
            $entry->set_visibility( FALSE );
        }
    }
);

my $level = Gtk3::LevelBar->new;
$box->pack_start( $level, FALSE, FALSE, 5 );

$label = Gtk3::Label->new;
$label->set_text( 'Password strength' );
$box->pack_start( $label, FALSE, FALSE, 5 );

$window->show_all;
Gtk3->main;

sub handler {
    # Unnecessary; just here for documentation purposes
    my ( $position, $char, $num_of_chars ) = @_;

    my ( $upper, $lower, $digits, $special ) = ( 0 ) x 4;

    my $percent = 0;

    my $pass = $entry->get_text;

    for my $t ( split //, $pass ) {
        if ( $t =~ /[a-z]/ ) {
            $lower++;
        } elsif ( $t =~ /[A-Z]/ ) {
            $upper++;
        } elsif ( $t =~ /[0-9]/ ) {
            $digits++;
        } else {
            $special++;
        }
    }

    $percent += .25 if ( $lower > 1 );
    $percent += .25 if ( $upper > 1 );
    $percent += .25 if ( $digits > 1 );
    $percent += .25 if ( $special > 1 );

    $level->set_value( $percent );

    return TRUE;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
