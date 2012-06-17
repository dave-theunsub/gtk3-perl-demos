#!/usr/bin/perl

use strict;
use warnings;

# Pull in standard libraries
use lib '.';
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $assistant;    # Gtk3::Assistant
my $pb;           # Gtk3::ProgressBar

create_assistant();

Gtk3->main();

sub apply_changes_gradually {
    my $fraction = $pb->get_fraction();
    $fraction += 0.05;

    if ( $fraction < 1.0 ) {
        $pb->set_fraction($fraction);
        return TRUE;
    } else {
        $assistant->destroy();
        return FALSE;
    }
}

sub on_assistant_apply {
    Glib::Timeout->add( 100, \&apply_changes_gradually );
}

sub on_assistant_close_cancel {
    $assistant->destroy();
}

sub on_assistant_prepare {
    my ( $current_page, $num_pages );

    $current_page = $assistant->get_current_page();
    $num_pages    = $assistant->get_n_pages();

    my $title = sprintf 'Sample assistant (%d of %d)',
        $current_page + 1, $num_pages;
    $assistant->set_title($title);

    if ( $current_page == 3 ) {
        $assistant->commit;
    }
}

sub on_entry_changed {
    my ($data)       = @_;
    my $page_num     = $assistant->get_current_page();
    my $current_page = $assistant->get_nth_page($page_num);

    if ($data) {
        $assistant->set_page_complete( $current_page, TRUE );
    } else {
        $assistant->set_page_complete( $current_page, FALSE );
    }
}

sub create_page1 {
    my $box = Gtk3::Box->new( 'horizontal', 12 );
    $box->set_border_width(12);
	$box->set_homogeneous( TRUE );

    $box->pack_start(
        Gtk3::Label->new('You must fill out this entry to continue:'),
        FALSE, FALSE, 0 );

    my $entry = Gtk3::Entry->new();
    $entry->set_activates_default(TRUE);
    $box->pack_start( $entry, TRUE, TRUE, 0 );
    $entry->signal_connect(
        changed => sub {
            on_entry_changed( $entry->get_text );
        } );
    $box->show_all();
    $assistant->append_page($box);
    $assistant->set_page_title( $box, 'Page 1' );
    $assistant->set_page_type( $box, 'intro' );
}

sub create_page2 {
    my $box = Gtk3::Box->new( 'vertical', 12 );
    $box->set_border_width(12);
	$box->set_homogeneous( TRUE );

    my $cb = Gtk3::CheckButton->new_with_label(
              'This is optional data, you may continue '
            . 'even if you do not check this' );
    $box->pack_start( $cb, FALSE, FALSE, 0 );
    $box->show_all();
    $assistant->append_page($box);
    $assistant->set_page_complete( $box, TRUE );
    $assistant->set_page_title( $box, 'Page 2' );
}

sub create_page3 {
    my $label = Gtk3::Label->new( q { This is a confirmation page. }
            . q { Press 'Apply' to save changes. } );
    $label->show();

    $assistant->append_page($label);
    $assistant->set_page_type( $label, 'confirm' );
    $assistant->set_page_complete( $label, TRUE );
    $assistant->set_page_title( $label, 'Confirmation' );
}

sub create_page4 {
    $pb = Gtk3::ProgressBar->new();
    $pb->set_halign('center');
    $pb->set_valign('center');
    $pb->set_fraction(0.0);
    $pb->show();

    $assistant->append_page($pb);
    $assistant->set_page_type( $pb, 'progress' );
    $assistant->set_page_complete( $pb, TRUE );
    $assistant->set_page_title( $pb, 'Applying changes...' );

    $assistant->set_page_complete( $pb, FALSE );
}

sub create_assistant {
    if ( !$assistant ) {
        $assistant = Gtk3::Assistant->new();
        $assistant->set_default_size( -1, 300 );

        create_page1();
        create_page2();
        create_page3();
        create_page4();

        $assistant->signal_connect(
            destroy => sub {
                # If this is part of a package (gtk3-demo), then
                # $assistant->destroy();
                # otherwise:
                Gtk3->main_quit;
            } );
        $assistant->signal_connect( cancel  => \&on_assistant_close_cancel );
        $assistant->signal_connect( close   => \&on_assistant_close_cancel );
        $assistant->signal_connect( apply   => \&on_assistant_apply );
        $assistant->signal_connect( prepare => \&on_assistant_prepare );
    }

    if ( !$assistant->get_visible ) {
        $assistant->show_all();
    } else {
        $assistant->destroy();
    }
}
