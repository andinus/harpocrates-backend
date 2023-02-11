use Data::Dump::Tree;

use DBIish::Transaction;

#| settle-orders runs Price/Time priority aka FIFO algorithm to settle
#| orders in order book. It moves orders to transactions table. It
#| returns the number of buy orders that were completely, partially
#| settled.
sub settle-orders(%config, $pool --> Int) is export {
    my $connection = $pool.get-connection();
    LEAVE .dispose with $connection;

    my Int $processed-buy = 0;

    # Get buy orders. Only this function works with orderbook. We
    # might add the ability to cancel orders. With this we cannot do
    # that.
    my $sth = $connection.execute(
        'SELECT id, account, symbol, quantity, price, created
                 FROM orderbook.detail WHERE type = \'buy\' ORDER BY price, created;',
    );

    # Stores buy orders.
    my @buy-orders = $sth.allrows(:array-of-hash);

    # Match buy order to sell orders if possible.
    BUY: for @buy-orders -> $buy {
        my $t = DBIish::Transaction.new(:$connection, :retry);
        $t.in-transaction: -> $dbh {
            my Int $quantity = $buy<quantity>;
            my Str $symbol = $buy<symbol>;

            # Match to sell orders from database. sell order prices
            # should be less than buy order limit.
            my $sth = $dbh.execute(
                'SELECT id, account, symbol, quantity, price, created
                     FROM orderbook.detail WHERE type = \'sell\' AND symbol = ?
                                           AND price <= ?
                     ORDER BY price, created;',
                $symbol, $buy<price>
            );

            SELL: for $sth.allrows(:array-of-hash) -> $sell {
                # Perfect match. Remove the sell order and add it to
                # transaction table.
                if $quantity == $sell<quantity> {
                    $dbh.execute('DELETE FROM orderbook.detail WHERE id = ?;', $sell<id>);
                    $quantity = 0;
                } elsif $quantity > $sell<quantity> {
                    # Remove the sell order and continue looking for
                    # more matches for this buy order.
                    $dbh.execute('DELETE FROM orderbook.detail WHERE id = ?;', $sell<id>);
                    $quantity -= $sell<quantity>;
                } else {
                    # Sell order quantity is greater than buy order so
                    # we update the sell order quantity.
                    $dbh.execute(
                        'UPDATE orderbook.detail SET quantity = quantity - ? WHERE id = ?;',
                        $quantity, $sell<id>
                    );
                    $quantity = 0;
                }

                # Add buy transaction for buyer.
                $dbh.execute(
                    'INSERT INTO users.transaction (account, type, symbol, quantity, price)
                             VALUES (?, ?, ?, ?, ?);',
                    $buy<account>, 'buy', $symbol, $buy<quantity>, $sell<price>
                );

                # Add sell transaction for seller.
                $dbh.execute(
                    'INSERT INTO users.transaction (account, type, symbol, quantity, price)
                             VALUES (?, ?, ?, ?, ?);',
                    $sell<account>, 'sell', $symbol, $buy<quantity>, $sell<price>
                );

                # If buy order is satisfied then delete the buy order
                # and move on.
                if $quantity == 0 {
                    $dbh.execute('DELETE FROM orderbook.detail WHERE id = ?;', $buy<id>);
                    $processed-buy++;
                    last SELL;
                }
            }

            # If buy order is partially satisfied then update the
            # order book.
            if $quantity != $buy<quantity> {
                $dbh.execute(
                    'UPDATE orderbook.detail SET quantity = ? WHERE id = ?;',
                    $quantity, $buy<id>
                );
                $processed-buy++;
            }
        }
    }
    return $processed-buy;
}
