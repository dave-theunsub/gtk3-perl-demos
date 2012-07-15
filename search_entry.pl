#!/usr/bin/perl
#
# Search Entry
#
# GtkEntry allows to display icons and progress information.
# This demo shows how to use these features in a search entry.
# This version requires perl-Gtk3 >= 0.07.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use constant GTK_RESPONSE_NONE => -1;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $nb;
my $entry;
my $search_progress_id;
my $finish_search_id;
my $menu;

do_search_entry();
Gtk3->main();

sub do_search_entry {
    my $window = Gtk3::Dialog->new;
    $window->set_title('Search Entry');
    $window->add_button( 'gtk-close' => GTK_RESPONSE_NONE );
    $window->set_resizable(FALSE);
    $window->signal_connect( destroy  => sub { Gtk3->main_quit } );
    $window->signal_connect( response => sub { $window->destroy } );

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my $vbox = Gtk3::Box->new( 'vertical', 5 );
    $vbox->set_border_width(5);
    $window->get_content_area()->add($vbox);

    my $label = Gtk3::Label->new('');
    $label->set_use_markup('Search entry demo');
    $vbox->pack_start( $label, FALSE, FALSE, 0 );

    my $hbox = Gtk3::Box->new( 'horizontal', 10 );
    $vbox->pack_start( $hbox, TRUE, TRUE, 0 );
    $hbox->set_border_width(0);

    # Create our entry
    $entry = Gtk3::Entry->new();
    $hbox->pack_start( $entry, FALSE, FALSE, 0 );

    # Create the find and cancel buttons
    $nb = Gtk3::Notebook->new();
    $nb->set_show_tabs(FALSE);
    $nb->set_show_border(FALSE);
    $hbox->pack_start( $nb, FALSE, FALSE, 0 );

    my $find_btn = Gtk3::Button->new_with_label('Find');
    $find_btn->signal_connect( clicked => \&start_search, $entry );
    $nb->append_page($find_btn);
    $find_btn->show();

    my $cancel_btn = Gtk3::Button->new_with_label('Cancel');
    $cancel_btn->signal_connect( clicked => \&stop_search );
    $nb->append_page($cancel_btn);
    $cancel_btn->show();

    # Set up the search icon
    search_by_name( undef, $entry );

    # Set up the clear icon
    $entry->set_icon_from_stock( 'secondary', 'gtk-clear' );

    #$entry->signal_connect( text_changed_cb =>
    $entry->signal_connect( 'icon-press' => \&icon_press_cb );
    $entry->signal_connect(
        'notify::text' => \&text_changed_cb,
        $find_btn
        );
    $entry->signal_connect( activate => \&activate_cb );

    # Create the menu
    $menu = create_search_menu($entry);
    $menu->attach_to_widget($entry);

    # Add accessible alternatives for icon functionality
    $entry->signal_connect( 'populate-popup' => \&entry_populate_popup );

    # Give the focus to the close_button
    my $close_btn = $window->get_widget_for_response(GTK_RESPONSE_NONE);
    $close_btn->grab_focus;

    $window->show_all;
}

sub show_find_button {
    $nb->set_current_page(0);
}

sub show_cancel_button {
    $nb->set_current_page(1);
}

sub search_progress {
    my $data = shift();
    $entry->progress_pulse($data);
    return TRUE;    #G_SOURCE_CONTINUE
}

sub search_progress_done {
    $entry->set_progress_fraction(0.0);
}

sub finish_search {
    show_find_button();
    Glib::Source->remove($search_progress_id);
    $search_progress_id = 0;
    search_progress_done();

    return FALSE;
}

sub start_search_feedback {
    my $data = shift;
    $search_progress_id = Glib::Timeout->add( 100, \&search_progress, $data );

    return FALSE;
}

sub start_search {
    my ( $button, $entry ) = @_;
    show_cancel_button();
    $search_progress_id =
        Glib::Timeout->add_seconds( 1, \&start_search_feedback, $entry );
    $finish_search_id =
        Glib::Timeout->add_seconds( 15, \&finish_search, $button );
}

sub stop_search {
    my ( $button, $data ) = @_;
    Glib::Source->remove($finish_search_id);
    finish_search($button);
}

sub clear_entry {
    $entry->set_text('');
}

sub search_by_name {
    my ( $item, $entry ) = @_;
    $entry->set_icon_from_stock( 'primary', 'gtk-find' );
    $entry->set_icon_tooltip_text( 'primary',
        "Search by name\n" . 'Click here to change the search type' );
    $entry->set_placeholder_text('name');
}

sub search_by_description {
    my ( $item, $entry ) = @_;
    $entry->set_icon_from_stock( 'primary', 'gtk-edit' );
    $entry->set_icon_tooltip_text( 'primary',
        "Search by description\n" . 'Click here to change the search type' );
    $entry->set_placeholder_text('description');
}

sub search_by_file {
    my ( $item, $entry ) = @_;
    $entry->set_icon_from_stock( 'primary', 'gtk-open' );
    $entry->set_icon_tooltip_text( 'primary',
        "Search by file name\n" . 'Click here to change the search type' );
    $entry->set_placeholder_text('file name');
}

sub create_search_menu {
    my ($entry) = shift;

    my $menu  = Gtk3::Menu->new();
    my $item  = Gtk3::ImageMenuItem->new_with_mnemonic('Search by _name');
    my $image = Gtk3::Image->new_from_stock( 'gtk-find', 6 );
    $item->set_image($image);
    $item->set_always_show_image(TRUE);
    $item->signal_connect( activate => \&search_by_name, $entry );
    $menu->append($item);

    $item = Gtk3::ImageMenuItem->new_with_mnemonic('Search by _description');
    $image = Gtk3::Image->new_from_stock( 'gtk-edit', 6 );
    $item->set_image($image);
    $item->set_always_show_image(TRUE);
    $item->signal_connect( activate => \&search_by_description, $entry );
    $menu->append($item);

    $item = Gtk3::ImageMenuItem->new_with_mnemonic('Search by _file name');
    $image = Gtk3::Image->new_from_stock( 'gtk-open', 6 );
    $item->set_image($image);
    $item->set_always_show_image(TRUE);
    $item->signal_connect( activate => \&search_by_file, $entry );
    $menu->append($item);

    $menu->show_all();
    return $menu;
}

sub text_changed_cb {
    my ( $entry, $pspec, $button ) = @_;
    my $has_text = length( $entry->get_text ) > 0;
    $entry->set_icon_sensitive( 'secondary', $has_text );
    $button->set_sensitive( $button, $has_text );
}

sub icon_press_cb {
    my ( $entry, $position, $event, $data ) = @_;
    if ( $position eq 'primary' ) {
        $menu->popup( undef, undef, undef, undef, $event->button,
            $event->time );
    } else {
        clear_entry($entry);
    }
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
