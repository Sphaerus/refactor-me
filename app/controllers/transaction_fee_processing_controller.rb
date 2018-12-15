class TransactionFeeProcessingController < ApplicationController

  def create
    service = TransactionProcessingService.new(current_user, params[:product_id])

    if service.call
      flash[:notice] = I18n.t('payments.success')

      if service.transaction.target.is_a?(Actions::Target)
        send_product_notifications(service.transaction)
        redirect_to templates_path
      else
        send_target_notifications(service.transaction)
        redirect_to targets_path
      end
    else
      redirect_to default_error_path, alert: service.error
    end
  end

  private

  def send_product_notifications(transaction)
    TransactionProductNotificationService.new(transaction).call
  end

  def send_target_notifications(transaction)
    TransactionTargetNotificationService.new(transaction).call
  end
end
