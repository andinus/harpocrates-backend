use Cro::HTTP::Router;

use Harpocrates::Session;

#| routes contains all routes.
sub routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    route {
        post -> Harpocrates::Session $session, 'account', 'register' {

        }
    }
}
