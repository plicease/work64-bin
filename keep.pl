use strict;
use warnings;
use AnyEvent;
use AnyEvent::Open3::Simple;

my $tlcf_last;
my $tlcf_pid;
my $tlcf = AnyEvent::Open3::Simple->new(
  on_start => sub {
    my($proc) = @_;
    $tlcf_pid = $proc->pid;
    $|=1;
    print '<<';
  },
  on_stdout => sub {
    $|=1;
    print '+';
    $tlcf_last = time;
  },
  on_exit => sub {
    start_tlcf();
  },
);

our $tlcf_timer = AnyEvent->timer(
  after => 15,
  interval => 5,
  cb => sub {
    my $since = time - $tlcf_last;
    $|=1;
    print '.';
    if($since > 60*3)
    {
      $|=1;
      print '/';
      kill 'KILL', $tlcf_pid;
    }
  }
);

sub start_tlcf
{
  $tlcf->run(qw( ssh worktunnel perl stay.pl ));
}


my $dare_last;
my $dare_pid;
my $dare = AnyEvent::Open3::Simple->new(
  on_start => sub {
    my($proc) = @_;
    $dare_pid = $proc->pid;
    $|=1;
    print '>>';
  },
  on_stdout => sub {
    $|=1;
    print '*';
    $dare_last = time;
  },
  on_exit => sub {
    start_dare();
  },
);

our $dare_timer = AnyEvent->timer(
  after => 15,
  interval => 5,
  cb => sub {
    my $since = time - $dare_last;
    $|=1;
    print '.';
    if($since > 60*3)
    {
      $|=1;
      print '\\';
      kill 'KILL', $dare_pid;
    }
  }
);

sub start_dare
{
  $dare->run(qw( ssh bartunnel perl stay.pl ));
}

start_dare();
start_tlcf();

AnyEvent->condvar->recv;
