module ActiveJob
  module Arguments
    remove_const(:TYPE_WHITELIST)
    TYPE_WHITELIST = [Date, DateTime, Time, NilClass, Fixnum, Float, String, TrueClass, FalseClass, Bignum ]
  end
end

module ActionMailer
  class DeliveryJob < ActiveJob::Base
    extend ActiveJob::Arguments
  end
end