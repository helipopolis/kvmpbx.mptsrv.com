#!/usr/bin/perl -w
#aster_eventwatching_app
use strict;
use Getopt::Long;
use Sys::Syslog;
use EV;
use Asterisk::AMI;
use DBI;
use POSIX;


my $app = bless {
    host => '10.0.0.252',
    user => 'admin',
    secret => 'asterisk',
    dbhost => 'localhost',
    dbuser => 'asterisk',
    dbsecret => 'asterisk'
};

GetOptions(
    $app,
    'host=s',
    'user=s',
    'secret=s',
    'dbhost=s',
    'dbuser=s',
    'dbsecret=s'
);

$app->init;
$app->run;

sub init {
    my ($app) = @_;

    openlog($0, 'pid', 'user');
    syslog("info", "Starting up");
    $SIG{TERM} = sub {
        $app->{should_stop} = 1;
    };
}

sub run {
    my ($app) = @_;
    our $dbh = DBI->connect("DBI:mysql:database=;host=$app->{dbhost}",
                         $app->{dbuser},$app->{dbsecret},
                         {'RaiseError' => 1});
    my $astman = Asterisk::AMI->new(PeerAddr => $app->{host},
                                PeerPort => '5038',
                                Username => $app->{user},
                                Secret => $app->{secret},
                                Events => 'on',
                                Handlers => { default => \&eventhandler },
                                Keepalive => 60, #Send a keepalive every minute
                                on_error => sub { syslog("info","Error occured on socket\r\n"); exit; },
                                on_disconnect => sub { syslog("info","Lost connection to asterisk \r\n"); exit;},
                                on_timeout => sub { syslog("info","Connection to asterisk timed out\r\n"); exit; }
                                ); 
    #Alternatively you can set Blocking => 0, and set an on_error sub to catch connection errors
    die "Unable to connect to asterisk" unless ($astman);
    $dbh->do("SET NAMES 'utf8'");
    $dbh->do("DELETE FROM asterisk.current_congestion;");
    #$dbh->do("UPDATE asterisk-realtime.endpoints SET status = 'Свободен' WHERE devicestate = 'Входящий' OR devicestate = 'Занят';");
    #$dbh->do("UPDATE asterisk-realtime.endpoints SET status = 'не доступен' WHERE peerstatus = 'не доступен' OR peerstatus = 'Не зарегистрирован';");
    my $colorindex = 0;
    sub eventhandler {
        my @colors = (0x3CB371,0x20B2AA,0x98FB98,0x00FF7F,0xADD8E6,0x00FF00,0xAFEEEE,0x00FA9A,0xADFF2F,0xFFFF00,0x00BFFF,0x00B2EE,0x87CEFF,0x7EC0EE,0xB0E2FF,0xFFEC8B,0xFFB5C5,0xFF6EB4,0xFF83FA,0xFFBBFF,0x00FFFF,0x7FFFD4);
        my ($ami, $event) = @_;
        #my $colorindex = 0;
        #syslog("info", "Получено событие: ".$event->{'Event'});
        if ($event->{'Event'} eq "ContactStatus") {
          my $peerstatus = "";
          $peerstatus = "Доступен" if ($event->{'ContactStatus'} eq "Reachable");
          $peerstatus = "Не зарегистрирован" if ($event->{'ContactStatus'} eq "Unregistered");
          $peerstatus = "не доступен" if ($event->{'ContactStatus'} eq "Unreachable");
          $peerstatus = "Занят" if ($event->{'ContactStatus'} eq "Busy");
          my $endpointname = $event->{'EndpointName'};
          #syslog("info", "PeerStatus: ".$event->{'PeerStatus'});
          #syslog("info", "Peer: ".$peer);
          #syslog("info", "Address: ".$event->{'Address'});
          my $query = "UPDATE `asterisk`.`ps_endpoints` SET status = \"".$peerstatus."\" WHERE id = \"".$endpointname."\"";
          #syslog("info", $event->{'ContactStatus'});
          if (defined($query)) {
                  #syslog("info", $query);
            $dbh->do($query);
          }
          if ($event->{'ContactStatus'} eq "Unreachable") {
            my $query2 = 'INSERT INTO asterisk.current_congestion  (bridgeuniqueid,callerid,name,color,datetime,channel) VALUES ("1000","Недоступен","'.$event->{'EndpointName'}.'","0xFF0000",UNIX_TIMESTAMP(),"'.$event->{'URI'}.'") ON DUPLICATE KEY UPDATE bridgeuniqueid = "1000"';
            if (defined($query2)) {
              #syslog("info", $query2);
              $dbh->do($query2); 
              }
          } elsif ($event->{'ContactStatus'} eq "Reachable") {
              my $query3 = 'DELETE FROM asterisk.current_congestion WHERE name = "'.$event->{'EndpointName'}.'" AND bridgeuniqueid = "1000"';
              if (defined($query3)) {
                      #syslog("info", $query3);
                $dbh->do($query3); 
             }
            }                                   
          } elsif ($event->{'Event'} eq "PeerStatus") {
          my $peerstatus = "";
          $peerstatus = "не доступен" if ($event->{'PeerStatus'} eq "Unreachable");
          my $endpointname = substr($event->{'Peer'},4);
          my $query = "UPDATE `asterisk-realtime`.`ps_endpoints` SET status = \"".$peerstatus."\" WHERE id = \"".$endpointname."\"";
        } elsif ($event->{'Event'} eq "BridgeEnter"){
        my $color;
        my $sth = $dbh->prepare("SELECT * FROM asterisk.current_congestion WHERE bridgeuniqueid = ?");
        $sth->execute($event->{'BridgeUniqueid'}) or die "Couldn't prepare statement: " . $dbh->errstr;
        my @data;
        if (@data = $sth->fetchrow_array()){
          $color = $data[4];
        } else {
          #$color = $colors[int(rand($#colors))];
          $color = $colors[$colorindex];
	  $colorindex++;
	  if ($colorindex>$#colors-1) {$colorindex = 0};
        }
        $sth->finish;
        my $name = $event->{'CallerIDName'};
        if ($name eq "<unknown>") {
           my $sth = $dbh->prepare("SELECT * FROM asterisk.addressbook_additional WHERE telnum = ?");
           $sth->execute($event->{'CallerIDNum'}) or die "Couldn't prepare statement: " . $dbh->errstr;
           my @data;
           if (@data = $sth->fetchrow_array()){
             $name = $data[1];
           }
        }
        my $query = 'INSERT INTO asterisk.current_congestion  (bridgeuniqueid,callerid,name,color,datetime,channel) VALUES ("'.$event->{'BridgeUniqueid'}.'","'.$name.'","'.$event->{'CallerIDNum'}.'","'.$color.'",UNIX_TIMESTAMP(),"'.$event->{'Channel'}.'")';
        if (defined($query)) {
                #syslog("info", $query);
          $dbh->do($query)  or die "Couldn't prepare statement: " . $dbh->errstr
        }
        } elsif ($event->{'Event'} eq "BridgeDestroy"){
          $dbh->do('DELETE FROM asterisk.current_congestion WHERE bridgeuniqueid = "'.$event->{'BridgeUniqueid'}.'"')  or die "Couldn't prepare statement: " . $dbh->errstr;
          #rint "$event->{'BridgeUniqueid'}\r\n";
        }elsif ($event->{'Event'} eq "BridgeLeave"){
          $dbh->do('DELETE FROM asterisk.current_congestion WHERE bridgeuniqueid = "'.$event->{'BridgeUniqueid'}.'" AND name = "'.$event->{'CallerIDNum'}.'"')  or die "Couldn't prepare statement: " . $dbh->errstr;
          #rint "$event->{'BridgeUniqueid'}\r\n";
        }elsif ($event->{'Event'} eq "ConfbridgeJoin"){
	  my $name = $event->{'CallerIDName'};
          if ($name eq "<unknown>") {
            my $sth = $dbh->prepare("SELECT * FROM asterisk.addressbook_additional WHERE telnum = ?");
            $sth->execute($event->{'CallerIDNum'}) or die "Couldn't prepare statement: " . $dbh->errstr;
            my @data;
            if (@data = $sth->fetchrow_array()){
            $name = $data[1];
           }
	  }
	  my $query = 'INSERT INTO asterisk.current_conf  (conference,callerid,name,datetime,channel) VALUES ("'.$event->{'Conference'}.'","'.$name.'","'.$event->{'CallerIDNum'}.'",NOW(),"'.$event->{'Channel'}.'")';
	  if (defined($query)) {
            #rint "$query\r\n";
            $dbh->do($query)  or die "Couldn't prepare statement: " . $dbh->errstr
	  }
	}elsif  ($event->{'Event'} eq "ConfbridgeLeave"){
	  $dbh->do('DELETE FROM asterisk.current_conf WHERE conference = "'.$event->{'Conference'}.'" AND name = "'.$event->{'CallerIDNum'}.'"')  or die "Couldn't prepare statement: " . $dbh->errstr;
	}elsif  ($event->{'Event'} eq "ConfbridgeTalking"){
	  my $status = $event->{'TalkingStatus'};
          if ($status eq "on") {
            $status = "Говорит"
	  }else 
	    {$status = "";
	    }
	  my $query = "UPDATE asterisk.current_conf SET Talking = \"".$status."\" WHERE channel = \"".$event->{'Channel'}."\"";
	  $dbh->do($query)  or die "Couldn't prepare statement: " . $dbh->errstr
	}
    }
    until ( $app->{should_stop} ) {EV::loop};
    syslog("info", "Shutting down");
    closelog();
}

