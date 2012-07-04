package Gtk3;

use strict;
use warnings;
use Carp qw/croak/;
use Cairo::GObject;
use Glib::Object::Introspection;
use Exporter;

our @ISA = qw(Exporter);

my $_GTK_BASENAME = 'Gtk';
my $_GTK_VERSION = '3.0';
my $_GTK_PACKAGE = 'Gtk3';

my $_GDK_BASENAME = 'Gdk';
my $_GDK_VERSION = '3.0';
my $_GDK_PACKAGE = 'Gtk3::Gdk';

my $_GDK_PIXBUF_BASENAME = 'GdkPixbuf';
my $_GDK_PIXBUF_VERSION = '2.0';
my $_GDK_PIXBUF_PACKAGE = 'Gtk3::Gdk';

my $_PANGO_BASENAME = 'Pango';
my $_PANGO_VERSION = '1.0';
my $_PANGO_PACKAGE = 'Pango';

my %_GTK_NAME_CORRECTIONS = (
  'Gtk3::stock_add' => 'Gtk3::Stock::add',
  'Gtk3::stock_add_static' => 'Gtk3::Stock::add_static',
  'Gtk3::stock_list_ids' => 'Gtk3::Stock::list_ids',
  'Gtk3::stock_lookup' => 'Gtk3::Stock::lookup',
  'Gtk3::stock_set_translate_func' => 'Gtk3::Stock::set_translate_func',
);
my @_GTK_FLATTEN_ARRAY_REF_RETURN_FOR = qw/
  Gtk3::ActionGroup::list_actions
  Gtk3::Builder::get_objects
  Gtk3::CellLayout::get_cells
  Gtk3::Stock::list_ids
  Gtk3::TreePath::get_indices
  Gtk3::Window::list_toplevels
/;
my @_GTK_HANDLE_SENTINEL_BOOLEAN_FOR = qw/
  Gtk3::Stock::lookup
  Gtk3::TreeModel::get_iter
  Gtk3::TreeModel::get_iter_first
  Gtk3::TreeModel::get_iter_from_string
  Gtk3::TreeModel::iter_children
  Gtk3::TreeModel::iter_nth_child
  Gtk3::TreeModel::iter_parent
  Gtk3::TreeModelFilter::convert_child_iter_to_iter
  Gtk3::TreeModelSort::convert_child_iter_to_iter
  Gtk3::TreeSelection::get_selected
/;

my @_GDK_PIXBUF_FLATTEN_ARRAY_REF_RETURN_FOR = qw/
  Gtk3::Gdk::Pixbuf::get_formats
/;

sub import {
  my $class = shift;

  Glib::Object::Introspection->setup (
    basename => $_GTK_BASENAME,
    version => $_GTK_VERSION,
    package => $_GTK_PACKAGE,
    name_corrections => \%_GTK_NAME_CORRECTIONS,
    flatten_array_ref_return_for => \@_GTK_FLATTEN_ARRAY_REF_RETURN_FOR,
    handle_sentinel_boolean_for => \@_GTK_HANDLE_SENTINEL_BOOLEAN_FOR);

  Glib::Object::Introspection->setup (
    basename => $_GDK_BASENAME,
    version => $_GDK_VERSION,
    package => $_GDK_PACKAGE);

  Glib::Object::Introspection->setup (
    basename => $_GDK_PIXBUF_BASENAME,
    version => $_GDK_PIXBUF_VERSION,
    package => $_GDK_PIXBUF_PACKAGE,
    flatten_array_ref_return_for => \@_GDK_PIXBUF_FLATTEN_ARRAY_REF_RETURN_FOR);

  Glib::Object::Introspection->setup (
    basename => $_PANGO_BASENAME,
    version => $_PANGO_VERSION,
    package => $_PANGO_PACKAGE);

  my $init = 0;
  my @unknown_args = ($class);
  foreach (@_) {
    if (/^-?init$/) {
      $init = 1;
    } else {
      push @unknown_args, $_;
    }
  }

  if ($init) {
    Gtk3::init ();
  }

  # call into Exporter for the unrecognized arguments; handles exporting and
  # version checking
  Gtk3->export_to_level (1, @unknown_args);
}

# - Overrides --------------------------------------------------------------- #

