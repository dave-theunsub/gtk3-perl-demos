#!/usr/bin/perl
# This is a mix of the Python example and
# one Zentara wrote for Gtk2.

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

do_status_icon_demo();

sub do_status_icon_demo {
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
}
