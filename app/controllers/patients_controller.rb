class PatientsController < ApplicationController

  def index
    @patients = Patient.all
  end

  def show
    @patient = current_user.patients.find params[:id]
  end

  def new
    @patient = Patient.new
    @health_plans = HealthPlan.all
  end

  def edit
    @patient = current_user.patients.find params[:id]
    @health_plans = HealthPlan.all
  end

  def create
    @patient = current_user.patients.new patient_params

    if @patient.save
      redirect_to patients_path
    else
      render :new
    end
  end

  def update
    @patient = current_user.patients.find params[:id]

    if @patient.update_attributes patient_params
      redirect_to patients_path
    else
      render :edit
    end
  end

  def destroy
    @patient = current_user.patients.find params[:id]

    if @patient.destroy
      redirect_to patients_path
    else
      render :show
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:name, :health_plan_id, :supply_area_id, :order_number, :o2_prescription, :period)
  end
end