sub Gtk3::CHECK_VERSION {
  return not defined Gtk3::check_version(@_ == 4 ? @_[1..3] : @_);
}

sub Gtk3::check_version {
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'check_version',
                                       @_ == 4 ? @_[1..3] : @_);
}

sub Gtk3::init {
  my $rest = Glib::Object::Introspection->invoke (
               $_GTK_BASENAME, undef, 'init',
               [$0, @ARGV]);
  @ARGV = @{$rest}[1 .. $#$rest]; # remove $0
  return;
}

sub Gtk3::init_check {
  my ($success, $rest) = Glib::Object::Introspection->invoke (
                           $_GTK_BASENAME, undef, 'init_check',
                           [$0, @ARGV]);
  @ARGV = @{$rest}[1 .. $#$rest]; # remove $0
  return $success;
}

sub Gtk3::main {
  # Ignore any arguments passed in.
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'main');
}

sub Gtk3::main_quit {
  # Ignore any arguments passed in.
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'main_quit');
}

{
  my $global_about_dialog = undef;
  my $about_dialog_key = '__gtk3_about_dialog';

  sub Gtk3::show_about_dialog {
    # For backwards-compatibility, optionally accept and discard a class
    # argument.
    my $parent_or_class = shift;
    my $parent = defined $parent_or_class && $parent_or_class eq 'Gtk3'
               ? shift
               : $parent_or_class;
    my %props = @_;
    my $dialog = defined $parent
               ? $parent->{$about_dialog_key}
               : $global_about_dialog;

    if (!$dialog) {
      $dialog = Gtk3::AboutDialog->new;
      $dialog->signal_connect (delete_event => \&Gtk3::Widget::hide_on_delete);
      # FIXME: We can't actually do this fully correctly, because the license
      # and credits subdialogs are private.
      $dialog->signal_connect (response => \&Gtk3::Widget::hide);
      foreach my $prop (keys %props) {
        $dialog->set ($prop => $props{$prop});
      }
      if ($parent) {
        $dialog->set_modal (Glib::TRUE);
        $dialog->set_transient_for ($parent);
        $dialog->set_destroy_with_parent (Glib::TRUE);
        $parent->{$about_dialog_key} = $dialog;
      } else {
        $global_about_dialog = $dialog;
      }
    }

    $dialog->present;
  }
}

sub Gtk3::ActionGroup::add_actions {
  my ($self, $entries, $user_data) = @_;

  croak 'actions must be a reference to an array of action entries'
    unless (ref($entries) eq 'ARRAY');

  croak 'action array is empty'
    unless (@$entries);

  my $process = sub {
    my ($p) = @_;
    my ($name, $stock_id, $label, $accelerator, $tooltip, $callback);

    if (ref($p) eq 'ARRAY') {
      $name        = $p->[0];
      $stock_id    = $p->[1];
      $label       = $p->[2];
      $accelerator = $p->[3];
      $tooltip     = $p->[4];
      $callback    = $p->[5];
    } elsif (ref($p) eq 'HASH') {
      $name        = $p->{name};
      $stock_id    = $p->{stock_id};
      $label       = $p->{label};
      $accelerator = $p->{accelerator};
      $tooltip     = $p->{tooltip};
      $callback    = $p->{callback};
    } else {
      croak 'action entry must be a reference to a hash or an array';
    }

    if (defined($label)) {
      $label   = $self->translate_string($label);
    }
    if (defined($tooltip)) {
      $tooltip = $self->translate_string($tooltip);
    }

    my $action = Gtk3::Action->new ($name, $label, $tooltip, $stock_id);

    if ($callback) {
      $action->signal_connect ('activate', $callback, $user_data);
    }
    $self->add_action_with_accel ($action, $accelerator);
  };

  for my $e (@$entries) {
    $process->($e);
  }
}

