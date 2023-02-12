use Cro::HTTP::Router;

use Harpocrates::Session;
use Harpocrates::Routes::NSE;
use Harpocrates::Routes::Admin;
use Harpocrates::Routes::Account;
use Harpocrates::Routes::Trading;
use Harpocrates::Routes::Portfolio;

#| routes contains all routes.
sub routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    route {
        get -> 'ping' {
            content 'text/plain', "pong";
        }
        get -> 'life' {
            response.status = 404;
        }

        include nse => nse-routes(%config, $pool);

        include admin => admin-routes(%config, $pool);
        include account => account-routes(%config, $pool);
        include trading => trading-routes(%config, $pool);
        include portfolio => portfolio-routes(%config, $pool);
    }
}
