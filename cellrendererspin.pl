#!/usr/bin/perl

#
# GtkCellRendererSpin — Renders a spin button in a cell
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new('toplevel');
$window->set_title('GtkCellRendererSpin');
$window->signal_connect(
    destroy => sub {
        $window->destroy;
        Gtk3->main_quit;
    } );
$window->set_border_width(5);
$window->set_default_size( 260, 125 );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

my $store = Gtk3::ListStore->new( 'Glib::String', 'Glib::Int' );
my $i = 1;

for my $count (qw| One Two Three |) {
    my $iter = $store->append;
    $store->set( $iter, 0, $count, 1, $i++ );
}

my $view = Gtk3::TreeView->new($store);

my $ct =
    Gtk3::TreeViewColumn->new_with_attributes( 'Numbers',
    Gtk3::CellRendererText->new, text => 0 );
$view->append_column($ct);

my $spinner = Gtk3::CellRendererSpin->new;
$spinner->signal_connect( edited => \&on_amount_edited, $store );
$spinner->set_property( editable => TRUE );

my $adj = Gtk3::Adjustment->new( 0, 0, 100, 1, 10, 0 );
$spinner->set_property( adjustment => $adj );

my $cs = Gtk3::TreeViewColumn->new_with_attributes( 'Amount',
    $spinner, text => 1 );
$view->append_column($cs);

$window->add($view);
$window->show_all();

Gtk3->main;

sub on_amount_edited {
    my ( $widget, $path, $value, $store ) = @_;

    my $path_str = Gtk3::TreePath->new($path);
    my $iter     = $store->get_iter($path_str);

    $store->set( $iter, 1, int($value) );
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
