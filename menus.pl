#!/usr/bin/perl
#
# Menus
# There are several widgets involved in displaying menus.
# The GtkMenuBar widget is a menu bar, which normally appears
# horizontally at the top of an application, but can also be
# layed out vertically. The GtkMenu widget is the actual menu
# that pops up. Both GtkMenuBar and GtkMenu are subclasses of
# GtkMenuShell; a GtkMenuShell contains menu items (GtkMenuItem).
# Each menu item contains text and/or images and can be selected by the user.
#
# There are several kinds of menu item, including plain GtkMenuItem,
# GtkCheckMenuItem which can be checked/unchecked, GtkRadioMenuItem
# which is a check menu item that's in a mutually exclusive group,
# GtkSeparatorMenuItem which is a separator bar, GtkTearoffMenuItem
# which allows a GtkMenu to be torn off, and GtkImageMenuItem which
# can place a GtkImage or other widget next to the menu text.
#
# A GtkMenuItem can have a submenu, which is simply a GtkMenu to
# pop up when the menu item is selected. Typically, all menu items
# in a menu bar have submenus.
#
# GtkUIManager provides a higher-level interface for creating menu
# bars and menus; while you can construct menus manually, most
# people don't do that. There's a separate demo for GtkUIManager.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new('toplevel');
$window->set_title('Menus');
$window->set_border_width(0);
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

my $accel_group = Gtk3::AccelGroup->new;
$window->add_accel_group($accel_group);

my $box = Gtk3::Box->new( 'horizontal', 0 );
$window->add($box);
$box->show();

my $box1 = Gtk3::Box->new( 'vertical', 0 );
$box->add($box1);
$box1->show();

my $menubar = Gtk3::MenuBar->new;
$box1->pack_start( $menubar, FALSE, TRUE, 0 );
$menubar->show();

my $menu = create_menu(2);

my $menuitem = Gtk3::MenuItem->new_with_label("test\nline2");
$menuitem->set_submenu($menu);
$menubar->append($menuitem);
$menuitem->show();

$menuitem = Gtk3::MenuItem->new_with_label('foo');
$menuitem->set_submenu( create_menu(3) );
$menubar->append($menuitem);
$menuitem->show();

$menuitem = Gtk3::MenuItem->new_with_label('bar');
$menuitem->set_submenu( create_menu(4) );
$menubar->append($menuitem);
$menuitem->show();

my $box2 = Gtk3::Box->new( 'vertical', 10 );
$box2->set_border_width(10);
$box1->pack_start( $box2, FALSE, TRUE, 0 );
$box2->show();

my $flip_button = Gtk3::Button->new_with_label('Flip');
$flip_button->signal_connect(
    clicked => sub {
        change_orientation($menubar);
    } );
$box2->pack_start( $flip_button, TRUE, TRUE, 0 );
$flip_button->show();

my $close_button = Gtk3::Button->new_with_label('Close');
$close_button->signal_connect( clicked => sub { Gtk3->main_quit } );
$close_button->set_can_default(TRUE);
$close_button->grab_default();
$box2->pack_start( $close_button, TRUE, TRUE, 0 );
$close_button->show();

$window->show_all();

Gtk3->main();

sub change_orientation {
    my $menubar     = shift;
    my $parent      = $menubar->get_parent();
    my $orientation = $parent->get_orientation();
    $parent->set_orientation(
        $orientation eq 'vertical' ? 'horizontal' : 'vertical' );
    $menubar->set_pack_direction(
        $orientation eq 'vertical' ? 'ttb' : 'ltr' );
}

sub create_menu {
    my $depth = shift;

    return undef if ( $depth < 1 );

    my $menu  = Gtk3::Menu->new;
    my $group = [];

    my ( $i, $j );
    for ( $i = 0, $j = 1; $i < 5; $i++, $j++ ) {
        my $buff = sprintf( 'item %2d - %d', $depth, $j );
        my $menuitem = Gtk3::RadioMenuItem->new_with_label( $group, $buff );
        $group = $menuitem->get_group;

        $menu->append($menuitem);
        $menuitem->show();
        if ( $i == 3 ) {
            $menuitem->set_sensitive(FALSE);
        }
        $menuitem->set_submenu( create_menu( $depth - 1 ) );
    }

    return $menu;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