sub Gtk3::ActionGroup::add_toggle_actions {
  my ($self, $entries, $user_data) = @_;

  croak 'entries must be a reference to an array of toggle action entries'
    unless (ref($entries) eq 'ARRAY');

  croak 'toggle action array is empty'
    unless (@$entries);

  my $process = sub {
    my ($p) = @_;
    my ($name, $stock_id, $label, $accelerator, $tooltip,
      $callback, $is_active);

    if (ref($p) eq 'ARRAY') {
      $name        = $p->[0];
      $stock_id    = $p->[1];
      $label       = $p->[2];
      $accelerator = $p->[3];
      $tooltip     = $p->[4];
      $callback    = $p->[5];
      $is_active   = $p->[6];
    } elsif (ref($p) eq 'HASH') {
      $name        = $p->{name};
      $stock_id    = $p->{stock_id};
      $label       = $p->{label};
      $accelerator = $p->{accelerator};
      $tooltip     = $p->{tooltip};
      $callback    = $p->{callback};
      $is_active   = $p->{is_active};
    } else {
      croak 'action entry must be a hash or an array';
    }

    if (defined($label)) {
      $label   = $self->translate_string($label);
    }
    if (defined($tooltip)) {
      $tooltip = $self->translate_string($tooltip);
    }

    my $action = Gtk3::ToggleAction->new (
      $name, $label, $tooltip, $stock_id);
    $action->set_active ($is_active);

    if ($callback) {
      $action->signal_connect ('activate', $callback, $user_data);
    }

    $self->add_action_with_accel ($action, $accelerator);
  };

  for my $e (@$entries) {
    $process->($e);
  }
}

sub Gtk3::ActionGroup::add_radio_actions {
  my ($self, $entries, $value, $on_change, $user_data) = @_;

  croak 'radio_action_entries must be a reference to '
    . 'an array of action entries'
    unless (ref($entries) eq 'ARRAY');

  croak 'radio action array is empty'
    unless (@$entries);

  my $first_action = undef;

  my $process = sub {
    my ($group, $p) = @_;
    my ($name, $stock_id, $label, $accelerator, $tooltip, $entry_value);

    if (ref($p) eq 'ARRAY') {
      $name        = $p->[0];
      $stock_id    = $p->[1];
      $label       = $p->[2];
      $accelerator = $p->[3];
      $tooltip     = $p->[4];
      $entry_value = $p->[5];
    } elsif (ref($p) eq 'HASH') {
      $name        = $p->{name};
      $stock_id    = $p->{stock_id};
      $label       = $p->{label};
      $accelerator = $p->{accelerator};
      $tooltip     = $p->{tooltip};
      $entry_value = $p->{value};
    } else {
      croak 'radio action entries neither hash nor array';
    }

    if (defined($label)) {
      $label   = $self->translate_string($label);
    }
    if (defined($tooltip)) {
      $tooltip = $self->translate_string($tooltip);
    }

    my $action = Gtk3::RadioAction->new (
      $name, $label, $tooltip, $stock_id, $entry_value);

    $action->join_group($group);

    if ($value == $entry_value) {
      $action->set_active(Glib::TRUE);
    }
    $self->add_action_with_accel($action, $accelerator);
    return $action;
  };

  for my $e (@$entries) {
    my $group = $process->($first_action, $e);
    if (!$first_action) {
      $first_action = $group;
    }
  }

  if ($first_action && $on_change) {
    $first_action->signal_connect ('changed', $on_change, $user_data);
  }
}

sub Gtk3::Builder::add_objects_from_file {
  my ($builder, $filename, @rest) = @_;
  my $ref = _rest_to_ref (\@rest);
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Builder', 'add_objects_from_file',
    $builder, $filename, $ref);
}

sub Gtk3::Builder::add_objects_from_string {
  my ($builder, $string, @rest) = @_;
  my $ref = _rest_to_ref (\@rest);
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Builder', 'add_objects_from_string',
    $builder, $string, length $string, $ref);
}

sub Gtk3::Builder::add_from_string {
  my ($builder, $string) = @_;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Builder', 'add_from_string',
    $builder, $string, length $string);
}

