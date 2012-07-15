#!/usr/bin/perl

# Calendar
#
# This is an example of a GtkCalendar.
#
# Perl version by Dave M <dave.nerd@gmail.com>

use strict;
use warnings;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

use constant DEF_PAD       => 10;
use constant DEF_PAD_SMALL => 5;
use constant TM_YEAR_BASE  => 1900;

do_calendar();
Gtk3->main();

sub calendar_select_font {
    my ( $calendar, $window ) = @_;

    my $fsd =
        Gtk3::FontChooserDialog->new( 'Font Selection Dialog', $window );
    $fsd->set_position('mouse');

    my $response = $fsd->run;
    my $new_font = $fsd->get_font;
    warn "selected >$new_font<\n";
    $fsd->destroy;
    return unless defined $new_font;

    # Not sure if this really works or not...
    $calendar->modify_font( Pango::FontDescription->from_string($new_font) );
}

sub calendar_set_signal_strings {
    my ( $sig_ref, $new_sig ) = @_;

    $sig_ref->{prev2}->set_text( $sig_ref->{prev}->get_text );
    $sig_ref->{prev}->set_text( $sig_ref->{curr}->get_text );
    $sig_ref->{curr}->set_text($new_sig);
}

sub do_calendar {
    my $window = Gtk3::Window->new('toplevel');
    $window->set_title('GtkCalendar demo');
    $window->signal_connect( destroy => sub { Gtk3->main_quit } );
    $window->set_resizable(FALSE);

    my $icon = 'gtk-logo-rgb.gif';
    if ( -e $icon ) {
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
        my $transparent = $pixbuf->add_alpha( TRUE, 0xff, 0xff, 0xff );
        $window->set_icon($transparent);
    }

    my %signals;

    # This VBox will be handy to organize objects
    my $vbox = Gtk3::Box->new( 'vertical', DEF_PAD );
    $window->add($vbox);

    # The top part of the window, Calendar, flags, and fontsel
    my $hbox = Gtk3::Box->new( 'horizontal', DEF_PAD );
    $vbox->pack_start( $hbox, TRUE, TRUE, DEF_PAD );

    my $hbbox = Gtk3::ButtonBox->new('horizontal');
    $hbox->pack_start( $hbbox, FALSE, FALSE, DEF_PAD );
    $hbbox->set_layout('spread');
    $hbbox->set_spacing(5);

    # Calendar widget
    my $frame = Gtk3::Frame->new('Calendar');
    $hbbox->pack_start( $frame, FALSE, FALSE, DEF_PAD );

    my $calendar = Gtk3::Calendar->new;
    my ( $year, $month, $day ) = $calendar->get_date;
    $calendar->mark_day($day);
    $frame->add($calendar);
    $calendar->set_display_options( [] );

    $calendar->signal_connect(
        'month_changed' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'month changed: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'day_selected' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'day selected: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'day_selected_double_click' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'day selected double click: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'prev_month' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'prev month: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'next_month' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'next month: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'prev_year' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'prev year: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );
    $calendar->signal_connect(
        'next_year' => sub {
            my ( $year, $month, $day ) = $calendar->get_date;
            calendar_set_signal_strings( $_[1],
                'next year: '
                    . sprintf( "%02d/%d/%d", $month + 1, $day, $year ) );
        },
        \%signals
        );

    $hbox->pack_start( Gtk3::Separator->new('vertical'), FALSE, TRUE, 0 );

    my $vbox2 = Gtk3::Box->new( 'vertical', DEF_PAD );
    $hbox->pack_start( $vbox2, FALSE, FALSE, DEF_PAD );

    # Build the Right frame with the flags in
    $frame = Gtk3::Frame->new('Flags');
    $vbox2->pack_start( $frame, TRUE, TRUE, DEF_PAD );
    my $vbox3 = Gtk3::Box->new( 'vertical', DEF_PAD_SMALL );
    $frame->add($vbox3);

# show-heading / GTK_CALENDAR_SHOW_HEADING, show-day-names / GTK_CALENDAR_SHOW_DAY_NAMES, no-month-change / GTK_CALENDAR_NO_MONTH_CHANGE, show-week-numbers / GTK_CALENDAR_SHOW_WEEK_NUMBERS, show-details / GTK_CALENDAR_SHOW_DETAILS

    my @flags = (
        'Show Heading',
        'Show Day Names',
        'No Month Change',
        'Show Week Numbers',
        #'Week Start Monday',
        'Show Details',
        );

    my @toggles;

    for ( my $i = 0; $i < 5; $i++ ) {
        $toggles[$i] = Gtk3::CheckButton->new_with_label( $flags[$i] );
        $toggles[$i]->signal_connect(
            'toggled' => sub {
                my $j;
                my $opts = [];
                for ( $j = 0; $j < scalar(@flags); $j++ ) {
                    if ( $toggles[$j]->get_active ) {
                        push @$opts, $flags[$j];
                    }
                }
                $calendar->set_display_options($opts);
            } );
        $vbox3->pack_start( $toggles[$i], TRUE, TRUE, 0 );
    }
    foreach (@flags) {
        $_ =~ s/\s/-/g;
        $_ = lc($_);
    }

    # Build the right font button
    my $button = Gtk3::Button->new('Font...');
    $button->signal_connect(
        clicked => sub {
            calendar_select_font( $_[1], $window );
        },
        $calendar
        );
    $vbox2->pack_start( $button, FALSE, FALSE, 0 );

    # Build the signal-event part
    $frame = Gtk3::Frame->new('Signal events');
    $vbox->pack_start( $frame, TRUE, TRUE, DEF_PAD );

    $vbox2 = Gtk3::Box->new( 'vertical', DEF_PAD_SMALL );
    $vbox2->set_homogeneous(TRUE);
    $frame->add($vbox2);

    $hbox = Gtk3::Box->new( 'horizontal', 3 );
    $vbox2->pack_start( $hbox, FALSE, TRUE, 0 );
    my $label = Gtk3::Label->new('Signal:');
    $hbox->pack_start( $label, FALSE, TRUE, 0 );
    $signals{curr} = Gtk3::Label->new('');
    $hbox->pack_start( $signals{curr}, FALSE, TRUE, 0 );

    $hbox = Gtk3::Box->new( 'horizontal', 3 );
    $vbox2->pack_start( $hbox, FALSE, TRUE, 0 );
    $label = Gtk3::Label->new('Previous Signal:');
    $hbox->pack_start( $label, FALSE, TRUE, 0 );
    $signals{prev} = Gtk3::Label->new('');
    $hbox->pack_start( $signals{prev}, FALSE, TRUE, 0 );

    $hbox = Gtk3::Box->new( 'horizontal', 3 );
    $vbox2->pack_start( $hbox, FALSE, TRUE, 0 );
    $label = Gtk3::Label->new('Second Previous Signal:');
    $hbox->pack_start( $label, FALSE, TRUE, 0 );
    $signals{prev2} = Gtk3::Label->new('');
    $hbox->pack_start( $signals{prev2}, FALSE, TRUE, 0 );

    my $bbox = Gtk3::ButtonBox->new('horizontal');
    $vbox->pack_start( $bbox, FALSE, FALSE, 0 );
    $bbox->set_layout('end');

    $button = Gtk3::Button->new('Close');
    $button->signal_connect(
        'clicked' => sub {
            Gtk3->main_quit;
        } );
    $bbox->add($button);

    $window->show_all;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
