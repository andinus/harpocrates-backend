use Cro::HTTP::Router;
use Cro::HTTP::Client;

use DBIish::Transaction;
use Data::Dump::Tree;

use NSEIndia;
use Harpocrates::Session;

#| portfolio-routes contains all portfolio related routes.
sub portfolio-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    my NSEIndia $nse = NSEIndia.new();

    #| get-bonds returns all current bonds held by the user. We
    #| generate this by considering only the buy transactions of the
    #| user. Ideally we should consider the sell transactions and
    #| equity is sold in FIFO manner so we could ignore buy
    #| transactions after sorting them by date.
    sub get-bonds(Str $account-id --> List) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;
        # Get current market value of the bond to reflect % of
        # profits.
        my $sth = $connection.execute(
            'SELECT symbol, SUM(quantity) AS quantity, AVG(price) AS average_price
                 FROM users.transaction WHERE account = ? AND type = \'buy\'
                 GROUP BY symbol',
            $account-id
        );
        my @data = $sth.allrows(:array-of-hash);
        for @data.kv -> $k, $v {
            @data[$k]<current_price> = $nse.get-details($v<symbol>)<priceInfo><lastPrice>;
        }
        return @data;
    }

    route {
        get -> LoggedIn $session, 'bonds' {
            content 'application/json', get-bonds($session.id);
        }
    }
}