# Copied from Gtk2.pm
sub Gtk3::Builder::connect_signals {
  my $builder = shift;
  my $user_data = shift;

  my $do_connect = sub {
    my ($object,
        $signal_name,
        $user_data,
        $connect_object,
        $flags,
        $handler) = @_;
    my $func = ($flags & 'after') ? 'signal_connect_after' : 'signal_connect';
    # we get connect_object when we're supposed to call
    # signal_connect_object, which ensures that the data (an object)
    # lives as long as the signal is connected.  the bindings take
    # care of that for us in all cases, so we only have signal_connect.
    # if we get a connect_object, just use that instead of user_data.
    $object->$func($signal_name => $handler,
                   $connect_object ? $connect_object : $user_data);
  };

  # $builder->connect_signals ($user_data)
  # $builder->connect_signals ($user_data, $package)
  if ($#_ <= 0) {
    my $package = shift;
    $package = caller unless defined $package;

    $builder->connect_signals_full(sub {
      my ($builder,
          $object,
          $signal_name,
          $handler_name,
          $connect_object,
          $flags) = @_;

      no strict qw/refs/;

      my $handler = $handler_name;
      if (ref $package) {
        $handler = sub { $package->$handler_name(@_) };
      } else {
        if ($package && $handler !~ /::/) {
          $handler = $package.'::'.$handler_name;
        }
      }

      $do_connect->($object, $signal_name, $user_data, $connect_object,
                    $flags, $handler);
    });
  }

  # $builder->connect_signals ($user_data, %handlers)
  else {
    my %handlers = @_;

    $builder->connect_signals_full(sub {
      my ($builder,
          $object,
          $signal_name,
          $handler_name,
          $connect_object,
          $flags) = @_;

      return unless exists $handlers{$handler_name};

      $do_connect->($object, $signal_name, $user_data, $connect_object,
                    $flags, $handlers{$handler_name});
    });
  }
}

sub Gtk3::Button::new {
  my ($class, $label) = @_;
  if (defined $label) {
    return $class->new_with_mnemonic ($label);
  } else {
    return Glib::Object::Introspection->invoke (
      $_GTK_BASENAME, 'Button', 'new', @_);
  }
}

sub Gtk3::CheckMenuItem::new {
  my ($class, $mnemonic) = @_;
  if (defined $mnemonic) {
    return $class->new_with_mnemonic ($mnemonic);
  }
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'CheckMenuItem', 'new', @_);
}

sub Gtk3::HBox::new {
  my ($class, $homogeneous, $spacing) = @_;
  $homogeneous = 5 unless defined $homogeneous;
  $spacing = 0 unless defined $spacing;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'HBox', 'new', $class, $homogeneous, $spacing);
}

sub Gtk3::ImageMenuItem::new {
  my ($class, $mnemonic) = @_;
  if (defined $mnemonic) {
    return $class->new_with_mnemonic ($mnemonic);
  }
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'ImageMenuItem', 'new', @_);
}

sub Gtk3::ListStore::new {
  return _common_tree_model_new ('ListStore', @_);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::ListStore::get {
  return Gtk3::TreeModel::get (@_);
}

sub Gtk3::ListStore::set {
  return _common_tree_model_set ('ListStore', @_);
}

sub Gtk3::Menu::popup {
  my $self = shift;
  $self->popup_for_device (undef, @_);
}

sub Gtk3::Menu::popup_for_device {
  my ($menu, $device, $parent_menu_shell, $parent_menu_item, $func, $data, $button, $activate_time) = @_;
  my $real_func = $func ? sub {
    my @stuff = eval { $func->(@_) };
    if ($@) {
      warn "*** menu position callback ignoring error: $@";
    }
    if (@stuff == 3) {
      return (@stuff);
    } elsif (@stuff == 2) {
      return (@stuff, Glib::FALSE); # provide a default for push_in
    } else {
      warn "*** menu position callback must return two integers " .
           "(x, y) or two integers and a boolean (x, y, push_in)";
      return (0, 0, Glib::FALSE);
    }
  } : undef;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Menu', 'popup_for_device',
    $menu, $device, $parent_menu_shell, $parent_menu_item, $real_func, $data, $button, $activate_time);
}

sub Gtk3::MenuItem::new {
  my ($class, $mnemonic) = @_;
  if (defined $mnemonic) {
    return $class->new_with_mnemonic ($mnemonic);
  }
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'MenuItem', 'new', @_);
}

sub Gtk3::MessageDialog::new {
  my ($class, $parent, $flags, $type, $buttons, $format, @args) = @_;
  my $dialog = Glib::Object::new ($class, message_type => $type,
                                          buttons => $buttons);
  if (defined $format) {
    # sprintf can handle empty @args
    my $msg = sprintf $format, @args;
    $dialog->set (text => $msg);
  }
  if (defined $parent) {
    $dialog->set_transient_for ($parent);
  }
  if ($flags & 'modal') {
    $dialog->set_modal (Glib::TRUE);
  }
  if ($flags & 'destroy-with-parent') {
    $dialog->set_destroy_with_parent (Glib::TRUE);
  }
  return $dialog;
}

