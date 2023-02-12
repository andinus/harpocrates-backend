use Cro::HTTP::Router;

use NSEIndia;
use Harpocrates::Session;

#| trading-routes contains all trading related routes.
sub trading-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    #| place-buy-order places a buy order for a specific symbol,
    #| quantity, price.
    sub place-buy-order(
        Str $account-id, Str $symbol, Int $quantity, Rat() $price
    ) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        $connection.execute(
            'INSERT INTO orderbook.detail (account, symbol, type, quantity, price)
                 VALUES (?, ?, ?, ?, ?)',
            $account-id, $symbol, 'buy', $quantity, $price
        );
    }

    route {
        post -> LoggedIn $session, 'order', 'buy' {
            request-body -> (:$symbol!, :$quantity!, :$price!, *%) {
                place-buy-order($session.id, $symbol, $quantity, $price);
                shell "curl -d 'Buy order placed for $symbol ($quantity)' ntfy.sh/harpocrate_buy"
            }
        }
    }
}
