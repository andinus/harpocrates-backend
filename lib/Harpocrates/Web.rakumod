use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Log::File;
use Cro::HTTP::Session::InMemory;

use Net::SMTP;
use DBIish::Pool;

use Harpocrates::Config;
use Harpocrates::Routes;
use Harpocrates::Trading;
use Harpocrates::Session;

sub MAIN() is export {
    my %config = config();

    my $pool = DBIish::Pool.new(
        driver => 'Pg',
        initial-size => 2,
        max-connections => 10,
        min-spare-connections => 2,
        max-idle-duration => Duration.new(60),
        |%(
            database => %config<database><name>,
            user => %config<database><user>,
            password => %config<database><pass>,
        )
    );

    # Settle orders every x seconds.
    start {
        loop {
            my Int $processed = settle-orders(%config, $pool);
            put "[settle-orders] {DateTime.now} {$processed} order(s) processed.";
            sleep %config<settle-sleep>;
        }
    }

    my Cro::Service $http = Cro::HTTP::Server.new(
        http => <1.1>,
        host => "127.0.0.1",
        port => 5400,
        application => routes(%config, $pool),
        before => [
                   Cro::HTTP::Session::InMemory[Harpocrates::Session].new(
                       expiration => Duration.new(60 * 15)
                   );
               ],
        after => [
                  Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
              ]
    );
    $http.start;
    put "Listening at http://127.0.0.1:5400";

    react {
        whenever signal(SIGINT) {
            say "Shutting down...";
            $http.stop;
            done;
        }
    }
}
