#!/usr/bin/perl
#
# Paned Widgets
#
# The GtkHPaned and GtkVPaned Widgets divide their content area
# into two panes with a divider in between that the user can adjust.
# A separate child is placed into each pane.
#
# There are a number of options that can be set for each pane.
# This test contains both a horizontal (HPaned) and a vertical
# (VPaned) widget, and allows you to adjust the options for each
# side of each widget.
#

package panes;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;

do_panes();
Gtk3->main();

sub do_panes {
    if ( !$window ) {
        $window = Gtk3::Window->new('toplevel');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_title('Panes');
        $window->set_border_width(0);

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        # VBox is deprecated
        my $vbox = Gtk3::Box->new( 'vertical', 0 );
        $window->add($vbox);

        # VPaned is deprecated
        my $vpaned = Gtk3::Paned->new('vertical');
        $vbox->pack_start( $vpaned, TRUE, TRUE, 0 );
        $vpaned->set_border_width(5);

        # HPaned is deprecated
        my $hpaned = Gtk3::Paned->new('horizontal');
        $vpaned->add1($hpaned);

        my $frame = Gtk3::Frame->new('');
        $frame->set_shadow_type('in');
        $frame->set_size_request( 60, 60 );
        $hpaned->add1($frame);

        my $button = Gtk3::Button->new_with_mnemonic('_Hi there');
        $frame->add($button);

        $frame = Gtk3::Frame->new('');
        $frame->set_shadow_type('in');
        $frame->set_size_request( 80, 60 );
        #$frame->add( Gtk3::Button->new() );
        $hpaned->add2($frame);

        $frame = Gtk3::Frame->new('');
        $frame->set_shadow_type('in');
        $frame->set_size_request( 60, 80 );
        #$frame->add( Gtk3::Button->new() );
        $vpaned->add2($frame);

        # Now create toggle buttons to control sizing
        $vbox->pack_start(
            create_pane_options( $hpaned, 'Horizontal', 'Left', 'Right' ),
            FALSE, FALSE, 0 );

        $vbox->pack_start(
            create_pane_options( $vpaned, 'Vertical', 'Top', 'Bottom' ),
            FALSE, FALSE, 0 );

        $vbox->show_all();
    }

    if ( !$window->get_visible() ) {
        $window->show_all();
    } else {
        $window->destroy();
    }
}

sub create_pane_options {
    my ( $paned, $frame_label, $label1, $label2 ) = @_;

    my $frame = Gtk3::Frame->new($frame_label);
    $frame->set_border_width(4);

    my $table = Gtk3::Grid->new();
    $frame->add($table);

    my $label = Gtk3::Label->new($label1);
    $table->attach( $label, 0, 0, 1, 1 );

    my $cb = Gtk3::CheckButton->new_with_mnemonic('_Resize');
    $table->attach( $cb, 0, 1, 1, 1 );
    $cb->signal_connect(
        toggled => \&toggle_resize,
        $paned->get_child1
        );

    $cb = Gtk3::CheckButton->new_with_mnemonic('_Shrink');
    $table->attach( $cb, 0, 2, 1, 1 );
    $cb->set_active(TRUE);
    $cb->signal_connect(
        toggled => \&toggle_shrink,
        $paned->get_child1
        );

    $label = Gtk3::Label->new($label2);
    $table->attach( $label, 1, 0, 1, 1 );

    $cb = Gtk3::CheckButton->new_with_mnemonic('_Resize');
    $table->attach( $cb, 1, 1, 1, 1 );
    $cb->set_active(TRUE);
    $cb->signal_connect(
        toggled => \&toggle_resize,
        $paned->get_child2
        );

    $cb = Gtk3::CheckButton->new_with_mnemonic('_Shrink');
    $table->attach( $cb, 1, 2, 1, 1 );
    $cb->set_active(TRUE);
    $cb->signal_connect(
        toggled => \&toggle_shrink,
        $paned->get_child2
        );

    return $frame;
}

sub toggle_shrink {
    # $cb, $frame
    my ( $widget, $child ) = @_;

    my $paned = $child->get_parent;

    if ( $child == $paned->get_child1 ) {
        $paned->remove($child);
        $paned->pack1( $child, $widget->get_active, 0 );
    } else {
        $paned->remove($child);
        $paned->pack2( $child, $widget->get_active, 0 );
    }
}

sub toggle_resize {
    my ( $widget, $child ) = @_;

    my $paned = $child->get_parent;

    if ( $child == $paned->get_child1 ) {
        $paned->remove($child);
        $paned->pack1( $child, $widget->get_active, 0 );
    } else {
        $paned->remove($child);
        $paned->pack2( $child, $widget->get_active, 0 );
    }
}

1;
