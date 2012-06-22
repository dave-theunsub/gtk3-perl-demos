#!/usr/bin/perl

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

# Our main window: it holds everything
my $window = Gtk3::Window->new;
$window->set_title( 'template' );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

# This VBox will be handy to organize objects
my $box = Gtk3::Box->new ( 'vertical', 5 );
$window->add( $box );

# Tell everything to display
$window->show_all;

Gtk3->main();
