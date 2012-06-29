#!/usr/bin/perl

package appwindow;

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant COLOR_RED   => 0;
use constant COLOR_GREEN => 1;
use constant COLOR_BLUE  => 2;

use constant SHAPE_SQUARE    => 0;
use constant SHAPE_RECTANGLE => 1;
use constant SHAPE_OVAL      => 2;

use constant GTK_RESPONSE_OK => -5;

my $window;
my $messagelabel;
my $infobar;
my $registered = FALSE;

my @shape_entries = (
    # name,        stock id, label,        accelerator,  tooltip,     value
    [ "Square", undef, "_Square", "<control>S", "Square", SHAPE_SQUARE ],
    [   "Rectangle", undef, "_Rectangle", "<control>R",
        "Rectangle", SHAPE_RECTANGLE
        ],
    [ "Oval", undef, "_Oval", "<control>O", "Egg", SHAPE_OVAL ],
    );

my @color_entries = (
    # name,    stock id, label,    accelerator,  tooltip, value
    [ "Red",   undef, "_Red",   "<control>R", "Blood", COLOR_RED ],
    [ "Green", undef, "_Green", "<control>G", "Grass", COLOR_GREEN ],
    [ "Blue",  undef, "_Blue",  "<control>B", "Sky",   COLOR_BLUE ],
    );

my @entries = (
    # name,              stock id,  label
    [ "FileMenu",        undef, "_File" ],
    [ "PreferencesMenu", undef, "_Preferences" ],
    [ "ColorMenu",       undef, "_Color" ],
    [ "ShapeMenu",       undef, "_Shape" ],
    [ "HelpMenu",        undef, "_Help" ],
    [ "OpenMenu",        undef, "_Open" ],
    [   "New",               'gtk-new',
        "_New",              "<control>N",
        "Create a new file", \&activate_action
        ],
    [   "Open",        'gtk-open', "_Open", "<control>O",
        "Open a file", \&activate_action
        ],
    [   "Save",              'gtk-save',
        "_Save",             "<control>S",
        "Save current file", \&activate_action
        ],
    [   "SaveAs",         'gtk-save',
        "Save _As...",    undef,
        "Save to a file", \&activate_action
        ],
    [ "Quit", 'gtk-quit', "_Quit", "<control>Q", "Quit", \&activate_action ],
    [ "About", undef, "_About", "<control>A", "About", \&activate_action ],
    [ "Logo", "demo-gtk-logo", undef, undef, "GTK+", \&activate_action ],
    );

my @toggle_entries = ( [
        "Bold",  'gtk-bold',      # name, stock id
        "_Bold", "<control>B",    # label, accelerator
        "Bold",                   # tooltip
        \&activate_action, TRUE
        ],                        # is_active
    [   "DarkTheme",          undef,    # name, stock id
        "_Prefer Dark Theme", undef,    # label, accelerator
        "Prefer Dark Theme",            # tooltip
        \&activate_action, FALSE
        ],                              # is_active
    [   "HideTitlebar",                  undef,
        "_Hide Titlebar when maximized", undef,
        "Hide Titlebar when maximized",  \&activate_action,
        FALSE
        ] );

do_appwindow();
Gtk3->main();

sub menuitem_cb {
    my ( $callback_data, $callback_action, $widget ) = @_;

    my $dialog = Gtk3::MessageDialog->new(
        $callback_data,
        'destroy-with-parent',
        'info',
        'close',
        sprintf "You selected or toggled the menu item: \"%s\"",
        Gtk3::ItemFactory->path_from_widget($widget) );

    # Close dialog on user response
    $dialog->signal_connect( response => sub { $dialog->destroy; 1 } );

    $dialog->show;
}

sub toolbar_cb {
    my ( $button, $data ) = @_;

    my $dialog =
        Gtk3::MessageDialog->new( $data, 'destroy-with-parent', 'info',
        'close', "You selected a toolbar button" );

    # Close dialog on user response
    $dialog->signal_connect( response => sub { $_[0]->destroy; 1 } );

    $dialog->show;
}

