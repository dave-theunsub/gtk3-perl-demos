#!/usr/bin/perl
#
# Description
# GtkClipboard
# https://developer.gnome.org/gtk3/stable/gtk3-Clipboards.html
#
# Perl version by Dave M <dave.nerd@gmail.com>
# 25 Sept 2016

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new;
$window->set_title( 'GtkClipboard' );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

my $top_box = Gtk3::Box->new( 'vertical', 0 );
$window->add( $top_box );

my $box = Gtk3::Box->new( 'horizontal', 5 );
$top_box->add( $box );

my $type_entry = Gtk3::Entry->new;
$box->pack_start( $type_entry, FALSE, FALSE, 0 );
$type_entry->set_text( 'Type something' );
$type_entry->signal_connect(
    'key-press-event' => sub {
        if ( $type_entry->get_text eq 'Type something' ) {
            $type_entry->set_text( '' );
            return TRUE;
        }
    }
);
$type_entry->set_max_width_chars( 20 );

my $paste_entry = Gtk3::Entry->new;
$box->pack_start( $paste_entry, FALSE, FALSE, 0 );
$paste_entry->set_editable( FALSE );

my $buttonbox = Gtk3::ButtonBox->new( 'horizontal' );
$buttonbox->set_layout( 'expand' );
$top_box->pack_start( $buttonbox, FALSE, FALSE, 0 );

my $clippy
    = Gtk3::Clipboard::get( Gtk3::Gdk::Atom::intern( 'CLIPBOARD', FALSE ) );
$clippy->wait_for_text();

my $copy_btn = Gtk3::Button->new_from_icon_name( 'gtk-copy', 3 );
$copy_btn->set_tooltip_text( 'Copy' );
$copy_btn->signal_connect( 'clicked' => \&copy, $type_entry->get_text );
$buttonbox->add( $copy_btn );

my $paste_btn = Gtk3::Button->new_from_icon_name( 'gtk-paste', 3 );
$paste_btn->set_tooltip_text( 'Paste' );
$paste_btn->signal_connect( 'clicked' => \&paste, $type_entry->get_text );
$buttonbox->add( $paste_btn );

$window->show_all;

Gtk3->main();

sub copy {
    # my ( $button, $text ) = @_;
    return unless ( length( $type_entry->get_text ) );
    $clippy->set_text( $type_entry->get_text,
        length( $type_entry->get_text ) );
}

sub paste {
    my $text = $clippy->wait_for_text;
    return unless ( $text );
    $paste_entry->set_text( $text );
    $type_entry->set_text( 'Type something' );
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
