#!/usr/bin/perl -w

use strict;
use Frontier::Client;
use Nagios::Plugin;
use Nagios::Plugin::Getopt;
use Nagios::Plugin::Threshold;

my $plugin = Nagios::Plugin->new(shortname => "check_sipgate_balance");

my $options = Nagios::Plugin::Getopt->new(
    usage => "Usage: %s [OPTIONS]",
    version => "1.0.0",
);
$options->arg(
    spec => "critical|c=i",
    help => "Balance threshold for a critical warning",
    required => 0,
    default => 2,
);
$options->arg(
    spec => "warning|w=i",
    help => "Balance threshold for a warning",
    required => 0,
    default => 5,
);
$options->arg(
    spec => "username=s",
    help => "API username",
    required => 1
);
$options->arg(
    spec => "password=s",
    help => "API password",
    required => 1,
);
                                        
$options->getopts();

my $threshold = Nagios::Plugin::Threshold->set_thresholds(
    warning  => $options->warning . ":",
    critical => $options->critical . ":",
);

alarm $options->timeout;

my $url = sprintf("https://%s:%s\@samurai.sipgate.net/RPC2",
                  $options->username,
                  $options->password);
my $client = Frontier::Client->new(url => $url);

my $result = $client->call("samurai.BalanceGet");
my $balance =  $result->{'CurrentBalance'}->{'TotalIncludingVat'};

$plugin->add_perfdata(
    label => "balance",
    value => $balance,
    uom => $result->{'CurrentBalance'}->{'Currency'},
    threshold => $threshold,
);

$plugin->nagios_exit(
    return_code => $threshold->get_status($balance),
);