sub Gtk3::TreeModel::get {
  my ($model, $iter, @columns) = @_;
  my @values = map { $model->get_value ($iter, $_) } @columns;
  return @values[0..$#values];
}

# Not needed anymore once <https://bugzilla.gnome.org/show_bug.cgi?id=646742>
# is fixed.
sub Gtk3::TreeModelFilter::new {
  my ($class, $child_model, $root) = @_;
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreeModel', 'filter_new', $child_model, $root);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::TreeModelFilter::get {
  return Gtk3::TreeModel::get (@_);
}

# Not needed anymore once <https://bugzilla.gnome.org/show_bug.cgi?id=646742>
# is fixed.
sub Gtk3::TreeModelSort::new_with_model {
  my ($class, $child_model) = @_;
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreeModel', 'sort_new_with_model', $child_model);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::TreeModelSort::get {
  return Gtk3::TreeModel::get (@_);
}

sub Gtk3::TreePath::new {
  my ($class, @args) = @_;
  my $method = (@args == 1) ? 'new_from_string' : 'new';
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreePath', $method, @_);
}

sub Gtk3::TreePath::new_from_indices {
  my ($class, @indices) = @_;
  my $path = Gtk3::TreePath->new;
  foreach (@indices) {
    $path->append_index ($_);
  }
  return $path;
}

sub Gtk3::TreeStore::new {
  return _common_tree_model_new ('TreeStore', @_);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::TreeStore::get {
  return Gtk3::TreeModel::get (@_);
}

sub Gtk3::TreeStore::set {
  return _common_tree_model_set ('TreeStore', @_);
}

sub Gtk3::TreeView::new {
  my ($class, @args) = @_;
  my $method = (@args == 1) ? 'new_with_model' : 'new';
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreeView', $method, @_);
}

sub Gtk3::TreeViewColumn::new_with_attributes {
  my ($class, $title, $cell, %attr_to_column) = @_;
  my $object = $class->new;
  $object->set_title ($title);
  $object->pack_start ($cell, Glib::TRUE);
  foreach my $attr (keys %attr_to_column) {
    $object->add_attribute ($cell, $attr, $attr_to_column{$attr});
  }
  return $object;
}

sub Gtk3::VBox::new {
  my ($class, $homogeneous, $spacing) = @_;
  $homogeneous = 5 unless defined $homogeneous;
  $spacing = 0 unless defined $spacing;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'VBox', 'new', $class, $homogeneous, $spacing);
}

sub Gtk3::Window::new {
  my ($class, $type) = @_;
  $type = 'toplevel' unless defined $type;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Window', 'new', $class, $type);
}

# Gdk

sub Gtk3::Gdk::Window::new {
  my ($class, $parent, $attr, $attr_mask) = @_;
  if (not defined $attr_mask) {
    $attr_mask = Gtk3::Gdk::WindowAttributesType->new ([]);
    if (exists $attr->{title}) { $attr_mask |= 'GDK_WA_TITLE' };
    if (exists $attr->{x}) { $attr_mask |= 'GDK_WA_X' };
    if (exists $attr->{y}) { $attr_mask |= 'GDK_WA_Y' };
    if (exists $attr->{cursor}) { $attr_mask |= 'GDK_WA_CURSOR' };
    if (exists $attr->{visual}) { $attr_mask |= 'GDK_WA_VISUAL' };
    if (exists $attr->{wmclass_name} && exists $attr->{wmclass_class}) { $attr_mask |= 'GDK_WA_WMCLASS' };
    if (exists $attr->{override_redirect}) { $attr_mask |= 'GDK_WA_NOREDIR' };
    if (exists $attr->{type_hint}) { $attr_mask |= 'GDK_WA_TYPE_HINT' };
  }
  return Glib::Object::Introspection->invoke (
    $_GDK_BASENAME, 'Window', 'new',
    $class, $parent, $attr, $attr_mask);
}

# GdkPixbuf

sub Gtk3::Gdk::Pixbuf::get_pixels {
  my $pixel_aref = Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'get_pixels', @_);
  return pack 'C*', @{$pixel_aref};
}

