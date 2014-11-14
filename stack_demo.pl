#!/usr/bin/perl

# GtkStack — A stacking container
# Perl version taken from http://python-gtk-3-tutorial.readthedocs.org/
# Perl version by Dave M <dave.nerd@gmail.com>
#

use Gtk3 '-init';
use Glib 'TRUE';

my $window = Gtk3::Window->new( 'toplevel' );
$window->signal_connect( 'delete-event' => sub { Gtk3->main_quit } );
$window->set_title( 'Stack Demo' );
$window->set_border_width( 10 );

my $box = Gtk3::Box->new( 'vertical', 6 );
$window->add( $box );

my $stack = Gtk3::Stack->new;
$stack->set_transition_type( 'slide-left-right' );
$stack->set_transition_duration( 1000 );

my $button = Gtk3::CheckButton->new( 'Click me!' );
$stack->add_titled( $button, 'check', 'Check Button' );

my $label = Gtk3::Label->new( '' );
$label->set_markup( "<big>A fancy label</big>" );
$stack->add_titled( $label, 'label', 'A label' );

my $stack_switcher = Gtk3::StackSwitcher->new;
$stack_switcher->set_stack( $stack );
$box->pack_start( $stack_switcher, TRUE, TRUE, 0 );
$box->pack_start( $stack,          TRUE, TRUE, 0 );

$window->show_all;

Gtk3->main;

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
