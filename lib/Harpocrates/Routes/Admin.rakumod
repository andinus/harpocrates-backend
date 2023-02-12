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
            'SELECT uk.created, uk.type, uk.id, uk.image, ua.email
                 FROM users.kyc uk JOIN users.account ua ON ua.id = uk.account
                 WHERE ua.kyc_verified = FALSE AND ua.kyc_uploaded = TRUE
                 AND uk.type = \'aadhar\';',
        );
        return $sth.allrows(:array-of-hash).eager;
    }

    #| verify-kyc marks user kyc as verified.
    sub verify-kyc(Str $email) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        $connection.execute(
            'UPDATE users.account SET kyc_verified = TRUE WHERE email = ?', $email
        );
    }

    route {
        get -> AdminLoggedIn $session, 'unverified-kyc' {
            content 'application/json', get-unverified-kyc();
        }

        # image is a uuid that is randomly generated so we allow
        # admins to view user's KYC.
        get -> AdminLoggedIn $session, 'unverified-kyc', $image {
            static $image-dir.add($image);
        }

        get -> AdminLoggedIn $session, 'kyc', 'verify', $email {
            verify-kyc($email);
        }
    }
}
