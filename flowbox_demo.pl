#!/usr/bin/perl

# GtkFlowBox — A container that allows reflowing its children
# Adapted from http://python-gtk-3-tutorial.readthedocs.org/
# Perl version by Dave M <dave.nerd@gmail.com>
# This requires Gtk3 >= 3.12. I'm told this program works,
# but I cannot test it because Fedora has 3.10.
#

use Gtk3 '-init';
use Glib 'TRUE';

my $window = Gtk3::Window->new( 'toplevel' );
$window->signal_connect( 'delete-event' => sub { Gtk3->main_quit } );
$window->set_title( 'FlowBox Demo' );
$window->set_border_width( 10 );
$window->set_default_size( 300, 250 );

my $header = Gtk3::HeaderBar->new;
$header->set_subtitle( 'Sample FlowBox App' );
$header->set_show_close_button( TRUE );
$window->set_titlebar( $header );

my $scrolled = Gtk3::ScrolledWindow->new;
$scrolled->set_policy( 'never', 'never' );
$window->add( $scrolled );

my $box = Gtk3::FlowBox->new;
$box->set_max_children_per_line( 3 );
$box->set_selection_mode( 'none' );
$scrolled->add( $box );

create_flowbox();

$window->show_all;

Gtk3->main;

sub create_flowbox {
    my @array = (
        'gtk-apply',        'gtk-ok',
        'gtk-no',           'gtk-close',
        'gtk-color-picker', 'gtk-cut',
        'gtk-paste',        'gtk-connect',
        'gtk-delete',       'gtk-directory',
        'gtk-clear',
    );

    for my $b ( @array ) {
        my $button = Gtk3::Button->new;
        my $image = Gtk3::Image->new_from_stock( $b, 'button' );
        $button->add( $image );
        $box->add( $button );
    }
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
