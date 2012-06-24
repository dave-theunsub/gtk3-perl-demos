#!/usr/bin/perl

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;
do_pickers();

sub do_pickers {
    if ( !$window ) {
        $window = Gtk3::Window->new('toplevel');
        $window->set_title('Pickers');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_border_width(10);

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        my $table = Gtk3::Grid->new();
        $table->set_row_spacing(3);
        $table->set_column_spacing(10);
        $table->set_border_width(10);
        $window->add($table);

        my $label = Gtk3::Label->new('Color:');
        $label->set_halign('start');
        $label->set_valign('center');
        $label->set_hexpand(TRUE);

        my $picker = Gtk3::ColorButton->new();
        $table->attach( $label,  0, 0, 1, 1 );
        $table->attach( $picker, 1, 0, 1, 1 );

        $label = Gtk3::Label->new('Font:');
        $label->set_halign('start');
        $label->set_valign('center');
        $label->set_hexpand(TRUE);

        $picker = Gtk3::FontButton->new();
        $table->attach( $label,  0, 1, 1, 1 );
        $table->attach( $picker, 1, 1, 1, 1 );

        $label = Gtk3::Label->new('File:');
        $label->set_halign('start');
        $label->set_valign('center');
        $label->set_hexpand(TRUE);
        $picker = Gtk3::FileChooserButton->new( 'Pick a file', 'open' );
        $table->attach( $label,  0, 2, 1, 1 );
        $table->attach( $picker, 1, 2, 1, 1 );

        $label = Gtk3::Label->new('Folder:');
        $label->set_halign('start');
        $label->set_valign('center');
        $label->set_hexpand(TRUE);
        $picker =
            Gtk3::FileChooserButton->new( 'Pick a Folder', 'select-folder' );
        $table->attach( $label,  0, 3, 1, 1 );
        $table->attach( $picker, 1, 3, 1, 1 );

        $label = Gtk3::Label->new('Mail:');
        $label->set_halign('start');
        $label->set_valign('center');
        $label->set_hexpand(TRUE);
        $picker = Gtk3::AppChooserButton->new('x-scheme-handler/mailto');
        $picker->set_show_dialog_item(TRUE);
        $table->attach( $label,  0, 4, 1, 1 );
        $table->attach( $picker, 1, 4, 1, 1 );
    }

    if ( !$window->get_visible ) {
        $window->show_all;
    } else {
        $window->destroy();
    }
}

Gtk3->main();
