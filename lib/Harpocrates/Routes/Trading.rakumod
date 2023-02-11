use Cro::HTTP::Router;

use NSEIndia;
use Harpocrates::Session;

#| trading-routes contains all trading related routes.
sub trading-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    my NSEIndia $nse = NSEIndia.new();

    route {
        get -> LoggedIn $session, 'bonds' {
            content 'application/json', $nse.bonds();
        }

        get -> LoggedIn $session, 'equity', Str $symbol {
             if $nse.validate-symbol($symbol) {
                content 'application/json', $nse.get-details($symbol);
            } else {
                response.status = 404;
            }
        }
    }
}
