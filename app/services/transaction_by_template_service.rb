class TransactionByTemplateService
  def initialize(user, template)
    @user     = user
    @template = template
  end

  def call
    return false unless if_valid

    ActiveRecord::Base.transaction do
      by_template_service = create_service
      by_template_service.call

      @user.update_attributes(balance: @user.balance - @template.price)

      @user.transactions.create(status:           :success,
                                payment:          'balance',
                                transaction_type: :site_purchase,
                                amount:           by_template_service.target.price)
    end
  end

  protected

  def create_service
    TargetGeneratorService.new(@user, @template)
  end

  def if_valid
    @user.balance >= @template.price && regular_transactions < 100_000_00 # Cents
  end

  def regular_transactions
    if @user.role&.all_transactions?
      @user.all_transactions
    else
      @user.template_transactions
    end.map(&:amount).sum
  end
end
