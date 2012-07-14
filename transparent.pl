#!/usr/bin/perl

# Transparency demo
#
# This is a minimalist version of the C demo.
# It's minimalist because not all Cairo stuff works yet.
# It still gives a decent look at transparency, though.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant SHADOW_OFFSET_X => 7;
use constant SHADOW_OFFSET_Y => 7;
use constant SHADOW_RADIUS   => 5;

do_transparent();
Gtk3->main();

sub draw_shadow_box {
    my ( $cr, $rect, $radius, $transparency ) = @_;

    my $x0 = $rect->{x};
    my $x1 = $rect->{x} + $radius;
    my $x2 = $rect->{x} + $rect->{width} - $radius;
    my $x3 = $rect->{x} + $rect->{width};

    my $y0 = $rect->{y};
    my $y1 = $rect->{y} + $radius;
    my $y2 = $rect->{y} + $rect->{height} - $radius;
    my $y3 = $rect->{y} + $rect->{height};

    # Fill non-border part
    $cr->set_source_rgba( 0, 0, 0, $transparency );
    $cr->rectangle( $x1, $y1, $x2 - $x1, $y2 - $y1 );
    $cr->fill;

    # Upper border
    my $pattern = $cr->create_linear( 0, $y0, 0, $y1 );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x1, $y0, $x2 - $x1, $y1 - $y0 );
    $cr->fill;

    # Bottom border
    $pattern = $cr->pattern_create_linear( 0, $y2, 0, $y3 );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x1, $y2, $x2 - $x1, $y3 - $y2 );
    $cr->fill;

    # Left border
    $pattern = $cr->pattern_create_linear( $x0, 0, $x1, 0 );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x0, $y1, $x1 - $x0, $y2 - $y1 );
    $cr->fill;

    # Right border
    $pattern = $cr->pattern_create_linear( $x2, 0, $x3, 0 );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x2, $y1, $x3 - $x2, $y2 - $y1 );
    $cr->fill;

    # NW corner
    $pattern = $cr->pattern_create_radial( $x1, $y1, 0, $x1, $y1, $radius );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x0, $y0, $x1 - $x0, $y1 - $y0 );
    $cr->fill;

    # NE corner
    $pattern = $cr->pattern_create_radial( $x2, $y1, 0, $x2, $y1, $radius );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x2, $y0, $x3 - $x2, $y1 - $y0 );
    $cr->fill;

    # SW corner
    $pattern = $cr->pattern_create_radial( $x1, $y2, 0, $x1, $y2, $radius );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x0, $y2, $x1 - $x0, $y3 - $y2 );
    $cr->fill;

    # SE corner
    $pattern = $cr->pattern_create_radial( $x2, $y2, 0, $x2, $y2, $radius );
    $pattern->add_color_stop_rgba( 0.0, 0.0, 0, 0, 0.0 );
    $pattern->add_color_stop_rgba( 1.0, 0.0, 0, 0, $transparency );

    $cr->set_source($pattern);
    $cr->pattern_destroy($pattern);

    $cr->rectangle( $x2, $y2, $x3 - $x2, $y3 - $y2 );
    $cr->fill;
}

sub draw_callback {
    my ( $widget, $cr, $data ) = @_;

    my $rect = $widget->get_allocation;
    $rect->{x} += SHADOW_OFFSET_X;
    $rect->{y} += SHADOW_OFFSET_Y;
    $rect->{width}  -= SHADOW_OFFSET_X;
    $rect->{height} -= SHADOW_OFFSET_Y;

    draw_shadow_box( $cr, $rect, SHADOW_RADIUS, 0.4 );

    return FALSE;
}

sub do_transparent {
    my $window = Gtk3::Window->new('toplevel');
    $window->set_title('Transparency demo');
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );
    $window->set_default_size( 450, 450 );
    $window->set_border_width(0);

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my $view = Gtk3::TextView->new();
    my $sw = Gtk3::ScrolledWindow->new( undef, undef );
    $sw->set_policy( 'automatic', 'automatic' );
    $sw->add($view);

    my $overlay = Gtk3::Overlay->new();
    $overlay->add($sw);
    $window->add($overlay);
    $overlay->override_background_color('normal');

    my $align = Gtk3::Alignment->new( 0.0, 0.0, 0.0, 0.0 );
    $align->set_padding( 0, SHADOW_OFFSET_Y, 0, SHADOW_OFFSET_X, );
    #$align->signal_connect( draw => \&draw_callback );

    my $entry = Gtk3::Entry->new();
    $align->add($entry);

    $overlay->add_overlay($align);
    $align->set_halign('center');
    $align->set_valign('start');

    $overlay->show_all();

    $window->show_all;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
