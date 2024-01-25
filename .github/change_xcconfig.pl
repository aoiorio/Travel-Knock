use YAML;

open my $yaml_file, '<', './pubspec.yaml' or die "Cannot open file: $!";
my $data = YAML::LoadFile($yaml_file);
close $yaml_file;

my $version = substr($data->{version}, 0, -2);

open my $xcconfig_file, '<', "./ios/Flutter/Generated.xcconfig.orig" or die "Cannot open file: $!";
my @envs = <$xcconfig_file>;
close $xcconfig_file;

foreach my $env (@envs) {
    my ($key, $value) = split(/=/, $env, 2);
    if ($key eq "FLUTTER_BUILD_NAME") {
        $value = $version;
        $env = "$key=$value\n";
    }
}

open $xcconfig_file, '>', "./ios/Flutter/Generated.xcconfig" or die "Cannot open file: $!";
print $xcconfig_file @envs;
close $xcconfig_file;
