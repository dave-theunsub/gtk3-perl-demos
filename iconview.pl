#!/usr/bin/perl

# GtkIconView — A widget which displays a list of icons in a grid
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window = Gtk3::Window->new;
$window->set_default_size( 300, 80 );
$window->set_border_width( 5 );
$window->signal_connect( destroy => sub { Gtk3->main_quit } );

my $box = Gtk3::Box->new( 'vertical', 5 );
$window->add( $box );

my @icons = (
    { name => 'gtk-home',  label => 'Home' },
    { name => 'gtk-copy',  label => 'Copy' },
    { name => 'gtk-apply', label => 'Apply' },
    { name => 'gtk-quit',  label => 'Quit' },
);

my $store = Gtk3::ListStore->new( 'Gtk3::Gdk::Pixbuf', 'Glib::String', );

my $view = Gtk3::IconView->new;
$box->pack_start( $view, TRUE, TRUE, 5 );
$view->set_model( $store );
$view->set_pixbuf_column( 0 );
$view->set_text_column( 1 );
$view->set_activate_on_single_click( TRUE );
$view->signal_connect( 'item-activated' => \&click, $store );

for my $i ( @icons ) {
    my $iter = $store->append;
    my $pix  = Gtk3::IconTheme->get_default()
        ->load_icon( $i->{ name }, 32, 'use-builtin', );
    $store->set( $iter, 0, $pix, 1, $i->{ label } );
}

my $grid = Gtk3::Grid->new;
$grid->set_column_homogeneous( TRUE );
$grid->set_column_spacing( 10 );
$box->pack_start( $grid, FALSE, FALSE, 5 );
$grid->attach( Gtk3::Label->new( 'Activate images with' ), 0, 0, 1, 1 );

my $single_btn
    = Gtk3::RadioButton->new_with_label_from_widget( undef, 'single click' );
$single_btn->signal_connect( toggled => \&toggled, TRUE );
$grid->attach( $single_btn, 1, 0, 1, 1 );
my $double_btn = Gtk3::RadioButton->new_with_label_from_widget( $single_btn,
    'double click' );
$double_btn->signal_connect( toggled => \&toggled, FALSE );
$grid->attach( $double_btn, 2, 0, 1, 1 );

$window->show_all;

Gtk3->main();

sub click {
    my ( $view, $path, $model ) = @_;

    my $iter  = $model->get_iter( $path );
    my $value = $model->get_value( $iter, 1 );
    my $image = $model->get_value( $iter, 0 );
    warn "received $value\n";

    my $dialog = Gtk3::MessageDialog->new(
        $window,                                # parent
        [ qw| modal destroy-with-parent | ],    # options
        'info',                                 # type
        'close',                                # button
        "You selected $value",                  # label
    );
    $dialog->run;
    $dialog->destroy;
}

sub toggled {
    my ( $button, $value ) = @_;

    $view->set_activate_on_single_click( $value );
}
