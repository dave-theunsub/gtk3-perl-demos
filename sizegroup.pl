#!/usr/bin/perl
#
# Size Groups
#
# GtkSizeGroup provides a mechanism for grouping a number of widgets
# together so they all request the same amount of space. This is
# typically useful when you want a column of widgets to have the same
# size, but you can't use a GtkTable widget.
#
# Note that size groups only affect the amount of space requested,
# not the size that the widgets finally receive. If you want the widgets
# in a GtkSizeGroup to actually be the same size, you need to pack
# them in such a way that they get the size they request and not more.
# For example, if you are packing your widgets into a table,
# you would not include the GTK_FILL flag.
#

package sizegroup;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;
my $table;

do_sizegroup();

sub do_sizegroup {
    my @color_options = ( 'Red',    'Green',  'Blue' );
    my @dash_options  = ( 'Solid',  'Dashed', 'Dotted' );
    my @end_options   = ( 'Square', 'Round',  'Arrow' );

    if ( !$window ) {
        $window = Gtk3::Dialog->new('');
        $window->add_button( 'gtk-close' => 0 );
        $window->set_title('Size Group');
        $window->signal_connect( response => sub { $window->destroy; 1 } );
        $window->signal_connect( destroy => sub { $window = undef; 1 } );

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        my $vbox = Gtk3::Box->new( 'vertical', 5 );
        $window->get_content_area()->add($vbox);
        $vbox->set_border_width(5);
        $vbox->set_homogeneous(FALSE);

        my $size_group = Gtk3::SizeGroup->new('horizontal');

        my $frame = Gtk3::Frame->new('Color Options');
        $vbox->pack_start( $frame, TRUE, TRUE, 0 );

        my $table = Gtk3::Grid->new;
        $table->set_border_width(5);
        $table->set_row_spacing(5);
        $table->set_column_spacing(10);
        $frame->add($table);

        add_row( $table, 0, $size_group, '_Foreground', @color_options );
        add_row( $table, 1, $size_group, '_Background', @color_options );

        # Add another frame holding line style options
        my $l_frame = Gtk3::Frame->new('Line Options');
        $vbox->pack_start( $l_frame, FALSE, FALSE, 0 );

        my $l_table = Gtk3::Grid->new;
        $l_table->set_border_width(5);
        $l_table->set_row_spacing(5);
        $l_table->set_column_spacing(10);
        $l_frame->add($l_table);

        add_row( $l_table, 0, $size_group, '_Dashing',    @dash_options );
        add_row( $l_table, 1, $size_group, '_Background', @end_options );

        # Add a CheckButton to turn grouping on and off
        my $cb = Gtk3::CheckButton->new_with_mnemonic('_Enable grouping');
        $vbox->pack_start( $cb, FALSE, FALSE, 0 );

        $cb->set_active(TRUE);
        $cb->signal_connect(
            toggled => \&toggle_grouping,
            $size_group
            );
    }

    if ( !$window->get_visible ) {
        $window->show_all();
    } else {
        $window->destroy();
    }

    Gtk3->main();
}

sub add_row {
    my ( $table, $row, $size_group, $text, @options ) = @_;

    my $label = Gtk3::Label->new_with_mnemonic($text);
    $label->set_halign('start');
    $label->set_valign('end');
    $label->set_hexpand(TRUE);
    $table->attach( $label, 0, $row, 1, 1 );

    my $combo_box = create_combo_box(@options);
    $label->set_mnemonic_widget($combo_box);
    $size_group->add_widget($combo_box);
    $table->attach( $combo_box, 1, $row, 1, 1 );
}

sub create_combo_box {
    my @options   = @_;
    my $combo_box = Gtk3::ComboBoxText->new();

    for my $o (@options) {
        $combo_box->append_text($o);
    }
    $combo_box->set_active(FALSE);
    return $combo_box;
}

sub toggle_grouping {
    my ( $button, $size_group ) = @_;

    # GTK_SIZE_GROUP_NONE is not generally useful, but is useful
    # here to show the effect of GTK_SIZE_GROUP_HORIZONTAL by
    # contrast.

    my $new_mode = $button->get_active() ? 'horizontal' : 'none';

    $size_group->set_mode($new_mode);
}

1;
