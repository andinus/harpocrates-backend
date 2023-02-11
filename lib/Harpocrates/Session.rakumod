use Cro::HTTP::Auth;

class Harpocrates::Session does Cro::HTTP::Auth {
    has Str $.id is rw;
    has Str $.email is rw;
    has Bool $.verified is rw;

    #| logged-in returns true if the user is logged in and the account
    #| is verified.
    method logged-in(--> Bool) {
        return $!id.defined && $!verified;
    }

    #| logged-in-not-verified returns true if the user is logged in
    #| and the account is not verified.
    method logged-in-not-verified(--> Bool) {
        return $!email.defined && not $!verified;
    }
}

subset LoggedIn of Harpocrates::Session is export where *.logged-in;
subset LoggedInNotVerified of Harpocrates::Session is export where *.logged-in-not-verified;
subset NotLoggedIn of Harpocrates::Session is export where not *.id.defined;
