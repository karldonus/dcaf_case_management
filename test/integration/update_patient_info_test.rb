require 'test_helper'

class UpdatePatientInfoTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
  end

  after do
    Capybara.use_default_driver
  end

  describe 'changing patient dashboard information' do
    before do
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      find('#patient_pregnancy_last_menstrual_period_weeks').select '5 weeks'
      find('#patient_pregnancy_last_menstrual_period_days').select '2 days'
      fill_in 'Appointment date', with: '2016-09-01'
      fill_in 'Phone number', with: '123-666-8888'
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      wait_for_ajax

      visit authenticated_root_path
      visit edit_patient_path @patient
    end

    it 'should alter the information' do
      within :css, '#patient_dashboard' do
        lmp_weeks = find('#patient_pregnancy_last_menstrual_period_weeks')
        lmp_days = find('#patient_pregnancy_last_menstrual_period_days')
        assert has_field?('First and last name', with: 'Susie Everyteen 2')
        assert_equal '5', lmp_weeks.value
        assert_equal '2', lmp_days.value
        assert has_field?('Appointment date', with: '2016-09-01')
        assert has_field? 'Phone number', with: '123-666-8888'
      end
    end
  end

  describe 'changing abortion information' do
    before do
      click_link 'Abortion Information'
      find('#patient_clinic_name').select 'Sample Clinic 1'
      # TODO: finish this after implementing clinic logic
      fill_in 'Abortion cost', with: '300'
      fill_in 'Patient contribution', with: '200'
      fill_in 'National Abortion Federation pledge', with: '50'
      fill_in 'DCAF soft pledge', with: '25'
      check 'Resolved without assistance from DCAF'

      click_away_from_field
      visit authenticated_root_path
      visit edit_patient_path @patient
      click_link 'Abortion Information'
    end

    # problematic test
    it 'should alter the information' do
      within :css, '#abortion_information' do
        assert_equal 'Sample Clinic 1', find('#patient_clinic_name').value
        # TK after clinic logic
        assert has_field? 'Abortion cost', with: '300'
        assert has_field? 'Patient contribution', with: '200'
        assert has_field? 'National Abortion Federation pledge', with: '50'
        assert has_field? 'DCAF soft pledge', with: '25'
        assert_equal '1', find('#patient_pregnancy_resolved_without_dcaf').value
      end
    end
  end

  describe 'changing patient information' do
    before do
      click_link 'Patient Information'
      fill_in 'Other contact name', with: 'Susie Everyteen Sr'
      fill_in 'Other phone', with: '123-666-7777'
      fill_in 'Relationship to other contact', with: 'Friend'
      fill_in 'Age', with: '24'
      find('#patient_race_ethnicity').select 'White/Caucasian'
      fill_in 'City', with: 'Washington'
      fill_in 'State', with: 'DC'
      fill_in 'ZIP', with: '90210'
      find('#patient_voicemail_preference').select 'Voicemail OK'
      check 'Spanish Only'

      find('#patient_employment_status').select 'Part-time'
      find('#patient_income').select '$30,000-34,999 ($577-672/week)'
      find('#patient_household_size_adults').select '1'
      find('#patient_household_size_children').select '3'
      find('#patient_insurance').select 'Other state Medicaid'
      find('#patient_referred_by').select 'Other abortion fund'
      check 'Homelessness'
      check 'Prison'

      click_away_from_field
      visit authenticated_root_path
      visit edit_patient_path @patient
    end

    # problematic test
    it 'should alter the information' do
      click_link 'Patient Information'
      within :css, '#patient_information' do
        assert has_field? 'Other contact name', with: 'Susie Everyteen Sr'
        assert has_field? 'Other phone', with: '123-666-7777'
        assert has_field? 'Relationship to other contact', with: 'Friend'
        assert has_field? 'Age', with: '24'
        assert_equal 'White/Caucasian', find('#patient_race_ethnicity').value
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'
        assert has_field? 'ZIP', with: '90210'
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert has_checked_field? 'Spanish Only'

        assert_equal 'Part-time', find('#patient_employment_status').value
        assert_equal '$30,000-34,999 ($577-672/week)',
                     find('#patient_income').value
        assert_equal '1', find('#patient_household_size_adults').value
        assert_equal '3', find('#patient_household_size_children').value
        assert_equal 'Other state Medicaid', find('#patient_insurance').value
        assert_equal 'Other abortion fund', find('#patient_referred_by').value
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert has_checked_field? 'Spanish Only'
        assert has_checked_field? 'Homelessness'
        assert has_checked_field? 'Prison'
      end
    end
  end

  private

  def click_away_from_field
    fill_in 'First and last name', with: nil
    wait_for_ajax
  end
end
