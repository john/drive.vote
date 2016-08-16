class UsersController < ApplicationController
  include UserParams
  include UserRoles

  before_action :set_user, only: [:show, :edit, :update]

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    # user_type is put in to the session in OmniauthCallbacksController
    @type = session['user_type']
  end

  def confirm
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { redirect_to root_path }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    session.delete(:user_type)
    is_new_user = @user.phone_number.blank?

    respond_to do |format|
      if update_user_roles(params) && @user.update(user_params)

        # different notice if the user was just created
        notice = (is_new_user) ? 'Welcome to Drive the Vote!' : 'User was successfully updated.'

        format.html do
          redirect_to root_path, notice: notice, is_new_user: is_new_user.to_s, locale: I18n.locale.to_s
        end
        format.json { render :show, status: :ok, location: @user }
      else
        @type = session['user_type']

        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
