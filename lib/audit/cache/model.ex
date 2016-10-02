# defmodule Audit.Cache.Model do
#   require Record
#   Record.defrecord :user, [email: nil, status: nil, openstack_id: nil, 
#                            name: nil, address: nil, phone: nil, phone_number: nil,
#                            phone_verified: false, email_verified: false, payment_verified: false,
#                            created_at: nil, trial_started_at: nil, trial_expired_at: nil, level: 0,
#                            credit_balance: 0.0, bill_day: 0, id: nil, referral_code: nil ]
#   Record.defrecord :admin, [audit_ids: nil, expires: nil, id: nil, issued_at: nil, tenant: nil]
# end