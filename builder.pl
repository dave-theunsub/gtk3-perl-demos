#!/usr/bin/perl

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';
# Temporary until merged with main.pl
use File::Basename 'dirname';

my $builder;

do_builder();

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

sub do_builder {
    my $window;
    if ( !$window ) {
        $builder = Gtk3::Builder->new();
        my $filename = demo_find_file('demo.ui');
        $builder->add_from_file($filename);

        $window = $builder->get_object('window1');
        $builder->connect_signals(undef);

        $window->set_screen( $window->get_screen() );
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
    }

    if ( !$window->get_visible ) {
        $window->show_all();
    } else {
        $window->destroy();
    }

	return $window;
}

sub demo_find_file {
    my $base = shift;
    return $base if ( -e $base );

    my $dir = dirname($base);
    return $dir . $base;
}
