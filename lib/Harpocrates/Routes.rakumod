use Cro::HTTP::Router;

use Harpocrates::Session;
use Harpocrates::Routes::Account;

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
    }
}
