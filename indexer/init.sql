CREATE TYPE IF NOT EXISTS network_type AS ENUM ('mainnet', 'sepolia')

CREATE TABLE IF NOT EXISTS indexer_example (
    _cursor bigint,
    created_at timestamp default current_timestamp,
    network network_type NOT NULL,
    block_hash text NOT NULL,
    block_number bigint NOT NULL,
    block_timestamp timestamp NOT NULL,
    transaction_hash text NOT NULL,

    -- Add your custom columns here
);
