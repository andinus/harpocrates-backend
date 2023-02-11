use Cro::HTTP::Router;
use Cro::HTTP::Client;

use HTML::Escape;
use Email::Valid;
use DBIish::Transaction;
use Crypt::SodiumPasswordHash;

use Harpocrates::Session;

#| account-routes contains all account related routes.
sub account-routes(
    %config, #= config contains config options
    $pool, #= get DBIish::Pool
) is export {
    my $email-validate = Email::Valid.new(:simple);
    my $email-client = Cro::HTTP::Client.new(
        auth => { username => "api", password => %config<email><api-key> },
    );

    #| generate-token returns a random token.
    sub generate-token(--> Str) {
        return (|('a'..'z'), |(1..9), |('A'..'Z')).roll(72).join;
    }

    #| create-user-account takes email, contact, password and creates a
    #| user account and also generates a verification token, sends
    #| verification email.
    sub create-user-account(Str $email, Str $contact, Str $password --> Str) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        my $t = DBIish::Transaction.new(:$connection, :retry);

        # Random verification token.
        my Str $token;

        $t.in-transaction: -> $dbh {
            my $account = $dbh.execute(
                'INSERT INTO users.account (email, contact, password) VALUES (?, ?, ?)
                     RETURNING id;',
                $email, $contact, sodium-hash($password)
            );

            # Save token to database.
            my $sth = $dbh.execute(
                'INSERT INTO users.verification (account) VALUES (?) RETURNING token;',
                $account.row(:hash)<id>
            );
            $token = $sth.row(:hash)<token>;
        }
        return $token;
    }

    #| get-user takes email returns password, id, verified columns for
    #| the user.
    sub get-user(Str $email --> Hash) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        my $sth = $connection.execute(
            'SELECT id, password, verified FROM users.account WHERE email = ?;',
            $email
        );
        return $sth.row(:hash);
    }

    #| send-verification-email takes email, token and sents the user a
    #| verification email with the token.
    sub send-verification-email(Str $email, Str $token) {
        await $email-client.post: (%config<email><api-url> ~ '/messages'),
                   content-type => 'application/x-www-form-urlencoded',
                   body => [
                            from => %config<email><user>,
                            to => "ysmta.harpo@inbox.testmail.app",
                            subject => "[Harpocrates] Verify account",
                            text => "Thank you for registering. Please verify your email to continue: https://harpocrates.unfla.me/account/verify?token={$token}"
                        ];
        CATCH {
            when X::Cro::HTTP::Error { put "Unexpected error: $_"; }
        }
    }

    #| verify-token takes a token string and verifies the user account
    #| associated with that token. Returns true on successful
    #| verification.
    sub verify-token(Str $token --> Bool) {
        my $connection = $pool.get-connection();
        LEAVE .dispose with $connection;

        my Bool $verified;
        my $t = DBIish::Transaction.new(:$connection, :retry);
        $t.in-transaction: -> $dbh {
            my $sth = $dbh.execute(
                'DELETE FROM users.verification
                     WHERE token = ? AND created > (now() - interval \'15 minutes\')
                     RETURNING account;',
                $token
            );

            $verified = $sth.rows != 0; # Number of affected rows.

            # If user was verified then add timestamp.
            $dbh.execute(
                'UPDATE users.account SET verified = ? WHERE id = ?;',
                DateTime.now, $sth.row(:hash)<account>
            ) if $verified;
        }

        return $verified;
    }

    route {
        get -> 'verify', Str :$token! {
            my %res;
            if verify-token($token) {
                %res<message> = "Email verified."
            } else {
                response.status = 400;
                %res<message> = "Invalid token, Email not verified."
            }
            content 'application/json', %res;
        }

        get -> NotLoggedIn $session, 'profile' {
            response.status = 401;
        }
        get -> LoggedIn $session, 'profile' {
            content 'application/json', %(email => $session.email);
        }

        post -> Harpocrates::Session $session, 'login' {
            request-body -> (:$email!, :$password!, *%) {
                my %res;
                my %user = get-user($email);
                # Only verified users will be able to login.
                if %user<id>.defined && sodium-verify(%user<password>, $password) {
                    $session.email = $email;

                    # Set user-id only if the user account is
                    # verified.
                    if %user<verified>.defined {
                        $session.verified = True;
                        $session.id = %user<id>;
                        response.status = 204;
                    } else {
                        response.status = 401;
                        %res<message> = "Verify your account to continue.";
                    }
                } else {
                    response.status = 401;
                    %res<message> = "Invalid Credentials";
                }

                content 'application/json', %res;
            }
        }

        post -> Harpocrates::Session $session, 'register' {
            request-body -> (:$email!, :$contact!, :$password!, *%) {
                # res holds the response that is sent.
                my %res;
                %res<errors>.push("Password too short.") unless $password.chars > 6;
                %res<errors>.push("Invalid Email.") unless $email-validate.validate($email);

                with %res<errors> {
                    response.status = 400;
                } else {
                    my Str $token = create-user-account($email, $contact, $password);

                    try {
                        start send-verification-email($email, $token);
                        CATCH {
                            default {
                                warn "[!!!] [send-verification-email]: $email" ~ $_.raku;
                            }
                        }
                    }

                    %res<message> = "We're sending you a verification email, verify the account to continue.";
                }

                content 'application/json', %res;
                CATCH {
                    when X::DBDish::DBError {
                        if (.source-function eq "_bt_check_unique"
                            && .constraint eq "account_email_key") {
                            response.status = 400;
                            content 'application/json', %(message => "Account already exists.");
                        } else {
                            die $_;
                        }
                    }
                }
            }
        }

        get -> LoggedIn $session, 'logout' {
            $session.id = Nil;
            response.status = 204;
        }
        get -> NotLoggedIn $session, 'logout' {
            response.status = 401;
            content 'application/json', %(message => "Not logged in to any account.")
        }
    }
}
