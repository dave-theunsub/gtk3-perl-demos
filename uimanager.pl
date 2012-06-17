#!/usr/bin/perl

use strict;
use warnings;

use lib '.';
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant COLOR_RED   => 0;
use constant COLOR_GREEN => 1;
use constant COLOR_BLUE  => 2;

use constant SHAPE_SQUARE    => 0;
use constant SHAPE_RECTANGLE => 1;
use constant SHAPE_OVAL      => 2;

use constant SOUND_LOW => 0;
use constant SOUND_MEDIUM => 1;
use constant SOUND_HIGH => 2;

do_ui_manager();

sub do_ui_manager {
    my $window = Gtk3::Window->new('toplevel');
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );
    $window->set_border_width(0);
    $window->set_title('UI Manager');

	my $icon = 'gtk-logo-rgb.gif';
    if( -e $icon ) {
		my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file('gtk-logo-rgb.gif');
        my $transparent = $pixbuf->add_alpha (TRUE, 0xff, 0xff, 0xff);
        $window->set_icon( $transparent );
    }


    my @entries = get_entries();
    my @toggle  = get_toggle_entries();
    my @shape   = get_shape_entries();
    my @color   = get_color_entries();
		my @vol		= get_volume_entries();
    my $ui_info = get_ui_info();

    my $actions = Gtk3::ActionGroup->new('Actions');
    $actions->add_actions(\@entries, undef);
    $actions->add_toggle_actions(\@toggle, undef);
    $actions->add_radio_actions(\@color, COLOR_RED,
      \&activate_radio_action);
    $actions->add_radio_actions(\@shape, SHAPE_OVAL,
      \&activate_radio_action);
	$actions->add_radio_actions(\@vol, SOUND_MEDIUM,
      \&activate_radio_action);

    my $ui = Gtk3::UIManager->new();
    $ui->insert_action_group($actions, 0);
    $window->add_accel_group($ui->get_accel_group);
    $ui->add_ui_from_string($ui_info, length($ui_info));

    my $vbox = Gtk3::Box->new( 'vertical', 0);
	$vbox->set_homogeneous( FALSE );
    $window->add($vbox);
    $vbox->pack_start($ui->get_widget('/MenuBar'), FALSE, FALSE, 0);

    my $label = Gtk3::Label->new("Type\n<alt>\nto start");
    $label->set_size_request(200, 200);
    $label->set_halign('center');
    $label->set_valign('center');
    $vbox->pack_start($label, TRUE, TRUE, 0);

    $vbox->pack_start(Gtk3::HSeparator->new(), FALSE, TRUE, 0);

    my $box2 = Gtk3::Box->new('vertical', 10);
	$box2->set_homogeneous( FALSE );
    $vbox->pack_start($box2, FALSE, TRUE, 0);

    my $button = Gtk3::Button->new_with_label('close');
    $button->signal_connect(clicked => sub { $window->destroy });
    $vbox->pack_start($button, FALSE, TRUE, 0);
    $button->set_can_default(TRUE);
    $button->grab_default(TRUE);

    $window->show_all();
    Gtk3->main();
}

sub activate_action {
    my $action = shift;
    warn "Action \"", $action->get_name, "\" activated\n";
}

sub activate_radio_action {
    my ($action, $current) = @_;
    warn "Radio action \"", $current->get_name, "\" selected\n";
}

sub get_ui_info {
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
		  <menu action='VolumeMenu'>
		  <menuitem action='Low'/>
		  <menuitem action='Medium'/>
		  <menuitem action='High'/>
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
    <separator action='Sep1'/>
    <toolitem action='Logo'/>
  </toolbar>
</ui>";
}

sub get_shape_entries {
    my @shapes = (
        [ 'Square', undef, '_Square', '<control>S', 'Square', SHAPE_SQUARE ],
        [   'Rectangle', undef, '_Rectangle', '<control>R',
            'Rectangle', SHAPE_RECTANGLE
        ],
        [ 'Oval', undef, '_Oval', '<control>O', 'Egg', SHAPE_OVAL ],
        );
    return @shapes;
}

sub get_color_entries {
    my @colors = (
        [ 'Red',   undef, '_Red',   '<control>R', 'Blood', COLOR_RED ],
        [ 'Green', undef, '_Green', '<control>G', 'Grass', COLOR_GREEN ],
        [ 'Blue',  undef, '_Blue',  '<control>B', 'Sky',   COLOR_BLUE ],
        );
    return @colors;
}

sub get_toggle_entries {
    my @toggle = ( [
            'Bold', 'gtk-stock-bold',  '_Bold', '<control>B',
            'Bold', \&activate_action, TRUE
            ] );
    return @toggle;
}

sub get_entries {
    my @entries = (
        [ 'FileMenu',        undef, '_File' ],
        [ 'PreferencesMenu', undef, '_Preferences' ],
        [ 'ColorMenu',       undef, '_Color' ],
        [ 'ShapeMenu',       undef, '_Shape' ],
		[ 'VolumeMenu',       undef, '_Volume' ],
        [ 'HelpMenu',        undef, '_Help' ],
        [ 'New',               'gtk-new',
          '_New',              '<control>N',
          'Create a new file', \&activate_action
        ],
        [ 'Open',        'gtk-open',
          '_Open',       '<control>O',
          'Open a file', \&activate_action
        ],
        [ 'Save',              'gtk-save',
          '_Save',             '<control>S',
          'Save current file', \&activate_action
        ],
        [ 'SaveAs',         'gtk-save',
          'Save _As...',    undef,
          'Save to a file', \&activate_action
        ],
        [ 'Quit', 'gtk-quit', '_Quit', '<control>Q',
          'Quit', \&activate_action
        ],
        [ 'About', undef, '_About', '<control>A', 'About',
						\&activate_action
        ],
        [ 'Logo', 'demo-gtk-logo', undef, undef, 'GTK+',
						\&activate_action
		],
        );
    return @entries;
}

sub get_volume_entries {
  my @vol_entries = (
    {
		  name        => 'Low',
		  label       => 'Low',
		  tooltip     => 'Low volume',
		  accelerator => '<control>L',
		  value       => 0
		},
		{
		  name        => 'Medium',
		  label       => 'Medium',
		  tooltip     => 'Medium volume',
		  accelerator => '<control>M',
		  value       => 1
		},
		{
		  name        => 'High',
		  label       => 'High',
		  tooltip     => 'High volume',
		  accelerator => '<control>H',
		  value       => 2
		},
  );
  return @vol_entries;
}
