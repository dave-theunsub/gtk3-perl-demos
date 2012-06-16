#!/usr/bin/perl

use strict;
use warnings;

use lib '.';
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;
do_overlay();

Gtk3->main();

sub do_overlay {
    if ( !$window ) {
        $window = Gtk3::Window->new('toplevel');
        $window->set_title('Overlay');
        $window->set_default_size( 450, 450 );
        $window->set_border_width(0);
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );

		my $icon = 'gtk-logo-rgb.gif';
		if( -e $icon ) {
			my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
			my $transparent = $pixbuf->add_alpha (TRUE, 0xff, 0xff, 0xff);
			$window->set_icon( $transparent );
		}

        my $view = Gtk3::TextView->new();

        my $sw = Gtk3::ScrolledWindow->new( undef, undef );
        $sw->set_policy( 'automatic', 'automatic' );
        $sw->add($view);

        my $overlay = Gtk3::Overlay->new();
        $overlay->add($sw);
        $window->add($overlay);

        my $entry = Gtk3::Entry->new();
        $overlay->add_overlay($entry);
        $entry->set_halign('end');
        $entry->set_valign('end');

        my $label = Gtk3::Label->new('Hello World!');
        $label->set_halign('end');
        $label->set_valign('end');
        $overlay->add_overlay($label);
        $label->set_margin_left(20);
        $label->set_margin_right(20);
        $label->set_margin_top(5);
        $label->set_margin_bottom(5);

        my $entry2 = Gtk3::Entry->new();
        $overlay->add_overlay($entry2);
        $entry2->set_halign('start');
        $entry2->set_valign('end');

        my $label2 = Gtk3::Label->new('Hello World!');
        $label2->set_halign('start');
        $label2->set_valign('end');
        $overlay->add_overlay($label2);
        $label2->set_margin_left(20);
        $label2->set_margin_right(20);
        $label2->set_margin_top(5);
        $label2->set_margin_bottom(5);

        my $entry3 = Gtk3::Entry->new();
        $overlay->add_overlay($entry3);
        $entry3->set_halign('end');
        $entry3->set_valign('start');

        my $label3 = Gtk3::Label->new('Hello World!');
        $label3->set_halign('end');
        $label3->set_valign('start');
        $overlay->add_overlay($label3);
        $label3->set_margin_left(20);
        $label3->set_margin_right(20);
        $label3->set_margin_top(5);
        $label3->set_margin_bottom(5);

        my $entry4 = Gtk3::Entry->new();
        $overlay->add_overlay($entry4);
        $entry4->set_halign('start');
        $entry4->set_valign('start');

        my $label4 = Gtk3::Label->new('Hello World!');
        $label4->set_halign('start');
        $label4->set_valign('start');
        $overlay->add_overlay($label4);
        $label4->set_margin_left(20);
        $label4->set_margin_right(20);
        $label4->set_margin_top(5);
        $label4->set_margin_bottom(5);

        my $entry5 = Gtk3::Entry->new();
        $overlay->add_overlay($entry5);
        $entry5->set_halign('end');
        $entry5->set_valign('center');

        my $label5 = Gtk3::Label->new('Hello World!');
        $label5->set_halign('end');
        $label5->set_valign('center');
        $overlay->add_overlay($label5);
        $label5->set_margin_left(20);
        $label5->set_margin_right(20);
        $label5->set_margin_top(5);
        $label5->set_margin_bottom(5);

        my $entry6 = Gtk3::Entry->new();
        $overlay->add_overlay($entry6);
        $entry6->set_halign('start');
        $entry6->set_valign('center');

        my $label6 = Gtk3::Label->new('Hello World!');
        $label6->set_halign('start');
        $label6->set_valign('center');
        $overlay->add_overlay($label6);
        $label6->set_margin_left(20);
        $label6->set_margin_right(20);
        $label6->set_margin_top(5);
        $label6->set_margin_bottom(5);

        my $entry7 = Gtk3::Entry->new();
        $overlay->add_overlay($entry7);
        $entry7->set_halign('center');
        $entry7->set_valign('start');

        my $label7 = Gtk3::Label->new('Hello World!');
        $label7->set_halign('center');
        $label7->set_valign('start');
        $overlay->add_overlay($label7);
        $label7->set_margin_left(20);
        $label7->set_margin_right(20);
        $label7->set_margin_top(5);
        $label7->set_margin_bottom(5);

        my $entry8 = Gtk3::Entry->new();
        $overlay->add_overlay($entry8);
        $entry8->set_halign('center');
        $entry8->set_valign('end');

        my $label8 = Gtk3::Label->new('Hello World!');
        $label8->set_halign('center');
        $label8->set_valign('end');
        $overlay->add_overlay($label8);
        $label8->set_margin_left(20);
        $label8->set_margin_right(20);
        $label8->set_margin_top(5);
        $label8->set_margin_bottom(5);

        my $entry9 = Gtk3::Entry->new();
        $overlay->add_overlay($entry9);
        $entry9->set_halign('center');
        $entry9->set_valign('center');

        my $label9 = Gtk3::Label->new('Hello World!');
        $label9->set_halign('center');
        $label9->set_valign('center');
        $overlay->add_overlay($label9);
        $label9->set_margin_left(20);
        $label9->set_margin_right(20);
        $label9->set_margin_top(5);
        $label9->set_margin_bottom(5);

        $overlay->show_all();

    }

    if ( !$window->get_visible ) {
        $window->show_all();
    } else {
        $window->destroy();
    }

    return $window;
}
