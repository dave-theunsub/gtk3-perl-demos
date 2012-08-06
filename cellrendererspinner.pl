#/usr/bin/perl

#
# GtkCellRendererSpinner — Renders a spinning animation in a cell
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $source;

my $window = Gtk3::Window->new('toplevel');
$window->set_title('CellRendererSpinner Demo');
$window->signal_connect(
    destroy => sub {
        $window->destroy;
        Gtk3->main_quit;
    } );
$window->set_border_width(5);
$window->set_default_size( 280, 125 );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

my $store = Gtk3::ListStore->new( 'Glib::String', 'Glib::Uint' );
my $i = 1;

for my $count ( 'Product 1', 'Product 2', 'Product 3' ) {
    my $iter = $store->append;
    $store->set( $iter, 0, $count, 1, $i++ );
}

my $view = Gtk3::TreeView->new($store);

my $ct =
    Gtk3::TreeViewColumn->new_with_attributes( 'Downloads',
    Gtk3::CellRendererText->new, text => 0 );
$view->append_column($ct);

my $spinner = Gtk3::CellRendererSpinner->new;

my $cs = Gtk3::TreeViewColumn->new_with_attributes( 'Status', $spinner );
$view->append_column($cs);

my $box = Gtk3::Box->new( 'vertical', 5 );
$window->add($box);
$box->add($view);

my $button = Gtk3::Button->new_from_stock('gtk-apply');
$box->add($button);
$button->signal_connect( clicked => \&activate, $spinner );

$window->show_all();

Gtk3->main;

sub activate {
    my ( $widget, $spin ) = @_;

    if ( $spin->get_property('active') ) {
        Glib::Source->remove($source);
        $spin->set_property( 'active' => FALSE );
        $spin->set_property( 'pulse'  => 1 );
        $window->queue_draw;
    } else {
        $spin->set_property( 'active' => TRUE );
        $spin->set_property( 'pulse'  => 1 );
        $source = Glib::Timeout->add(
            100,
            sub {
                my $val = $spin->get_property('pulse');
                $val++;
                $spin->set_property( 'pulse' => $val );
                $window->queue_draw;
                return TRUE;
            } );
        $window->queue_draw;
    }
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
