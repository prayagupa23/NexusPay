-- Add columns for trusted contacts verification to transactions table
-- Run this in your Supabase SQL Editor

ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS is_trusted_contact BOOLEAN DEFAULT NULL,
ADD COLUMN IF NOT EXISTS is_verified_contact BOOLEAN DEFAULT NULL;

-- Add comments to document the columns
COMMENT ON COLUMN transactions.is_trusted_contact IS 'Indicates if the receiver is a trusted contact (previously transacted with)';
COMMENT ON COLUMN transactions.is_verified_contact IS 'Indicates if the contact was verified via phone number API';

-- Optional: Create an index for faster queries on trusted contacts
CREATE INDEX IF NOT EXISTS idx_transactions_trusted_contact 
ON transactions(user_id, is_trusted_contact) 
WHERE is_trusted_contact = false;

-- Optional: Create an index for faster queries on verified contacts
CREATE INDEX IF NOT EXISTS idx_transactions_verified_contact 
ON transactions(user_id, is_verified_contact) 
WHERE is_verified_contact = false;

