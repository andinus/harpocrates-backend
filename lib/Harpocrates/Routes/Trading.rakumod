use Cro::HTTP::Router;

use NSEIndia;
use Harpocrates::Session;

#| trading-routes contains all trading related routes.
sub trading-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    route {
        get -> 'ping' {
            not-found;
        }
    }
}