sub register_stock_icons {
    if ( !$registered ) {
   # https://mail.gnome.org/archives/gtk-perl-list/2012-February/msg00024.html
   #my @items = (
   #{
   # 	stock_id => "demo-gtk-logo",
   #    label    => "_GTK!",
   #}) ;

        $registered = TRUE;

        # Register our stock items
        #Gtk3::Stock->add($items);

        # Add our custom icon factory to the list of defaults
        my $factory = Gtk3::IconFactory->new;
        $factory->add_default;

        #
        # demo_find_file() looks in the the current directory first,
        # so you can run gtk-demo without installing GTK, then looks
        # in the location where the file is installed.
        #
        my $pixbuf = undef;
###      my $filename = demo_find_file ("gtk-logo-rgb.gif", undef);
        my $filename = "gtk-logo-rgb.gif";
        if ($filename) {
            eval {
                $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file(
                    #main::demo_find_file($filename) );
                    demo_find_file($filename) );

           # The gtk-logo-rgb icon has a white background, make it transparent
                my $transparent =
                    $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );

                my $icon_set = Gtk3::IconSet->new_from_pixbuf($transparent);
                $factory->add( "demo-gtk-logo", $icon_set );
            };
            warn "failed to load GTK logo for toolbar"
                if $@;
        }
       # $factory goes out of scope here, but GTK will hold a reference on it.
    }
}

sub get_ui {
    return "<ui>
	<menubar name='MenuBar'>
	<menu action='FileMenu'>
      <menuitem action='New'/>
      <menuitem action='Open'/>
      <menuitem action='Save'/>
      <menuitem action='SaveAs'/>
      <separator/>
      <menuitem action='Quit'/>
    </menu>
    <menu action='PreferencesMenu'>
	  <menuitem action='DarkTheme'/>
	  <menuitem action='HideTitlebar'/>
    <menu action='ColorMenu'>
        <menuitem action='Red'/>
        <menuitem action='Green'/>
        <menuitem action='Blue'/>
      </menu>
      <menu action='ShapeMenu'>
        <menuitem action='Square'/>
        <menuitem action='Rectangle'/>
        <menuitem action='Oval'/>
      </menu>
      <menuitem action='Bold'/>
    </menu>
    <menu action='HelpMenu'>
      <menuitem action='About'/>
    </menu>
  </menubar>
  <toolbar  name='ToolBar'>
    <toolitem action='Open'/>
    <toolitem action='Quit'/>
    <separator/>
    <toolitem action='Logo'/>
  </toolbar>
</ui>";
}

sub update_statusbar {
    my ( $buffer, $statusbar ) = @_;
    $statusbar->pop(0);

    my $count = $buffer->get_char_count();
    my $iter  = $buffer->get_iter_at_mark( $buffer->get_insert );

    my $row = $iter->get_line;
    my $col = $iter->get_line_offset;

    my $msg =
        sprintf( 'Cursor at row %d column %d - ' . '%d chars in document',
        $row, $col, $count );

    $statusbar->push( 0, $msg );
}

sub activate_action {
    my $action = shift;

    my $name = $action->get_name;

    if ( $name eq 'DarkTheme' ) {
        my $value    = $action->get_active;
        my $settings = Gtk3::Settings->get_default;
        $settings->set( 'gtk-application-prefer-dark-theme', $value );
        return;
    }

    if ( $name eq 'HideTitlebar' ) {
        my $value = $action->get_active;
        $window->set_hide_titlebar_when_maximized( $value => TRUE );
        return;
    }

    my $dialog =
        Gtk3::MessageDialog->new( $window, 'destroy-with-parent', 'info',
        'close', 'You activated action "%s"', $name );

    $dialog->signal_connect( response => sub { $dialog->destroy } );
    $dialog->show();
}

