use Cro::HTTP::Router;

use Harpocrates::Session;
use Harpocrates::Routes::Account;
use Harpocrates::Routes::Trading;

#| routes contains all routes.
sub routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    route {
        get -> 'ping' {
            content 'text/plain', "pong";
        }

        include account => account-routes(%config, $pool);
        include trading => trading-routes(%config, $pool);
    }
}
