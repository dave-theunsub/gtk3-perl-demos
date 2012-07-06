#!/usr/bin/perl
#
# Dialog and Message Boxes
#
# Dialog widgets are used to pop up a transient window for user feedback.

package dialog_boxes;

use strict;
use warnings;

use constant GTK_RESPONSE_OK => -5;

use feature 'state';

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

my $window;
my ( $entry1, $entry2 );

do_dialog();
Gtk3->main;

sub do_dialog {
    if ( !$window ) {
        $window = Gtk3::Window->new('toplevel');
        $window->set_title('Dialogs');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_border_width(8);

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        my $frame = Gtk3::Frame->new('Dialogs');
        $window->add($frame);

        my $vbox = Gtk3::Box->new( 'vertical', 8 );
        $vbox->set_border_width(8);
        $frame->add($vbox);

        # Standard message dialog
        my $hbox = Gtk3::Box->new( 'horizontal', 8 );
        $vbox->pack_start( $hbox, FALSE, FALSE, 0 );
        my $button = Gtk3::Button->new_with_mnemonic('_Message Dialog');
        $button->signal_connect( clicked => \&message_dialog_clicked );
        $hbox->pack_start( $button, FALSE, FALSE, 0 );
        $vbox->pack_start( Gtk3::Separator->new('horizontal'),
            FALSE, FALSE, 0 );

        # Interactive dialog
        $hbox = Gtk3::Box->new( 'horizontal', 8 );
        $vbox->pack_start( $hbox, FALSE, FALSE, 0 );

        my $vbox2 = Gtk3::Box->new( 'vertical', 0 );
        $button = Gtk3::Button->new_with_mnemonic('_Interactive Dialog');
        $button->signal_connect( clicked => \&interactive_dialog_clicked );
        $hbox->pack_start( $vbox2, FALSE, FALSE, 0 );
        $vbox2->pack_start( $button, FALSE, FALSE, 0 );

        my $table = Gtk3::Grid->new();
        $table->set_row_spacing(4);
        $table->set_column_spacing(4);
        $hbox->pack_start( $table, FALSE, FALSE, 0 );

        my $label = Gtk3::Label->new_with_mnemonic('_Entry 1');
        $table->attach( $label, 0, 0, 1, 1 );

        $entry1 = Gtk3::Entry->new();
        $table->attach( $entry1, 1, 0, 1, 1 );
        $label->set_mnemonic_widget($entry1);

        $label = Gtk3::Label->new_with_mnemonic('E_ntry 2');
        $table->attach( $label, 0, 1, 1, 1 );

        $entry2 = Gtk3::Entry->new();
        $table->attach( $entry2, 1, 1, 1, 1 );

    }

    if ( !$window->get_visible ) {
        $window->show_all;
    } else {
        $window->destroy();
    }

    return $window;
}

sub message_dialog_clicked {
    state $i = 1;
    # format_secondary_text not implemented yet
    my $dialog = Gtk3::MessageDialog->new(
        $window,
        [qw( modal destroy-with-parent )],
        'info',
        'ok',
        "This messagebox has been popped up the following\n"
            . "number of times: $i"
            );

    $dialog->run;
    $dialog->destroy;
    $i++;
}

sub interactive_dialog_clicked {
    # new_with_buttons not implemented yet
    my $dialog = Gtk3::Dialog->new();
    $dialog->set_title('Interactive Dialog');
    $dialog->set_modal(TRUE);
    $dialog->set_destroy_with_parent(TRUE);
    $dialog->add_button( 'gtk-ok', GTK_RESPONSE_OK );

    my $hbox = Gtk3::Box->new( 'horizontal', 8 );
    $hbox->set_border_width(8);
    $dialog->get_content_area()->add($hbox);

    my $stock = Gtk3::Image->new_from_stock( 'gtk-dialog-question', 6 );
    $hbox->pack_start( $stock, FALSE, FALSE, 0 );

    my $table = Gtk3::Grid->new();
    $table->set_row_spacing(4);
    $table->set_column_spacing(4);
    $hbox->pack_start( $table, TRUE, TRUE, 0 );

    my $label = Gtk3::Label->new_with_mnemonic('_Entry 1');
    $table->attach( $label, 0, 0, 1, 1 );
    my $local_entry1 = Gtk3::Entry->new();
    $local_entry1->set_text( $entry1->get_text() );
    $table->attach( $local_entry1, 1, 0, 1, 1 );
    $label->set_mnemonic_widget($local_entry1);

    $label = Gtk3::Label->new_with_mnemonic('E_ntry 2');
    $table->attach( $label, 0, 1, 1, 1 );
    my $local_entry2 = Gtk3::Entry->new();
    $local_entry2->set_text( $entry2->get_text() );
    $table->attach( $local_entry2, 1, 1, 1, 1 );
    $label->set_mnemonic_widget($local_entry2);

    $hbox->show_all();

    if ( 'ok' eq $dialog->run ) {
        $entry1->set_text( $local_entry1->get_text );
        $entry2->set_text( $local_entry2->get_text );
    }
    $dialog->destroy;
}

1;