sub activate_radio_action {
    my ( $action, $current ) = @_;

    my $name   = $current->get_name;
    my $active = $current->get_active;
    my $value  = $current->get_current_value;

    if ($active) {
        my $text = sprintf(
            "You activated radio action: \"%s\".\n" . 'Current value: %d',
            $name, $value );
        $messagelabel->set_text($text);
        $infobar->set_message_type(
              $value == 0 ? 'GTK_MESSAGE_INFO'
            : $value == 1 ? 'GTK_MESSAGE_WARNING'
            : $value == 2 ? 'GTK_MESSAGE_QUESTION'
            : $value == 3 ? 'GTK_MESSAGE_ERROR'
            : $value == 4 ? 'GTK_MESSAGE_OTHER'
            : 'GTK_MESSAGE_OTHER'
            );
        $infobar->show;
    }
}

sub mark_set_callback {
    my ( $buffer, $new_location, $mark, $data ) = @_;

    update_statusbar( $buffer, $data );
}

sub do_appwindow {
    if ( !$window ) {
        register_stock_icons();

        $window = Gtk3::Window->new('toplevel');
        $window->set_title('Application Window');
        $window->signal_connect( destroy => sub { Gtk3->main_quit } );
        $window->set_icon_name('gtk-open');
        $window->set_default_size( 200, 200 );

        my $table = Gtk3::Grid->new;
        $window->add($table);

        # Create the menubar and toolbar

        my $action_group = Gtk3::ActionGroup->new('AppWindowActions');
        my $open_action  = Gtk3::Action->new(
            [ 'Open', '_Open', 'Open a file', 'gtk-open' ] );
        $action_group->add_action($open_action);

        $action_group->add_actions( \@entries, undef );

        $action_group->add_toggle_actions( \@toggle_entries, undef );

        $action_group->add_radio_actions( \@color_entries, COLOR_RED,
            \&activate_radio_action );

        $action_group->add_radio_actions( \@shape_entries, SHAPE_SQUARE,
            \&activate_radio_action );

        my $ui = Gtk3::UIManager->new();
        $ui->insert_action_group( $action_group, 0 );
        $window->add_accel_group( $ui->get_accel_group );
        my $ui_info = get_ui();
        $ui->add_ui_from_string( $ui_info, length($ui_info) );

        $table->attach( $ui->get_widget('/MenuBar'), 0, 0, 1, 1 );
        $table->attach( $ui->get_widget('/ToolBar'), 0, 1, 1, 1 );

        # Create document
        $infobar = Gtk3::InfoBar->new;
        $infobar->set_no_show_all(TRUE);
        $messagelabel = Gtk3::Label->new('');
        $messagelabel->show();
        $infobar->pack_start( $messagelabel, TRUE, TRUE, 0 );
        $infobar->add_button( 'gtk-ok', GTK_RESPONSE_OK );
        $infobar->signal_connect(
            response => sub {
                $infobar->hide();
            } );
        $infobar->set_halign('fill');
        $table->attach( $infobar, 0, 2, 1, 1 );

        my $sw = Gtk3::ScrolledWindow->new( undef, undef );
        $sw->set_policy( 'automatic', 'automatic' );
        $sw->set_shadow_type('in');
        $sw->set_halign('fill');
        $sw->set_valign('fill');
        $sw->set_hexpand(TRUE);
        $sw->set_vexpand(TRUE);
        $table->attach( $sw, 0, 3, 1, 1 );

        my $contents = Gtk3::TextView->new();
        $contents->grab_focus();
        $sw->add($contents);

        # Create statusbar
        my $statusbar = Gtk3::Statusbar->new;
        $sw->set_halign('fill');
        $table->attach( $statusbar, 0, 4, 1, 1 );

        # Show text widget info in the statusbar
        my $buffer = $contents->get_buffer();
        $buffer->signal_connect(
            changed => \&update_statusbar,
            $statusbar
            );
        $buffer->signal_connect(
            mark_set => \&mark_set_callback,
            $statusbar
            );

        update_statusbar( $buffer, $statusbar );
    }

    if ( !$window->get_visible ) {
        $window->show_all;
    } else {
        $window->destroy;
    }

    return $window;
}

sub demo_find_file {
    # This is only temporary so it can run stand alone.
    my $base    = shift;
    my $PROGDIR = $0;

    return $base if -e $base;

    my $filename = $PROGDIR . $base;
    die "Cannot find demo data file $base ($filename)\n"
        unless -e $filename;

    return $filename;
}

1;
