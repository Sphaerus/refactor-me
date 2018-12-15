class TransactionProcessingService
  def initialize(user, product_id)
    @user    = user
    @product = Actions::Base.find_by id: product_id
  end

  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      @reservation = @user.reservations.
          where(action_id: @product.id).
          where("status IS NOT NULL AND status NOT IN ('archived', 'cancelled')").
          first_or_initialize
      @reservation.update(quantity: (@reservation.quantity.presence || 0) + 1) # Nil guard

      update_state!
    end
  end

  protected

  def valid?
    @product.allowed_for?(@user) and @user.balance >= @product.price
  end

  def update_state!
    if @product.is_a?(Actions::Target)
      @user.transactions.create(status: 'sold_target', transaction_type: :product_purchase, amount: @product.price, product: @product)
      @user.update_columns(balance: @user.balance - @product.price - @product.discount_for_user(@user))
    elsif @product.is_a?(Actions::Lease)
      @user.transactions.create(status: 'sold_lease', transaction_type: :product_purchase, amount: @product.price, product: @product)
      @user.update_columns balance: @user.balance - @product.price
    end
  end
end
