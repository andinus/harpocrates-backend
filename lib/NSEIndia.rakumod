use Cro::HTTP::Client;
use Cro::HTTP::Client::CookieJar;

use CSV::Parser;
use JSON::Fast <immutable>;

class NSEIndia is export {
    has Str $!base-url = "https://www.nseindia.com";
    has Str $!legacy-base-url = "https://www1.nseindia.com";

    #| bonds contains list of all bonds symbol. This is a static list
    #| set in TWEAK.
    has Hash @!bonds;

    #| bond-symbol holds all valid series for given symbol.
    has %!bond-symbol;

    #| cache-dir stores cache of equity details.
    has IO $!cache-dir = "/tmp/harpocrates-equity-cache".IO;

    has Cro::HTTP::Client $!client;
    has Cro::HTTP::Client::CookieJar $!jar;

    #| TWEAK gets cookies required to call NSE India APIs and
    #| initialises a client.
    submethod TWEAK() {
        # Make sure cache-dir exists.
        mkdir $!cache-dir;
        die "Cache directory doesn't exist" unless $!cache-dir.d;

        # Set @!bonds.
        my $fh = open %?RESOURCES<MW-Bonds-on-CM-11-Feb-2023.csv>, :r;
        LEAVE .close with $fh;

        my $parser = CSV::Parser.new( file_handle => $fh, contains_header_row => True );
        my %data;
        while %data = %($parser.get_line()) {
            # Add symbol to bond-symbol.
            %!bond-symbol{%data<SYMBOL>}{%data<SERIES>} = True;

            @!bonds.push: %(
                SYMBOL => .<SYMBOL>,
                SERIES => .<SERIES>,
                LTP => .<LTP>,
                VALUE => .<VALUE>,
                '%CHNG' => .<%CHNG>,
                'BOND TYPE' => .{"BOND TYPE"},
                'COUPON RATE' => .{"COUPON RATE"},
                'FACE VALUE' => .{"FACE VALUE"},
                'VOLUME (Shares)' => .{"VOLUME (Shares)"},
                'CREDIT RATING' => .{"CREDIT RATING"},
                'MATURITY DATE' => .{"MATURITY DATE"}
            ) with %data;
        }

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
        my IO $file = $!cache-dir.add($symbol);
        # Add details to cache if it doesn't exist.
        unless $file.f {
            my $resp = await $!client.get: ($!base-url ~ '/api/quote-equity?symbol=' ~ $symbol);
            spurt $file, to-json await $resp.body;
        }
        return from-json slurp $file;
    }

    #| bonds is a getter function for @!bonds.
    method bonds(--> List) {
        return @!bonds;
    }
}