sub Gtk3::Gdk::Pixbuf::new_from_data {
  my ($class, $data, $colorspace, $has_alpha, $bits_per_sample, $width, $height, $rowstride) = @_;
  # FIXME: do we need to keep $real_data alive and then release it in a destroy
  # notify callback?
  my $real_data;
  {
    local $@;
    $real_data = (eval { @{$data} })
               ? $data
               : [unpack 'C*', $data];
  }
  return Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'new_from_data',
    $class, $real_data, $colorspace, $has_alpha, $bits_per_sample, $width, $height, $rowstride,
    undef, undef);
}

sub Gtk3::Gdk::Pixbuf::new_from_inline {
  my ($class, $data, $copy_pixels) = @_;
  $copy_pixels = Glib::TRUE unless defined $copy_pixels;
  my $real_data;
  {
    local $@;
    $real_data = (eval { @{$data} })
               ? $data
               : [unpack 'C*', $data];
  }
  return Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'new_from_inline',
    $class, $real_data, $copy_pixels);
}

sub Gtk3::Gdk::Pixbuf::new_from_xpm_data {
  my ($class, @data) = @_;
  my $real_data;
  {
    local $@;
    $real_data = (@data == 1 && eval { @{$data[0]} })
               ? $data[0]
               : \@data;
  }
  return Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'new_from_xpm_data',
    $class, $real_data);
}

sub Gtk3::Gdk::Pixbuf::save {
  my ($pixbuf, $filename, $type, @rest) = @_;
  my ($keys, $values) = _unpack_columns_and_values (\@rest);
  if (not defined $keys) {
    croak ('Usage: $pixbuf->save ($filename, $type, \@keys, \@values)',
           ' -or-: $pixbuf->save ($filename, $type, $key1 => $value1, ...)');
  }
  Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'save',
    $pixbuf, $filename, $type, $keys, $values);
}

sub Gtk3::Gdk::Pixbuf::save_to_buffer {
  my ($pixbuf, $type, @rest) = @_;
  my ($keys, $values) = _unpack_columns_and_values (\@rest);
  if (not defined $keys) {
    croak ('Usage: $pixbuf->save_to_buffer ($type, \@keys, \@values)',
           ' -or-: $pixbuf->save_to_buffer ($type, $key1 => $value1, ...)');
  }
  my (undef, $buffer) =
    Glib::Object::Introspection->invoke (
      $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'save_to_buffer',
      $pixbuf, $type, $keys, $values);
  return $buffer;
}

sub Gtk3::Gdk::Pixbuf::save_to_callback {
  my ($pixbuf, $save_func, $user_data, $type, @rest) = @_;
  my ($keys, $values) = _unpack_columns_and_values (\@rest);
  if (not defined $keys) {
    croak ('Usage: $pixbuf->save_to_callback ($save_func, $user_data, $type, \@keys, \@values)',
           ' -or-: $pixbuf->save_to_callback ($save_func, $user_data, $type, $key1 => $value1, ...)');
  }
  Glib::Object::Introspection->invoke (
    $_GDK_PIXBUF_BASENAME, 'Pixbuf', 'save_to_callback',
    $pixbuf, $save_func, $user_data, $type, $keys, $values);
}

# - Helpers ----------------------------------------------------------------- #

sub _common_tree_model_new {
  my ($package, $class, @types) = @_;
  my $real_types;
  {
    local $@;
    $real_types = (@types == 1 && eval { @{$types[0]} })
                ? $types[0]
                : \@types;
  }
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, $package, 'new',
    $class, $real_types);
}

sub _common_tree_model_set {
  my ($package, $model, $iter, @columns_and_values) = @_;
  my ($columns, $values) = _unpack_columns_and_values (\@columns_and_values);
  if (not defined $columns) {
    croak ('Usage: Gtk3::${package}::set ($store, \@columns, \@values)',
           ' -or-: Gtk3::${package}::set ($store, $column1 => $value1, ...)');
  }
  my @wrapped_values = ();
  foreach my $i (0..$#{$columns}) {
    my $column_type = $model->get_column_type ($columns->[$i]);
    push @wrapped_values,
         Glib::Object::Introspection::GValueWrapper->new (
           $column_type, $values->[$i]);
  }
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, $package, 'set',
    $model, $iter, $columns, \@wrapped_values);
}

