use Cro::HTTP::Client;
use Cro::HTTP::Client::CookieJar;

class NSEIndia is export {
    has Str $!base-url = "https://www.nseindia.com";
    has Str $!legacy-base-url = "https://www1.nseindia.com";

    has Cro::HTTP::Client $!client;
    has Cro::HTTP::Client::CookieJar $!jar;

    #| TWEAK gets cookies required to call NSE India APIs and
    #| initialises a client.
    submethod TWEAK() {
        # Initialize the client.
        $!client =  Cro::HTTP::Client.new:
                    # creating with cookie-jar, sends cookies on
                    # follow up requests.
                    :cookie-jar,
                    user-agent => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0',
                    headers => [
                                'Accept-Language' => 'en-US,en;q=0.9',
                                # 'Accept-Encoding' => 'gzip, deflate, br',
                                # 'Connection' => 'keep-alive'
                            ];

        # Calling API once to capture cookies.
        sink await $!client.get: $!base-url;
    }

    #| get-details gets symbol details.
    method get-details(Str $symbol) {
        my $resp = await $!client.get: ($!base-url ~ '/api/quote-equity?symbol=' ~ $symbol);
        return await $resp.body;
    }
}
