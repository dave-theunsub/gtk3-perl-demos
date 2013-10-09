#!/usr/bin/perl
#
# Builder
# Demonstrates an interface loaded from a XML description.
#
# Perl version by Dave M <dave.nerd@gmail.com>
# with patches from Thierry Vignaud <thierry.vignaud@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use File::Basename 'dirname';

my $builder  = Gtk3::Builder->new();
$builder->add_from_file(dirname($0) . '/demo.ui');

my $window = $builder->get_object('window1');
$builder->connect_signals(undef);

$window->set_screen( $window->get_screen() );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

$window->show_all();

Gtk3->main();

sub about_activate {
    my $about_dialog = $builder->get_object('aboutdialog1');
    $about_dialog->run();
    $about_dialog->hide();
}

sub quit_activate {
    my $action = shift;
    my $window = $builder->get_object('window1');
    $window->destroy;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
