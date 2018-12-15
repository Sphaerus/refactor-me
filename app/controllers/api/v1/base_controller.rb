module Api
  module V1
    class BaseController < Api::BaseController
      before_action :authenticate

      def current_account
        Account.find_by(authentication_token: auth_token).tap do |account|
          if account
            account.last_login    = Time.current
            account.session_token ||= Account.generate_session_token
            account.save!
          end
        end
      end

      def current_user
        current_account&.user
      end

      private

      def errors_for_json(service)
        errors_list = []
        service.errors.each do |attr, error|
          errors_list << { attr: attr, msg: error }
        end
        {
            errors:  errors_list,
            success: false
        }
      end

      def success_for_json(message)
        {
            success: {
                data: message
            },
            errors:  nil
        }
      end

    end
  end
end