sub _unpack_columns_and_values {
  my ($columns_and_values) = @_;
  my (@columns, @values);
  my $have_array_refs;
  {
    local $@;
    $have_array_refs =
      @$columns_and_values == 2 && eval { @{$columns_and_values->[0]} };
  }
  if ($have_array_refs) {
    @columns = @{$columns_and_values->[0]};
    @values = @{$columns_and_values->[1]};
  } elsif (@$columns_and_values % 2 == 0) {
    my %cols_to_vals = @$columns_and_values;
    @columns = keys %cols_to_vals;
    @values = values %cols_to_vals;
  } else {
    return ();
  }
  return (\@columns, \@values);
}

sub _rest_to_ref {
  my ($rest) = @_;
  local $@;
  if (scalar @$rest == 1 && eval { defined $rest->[0]->[0] }) {
    return $rest->[0];
  } else {
    return $rest;
  }
}

1;

__END__

# - Docs -------------------------------------------------------------------- #

=head1 NAME

Gtk3 - Perl interface to the 3.x series of the gtk+ toolkit

=head1 SYNOPSIS

  use Gtk3 -init;
  my $window = Gtk3::Window->new ('toplevel');
  my $button = Gtk3::Button->new ('Quit');
  $button->signal_connect (clicked => sub { Gtk3::main_quit });
  $window->add ($button);
  $window->show_all;
  Gtk3::main;

=head1 ABSTRACT

Perl bindings to the 3.x series of the gtk+ toolkit.  This module allows you to
write graphical user interfaces in a Perlish and object-oriented way, freeing
you from the casting and memory management in C, yet remaining very close in
spirit to original API.

=head1 DESCRIPTION

The Gtk3 module allows a Perl developer to use the gtk+ graphical user
interface library.  Find out more about gtk+ at L<http://www.gtk.org>.

The gtk+ reference manual is also a handy companion when writing Gtk3 programs
in Perl: L<http://developer.gnome.org/gtk3/stable/>.  The Perl bindings follow
the C API very closely, and the C reference documentation should be considered
the canonical source.

To discuss Gtk3 and ask questions join gtk-perl-list@gnome.org at
L<http://mail.gnome.org/mailman/listinfo/gtk-perl-list>.

Also have a look at the gtk2-perl website and sourceforge project page,
L<http://gtk2-perl.sourceforge.net>.

=head2 Porting from Gtk2 to Gtk3

The majority of the API has not changed, so as a first approximation you can
run C<< s/Gtk2/Gtk3/ >> on your application.  A big exception to this rule is
APIs that were deprecated in gtk+ 2.x -- these were all removed from gtk+ 3.0
and thus from L<Gtk3>.  The migration guide at
L<http://developer.gnome.org/gtk3/stable/migrating.html> describes what to use
instead.  Apart from this, here is a list of some other incompatible
differences between L<Gtk2> and L<Gtk3>:

=over

=item * The call syntax for class-static methods is now always
C<< Gtk3::Stock::lookup >> instead of C<< Gtk3::Stock->lookup >>.

=item * The %Gtk2::Gdk::Keysyms hash is gone; instead of C<<
Gtk2::Gdk::Keysyms{XYZ} >>, use C<< Gtk3::Gdk::KEY_XYZ >>.

=item * The Gtk2::Pango compatibility wrapper was not carried over; simply use
the namespace "Pango" everywhere.  It gets set up automatically when loading
L<Gtk3>.

=item * The Gtk3::Menu menu position callback passed to popup() does not
receive x and y parameters anymore.

=back

Note also that Gtk3::CHECK_VERSION will always fail when passed 2.y.z, so if
you have any existing version checks in your code, you will most likely need to
remove them.

=head1 SEE ALSO

=over

=item L<Glib>

=item L<Glib::Object::Introspection>

=back

=head1 AUTHORS

=encoding utf8

=over

=item Torsten Schönfeld <kaffeetisch@gmx.de>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 by Torsten Schoenfeld <kaffeetisch@gmx.de>

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option) any
later version.

=cut
