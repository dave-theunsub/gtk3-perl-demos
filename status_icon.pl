#!/usr/bin/perl
#
# Status Icon
#
# This is a simple example that shows how to create a status icon that
# will appear in the "notification area" in GNOME/KDE, or "system tray"
# in Windows.
#
# This is a mix of the Python example and one Zentara wrote for Gtk2.
#
# This demo requires perl-Gtk3 >= 0.06 or 0.07 - can't remember.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $icon = Gtk3::StatusIcon->new_from_stock('gtk-media-play');

my $menu = Gtk3::Menu->new();
my $item = Gtk3::MenuItem->new('hi');
$menu->append($item);

$item = Gtk3::ImageMenuItem->new_from_stock('gtk-quit');
$item->signal_connect( activate => sub { Gtk3->main_quit } );
$menu->append($item);

$menu->show_all();

$icon->signal_connect(
    'popup-menu' => sub {
        my ( $show, $button, $event_time ) = @_;
        $menu->popup( undef, undef, \&Gtk3::StatusIcon::position_menu,
            $show, $button, $event_time );
    } );

Gtk3->main();

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
