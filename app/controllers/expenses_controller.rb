class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_expense, only: [ :show, :edit, :update, :destroy, :confirm ]

  def index
    @expenses = @trip.expenses
                     .includes(:paid_by, :confirmed_by, :trip_item)
                     .sort_by { |e| expense_sort_time(e) }
    @total_by_currency = @trip.expenses.group(:currency).sum(:amount)
    @paid_by_currency  = @trip.expenses.where.not(confirmed_at: nil).group(:currency).sum(:amount)
  end

  def show
    sorted_ids = @trip.expenses
                      .order(expense_date: :desc, created_at: :desc)
                      .pluck(:id)
    idx = sorted_ids.index(@expense.id) || 0
    @expense_index    = idx + 1
    @expense_count    = sorted_ids.size
    @prev_expense_id  = sorted_ids[idx - 1] if idx > 0
    @next_expense_id  = sorted_ids[idx + 1] if idx < sorted_ids.size - 1
  end

  def new
    current_member = @trip.trip_members.joins(:traveler).find_by(travelers: { user_id: current_user.id })
    @expense = Expense.new(
      currency: "EUR",
      expense_date: Date.today,
      category: "other",
      paid_by_traveler_id: current_member&.traveler_id
    )
    # Pre-fill from a trip item's "Convert to Expense" redirect
    if (prefill = params[:expense]&.permit(:description, :category, :expense_date, :amount, :currency, :trip_item_id))
      @expense.assign_attributes(prefill.to_h.symbolize_keys)
    end
    @members = @trip.trip_members.includes(:traveler)
  end

  def create
    @expense = @trip.expenses.new(expense_params)
    @expense.added_by = current_user

    if @expense.save
      ParseReceiptJob.perform_later(@expense.id) if @expense.receipt.attached?
      redirect_to trip_path(@trip, tab: "expenses"), notice: "Expense added."
    else
      @members = @trip.trip_members.includes(:traveler)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @members = @trip.trip_members.includes(:traveler)
  end

  def update
    paid_attrs = if params.dig(:expense, :mark_paid) == "1"
      { confirmed_at: @expense.confirmed_at || Time.current,
        confirmed_by: @expense.confirmed_by || current_user }
    else
      { confirmed_at: nil, confirmed_by: nil }
    end

    if @expense.update(expense_params.merge(paid_attrs))
      redirect_to trip_expense_path(@trip, @expense), notice: "Saved."
    else
      @members = @trip.trip_members.includes(:traveler)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy!
    redirect_to trip_path(@trip, tab: "expenses"), notice: "Expense deleted."
  end

  def confirm
    if @expense.confirmed?
      @expense.update!(confirmed_at: nil, confirmed_by: nil)
    else
      @expense.update!(confirmed_at: Time.current, confirmed_by: current_user)
    end
    redirect_back fallback_location: trip_path(@trip, tab: "expenses")
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:trip_id])
  end

  def set_expense
    @expense = @trip.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:amount, :currency, :description, :category, :expense_date, :paid_by_traveler_id, :receipt, :trip_item_id)
  end
end
