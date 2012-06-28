#!/usr/bin/perl

package menus;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;

do_menus();

Gtk3->main();

sub do_menus {
    if ( !$window ) {
        $window = Gtk3::Window->new('toplevel');
        $window->set_title('Menus');
        $window->set_border_width(0);
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );

		my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
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
    }

    if ( !$window->get_visible ) {
        $window->show_all();
    } else {
        $window->destroy();
    }

	#return $window;
}

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

1;
