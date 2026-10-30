CREATE TABLE IF NOT EXISTS payment_transactions (
  reference TEXT PRIMARY KEY NOT NULL,
  firebase_uid TEXT NOT NULL,
  package_id TEXT NOT NULL CHECK (
    package_id IN ('utme', 'waec', 'post-utme', 'postgraduate')
  ),
  amount_kobo INTEGER NOT NULL CHECK (amount_kobo > 0),
  currency TEXT NOT NULL CHECK (currency = 'NGN'),
  customer_email TEXT NOT NULL,
  status TEXT NOT NULL CHECK (
    status IN ('initializing', 'pending', 'success', 'failed')
  ),
  authorization_url TEXT,
  gateway_transaction_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  paid_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_user_created
  ON payment_transactions(firebase_uid, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_status
  ON payment_transactions(status, updated_at);

CREATE TABLE IF NOT EXISTS user_entitlements (
  firebase_uid TEXT NOT NULL,
  package_id TEXT NOT NULL CHECK (
    package_id IN ('utme', 'waec', 'post-utme', 'postgraduate')
  ),
  payment_reference TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'revoked')),
  granted_at TEXT NOT NULL,
  PRIMARY KEY (firebase_uid, package_id),
  FOREIGN KEY (payment_reference)
    REFERENCES payment_transactions(reference)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_user_entitlements_user_status
  ON user_entitlements(firebase_uid, status);

CREATE TABLE IF NOT EXISTS payment_webhook_events (
  event_key TEXT PRIMARY KEY NOT NULL,
  reference TEXT NOT NULL,
  event_type TEXT NOT NULL,
  received_at TEXT NOT NULL,
  FOREIGN KEY (reference)
    REFERENCES payment_transactions(reference)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_payment_webhook_events_reference
  ON payment_webhook_events(reference);
