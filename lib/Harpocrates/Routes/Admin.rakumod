use Cro::HTTP::Router;
use Cro::HTTP::Client;

use MIME::Base64;
use DBIish::Transaction;

use Harpocrates::Session;

#| admin-routes contains all admin related routes.
sub admin-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    my IO $image-dir = %*ENV<HOME>.IO.add(%config<cryfs><dir>);

    #| get-unverified-kyc returns all unverified kyc records.
    sub get-unverified-kyc() {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        my $sth = $connection.execute(
            'SELECT id, account, symbol, quantity, price, created
                 FROM users.verification
                 WHERE account IN (SELECT id FROM users.account
                                   WHERE kyc_verified = FALSE AND kyc_uploaded = TRUE);',
        );
        return $sth.allrows(:array-of-hash);
    }

    route {
        get -> AdminLoggedIn $session, 'unverified-kyc' {
            content 'application/json', get-unverified-kyc();
        }
    }
}
