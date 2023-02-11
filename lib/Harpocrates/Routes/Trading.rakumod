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
        get -> 'bonds' {
            content 'application/json', $nse.bonds();
        }
    }
}
