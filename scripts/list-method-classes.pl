#! /usr/bin/env perl

use strict;
use Data::Dumper;
use JSON;

# print four-column table: [class, method, workspace-types, widgets]

my $usage = "Usage: $0 path_to_narrative_method_specs\n\n";

my $path = shift @ARGV || "$ENV{HOME}/kbase/narrative_method_specs";

my @files = map { chomp; $_ } `ls $path/methods/*/spec.json`;

my %class_to_methods;
my %method_to_types;
my %method_to_widgets;

for (@files) {
    my $method = $_;
    $method = (m|methods/(\S+)/spec.json|, $1);
    my $spec = `cat $_`;
    $spec = decode_json($spec);
    my $class = $spec->{behavior}->{python_class};
    push @{$class_to_methods{$class}}, $method;
    for my $param (@{$spec->{parameters}}) {
        my $ws_types = $param->{text_options}->{valid_ws_types};
        push(@{$method_to_types{$method}}, @$ws_types) if $ws_types && @$ws_types;
    }
    for my $widget (values %{$spec->{widgets}}) {
        push @{$method_to_widgets{$method}}, $widget if $widget;
    }
}

for my $class (sort keys %class_to_methods) {
    my @methods = sort @{$class_to_methods{$class}};
    for my $method (@methods) {
        my $types = $method_to_types{$method};
        $types = join(",", @$types) if $types;
        my $widgets = $method_to_widgets{$method};
        $widgets = join(",", @$widgets) if $widgets;
        print join("\t", $class, $method, $types, $widgets) . "\n";
    }
}
