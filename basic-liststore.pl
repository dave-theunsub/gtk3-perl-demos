#!/usr/bin/perl
#
# The GtkListStore is used to store data in list form, to be used
# later on by a GtkTreeView to display it. This is a very
# basic GtkListStore.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new('toplevel');
$window->set_title('GtkListStore');
$window->set_size_request( 400, 200 );
$window->signal_connect( destroy => sub { Gtk3->main_quit; } );

my $box = Gtk3::Box->new( 'vertical', 5 );
$window->add($box);

my $swin = Gtk3::ScrolledWindow->new( undef, undef );
$swin->set_policy( 'never', 'automatic' );
$box->pack_start( $swin, TRUE, TRUE, 0 );

my $liststore = Gtk3::ListStore->new('Glib::String');
for ( 1 .. 100 ) {
    my $iter = $liststore->append;
    $liststore->set( $iter, 0, $_ );
}

my $view = Gtk3::TreeView->new_with_model($liststore);
$view->append_column(
    Gtk3::TreeViewColumn->new_with_attributes(
        'Numbers', Gtk3::CellRendererText->new, text => 0
        ) );
$swin->add($view);

$box->pack_start( Gtk3::Separator->new('vertical'), FALSE, FALSE, 0 );

my $bbox = Gtk3::ButtonBox->new('horizontal');
$bbox->set_layout('spread');
$box->pack_start( $bbox, FALSE, FALSE, 0 );

my $button = Gtk3::Button->new_from_stock('gtk-delete');
$bbox->add($button);
$button->signal_connect( clicked => \&activate, $view );

$button = Gtk3::Button->new_from_stock('gtk-close');
$bbox->add($button);
$button->signal_connect( clicked => sub { Gtk3->main_quit } );

$window->show_all();
Gtk3->main;

sub activate {
    my ( undef, $tree ) = @_;
    my $sel = $tree->get_selection;

    my ( $model, $iter ) = $sel->get_selected;
    return unless $iter;

    $model->remove($iter);
    return TRUE;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
