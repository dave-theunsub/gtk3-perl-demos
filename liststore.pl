#!/usr/bin/perl
#
# The GtkListStore is used to store data in list form, to be used
# later on by a GtkTreeView to display it. This demo builds a
# simple GtkListStore and displays it. See the Stock Browser
# demo for a more advanced example.
#

package liststore;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant COLUMN_FIXED       => 0;
use constant COLUMN_NUMBER      => 1;
use constant COLUMN_SEVERITY    => 2;
use constant COLUMN_DESCRIPTION => 3;

my @data = (
    {   fixed       => FALSE,
        number      => 60482,
        severity    => "Normal",
        description => "scrollable notebooks and hidden tabs"
        },
    {   fixed    => FALSE,
        number   => 60620,
        severity => "Critical",
        description =>
            "gdk_window_clear_area (gdkwindow-win32.c) is not thread-safe"
            },
    {   fixed       => FALSE,
        number      => 50214,
        severity    => "Major",
        description => "Xft support does not clean up correctly"
        },
    {   fixed       => TRUE,
        number      => 52877,
        severity    => "Major",
        description => "GtkFileSelection needs a refresh method. "
        },
    {   fixed       => FALSE,
        number      => 56070,
        severity    => "Normal",
        description => "Can't click button after setting in sensitive"
        },
    {   fixed       => TRUE,
        number      => 56355,
        severity    => "Normal",
        description => "GtkLabel - Not all changes propagate correctly"
        },
    {   fixed       => FALSE,
        number      => 50055,
        severity    => "Normal",
        description => "Rework width/height computations for TreeView"
        },
    {   fixed       => FALSE,
        number      => 58278,
        severity    => "Normal",
        description => "gtk_dialog_set_response_sensitive () doesn't work"
        },
    {   fixed       => FALSE,
        number      => 55767,
        severity    => "Normal",
        description => "Getters for all setters"
        },
    {   fixed       => FALSE,
        number      => 56925,
        severity    => "Normal",
        description => "Gtkcalender size"
        },
    {   fixed       => FALSE,
        number      => 56221,
        severity    => "Normal",
        description => "Selectable label needs right-click copy menu"
        },
    {   fixed       => TRUE,
        number      => 50939,
        severity    => "Normal",
        description => "Add shift clicking to GtkTextView"
        },
    {   fixed       => FALSE,
        number      => 6112,
        severity    => "Enhancement",
        description => "netscape-like collapsable toolbars"
        },
    {   fixed       => FALSE,
        number      => 1,
        severity    => "Normal",
        description => "First bug :=)"
        },
    );

do_liststore();

sub add_columns {
    my $treeview = shift;
    my $model    = $treeview->get_model();

    # Column for fixed toggles
    my $renderer = Gtk3::CellRendererToggle->new;
    $renderer->signal_connect(
        toggled => \&fixed_toggled,
        $model
        );

    my $column =
        Gtk3::TreeViewColumn->new_with_attributes( 'Fixed', $renderer,
        active => COLUMN_FIXED );

    # Set this column to a fixed sizing (of 50 pixels)
    $column->set_sizing('fixed');
    $column->set_fixed_width(50);
    $treeview->append_column($column);

    # Column for bug numbers
    $renderer = Gtk3::CellRendererText->new;
    $column =
        Gtk3::TreeViewColumn->new_with_attributes( 'Bug number', $renderer,
        text => COLUMN_NUMBER );
    $column->set_sort_column_id(COLUMN_NUMBER);
    $treeview->append_column($column);

    # Column for severities
    $column =
        Gtk3::TreeViewColumn->new_with_attributes( 'Severity', $renderer,
        text => COLUMN_SEVERITY );
    $column->set_sort_column_id(COLUMN_SEVERITY);
    $treeview->append_column($column);

    # Column for description
    $column =
        Gtk3::TreeViewColumn->new_with_attributes( 'Description', $renderer,
        text => COLUMN_DESCRIPTION );
    $column->set_sort_column_id(COLUMN_DESCRIPTION);
    $treeview->append_column($column);
}

sub fixed_toggled {
    my ( $cell, $path_str, $model ) = @_;

    my $path = Gtk3::TreePath->new($path_str);

    # Get toggled iter
    my $iter = $model->get_iter($path);
    my $fixed = $model->get_value( $iter, COLUMN_FIXED );

    # Do something with value
    $fixed ^= 1;

    # Set new value
    $model->set( $iter, COLUMN_FIXED, $fixed );
}

sub create_model {
    my $lstore =
        Gtk3::ListStore->new( 'Glib::Boolean', 'Glib::Uint', 'Glib::String',
        'Glib::String', );

    for my $item (@data) {
        my $iter = $lstore->append();
        $lstore->set(
            $iter,
			COLUMN_FIXED, $item->{fixed},
			COLUMN_NUMBER, $item->{number},
		 	COLUMN_SEVERITY, $item->{severity},
		   	COLUMN_DESCRIPTION, $item->{description}
		);
    }
    return $lstore;
}

sub do_liststore {
    my $window;

    if ( !$window ) {
        $window = Gtk3::Window->new;
        $window->set_title('ListStore demo');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_border_width(8);
        $window->set_default_size( 300, 250 );

        my $icon = 'gtk-logo-rgb.gif';
        if ( -e $icon ) {
            my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
            my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
            $window->set_icon($transparent);
        }

        # This VBox will be handy to organize objects
        my $box = Gtk3::Box->new( 'vertical', 8 );
        $box->set_homogeneous(FALSE);
        $window->add($box);

        $box->pack_start(
            Gtk3::Label->new(
                      'This is the bug list (note: not based on real data, '
                    . 'it would be nice to have a nice ODBC interface to '
                    . 'bugzilla or so, though).'
                    ),
            FALSE, FALSE, 0
            );

        my $sw = Gtk3::ScrolledWindow->new( undef, undef );
        $sw->set_shadow_type('etched-in');
        $sw->set_policy( 'never', 'automatic' );
        $box->pack_start( $sw, TRUE, TRUE, 5 );

        # Create TreeModel
        my $model = create_model();

        # Create a TreeView
        my $treeview = Gtk3::TreeView->new($model);
        $treeview->set_rules_hint(TRUE);
        $treeview->set_search_column(COLUMN_DESCRIPTION);
        $sw->add($treeview);

        # Add columns to TreeView
        add_columns($treeview);
        $window->show_all();
        Gtk3->main();
    }

    if ( !$window->get_visible ) {
        $window->show_all;
    } else {
        $window->destroy();
    }
}

1;
