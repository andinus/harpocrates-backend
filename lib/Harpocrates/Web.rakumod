use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Log::File;
use Cro::HTTP::Session::InMemory;

use Net::SMTP;

use Harpocrates::Config;
use Harpocrates::Routes;

sub MAIN(Bool :$debug) {
    my Cro::Service $http = Cro::HTTP::Server.new(
        http => <1.1>,
        host => "127.0.0.1",
        port => "5400",
        application => routes(config()),
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
