module CheckinCommand
  def checkin!(*)
    return respond_need_to_register unless student_registered?(student_number)

    return checkin_without_checkout if session[:status] == :checkin

    respond_with :message, text: t(:ask_photo)
    save_context :checkin_photo_from_message
  end

  def checkin_photo_from_message(*)
    session[:time_checkin] = Time.now.to_s
    # PhotoLoader.call(payload: payload, time: session[:time_checkin], status: 'checkins')
    PhotoLoader.call(payload, session[:time_checkin], 'checkins')
    respond_with :message, text: t(:ask_geolocation)
    save_context :checkin_geo_from_message
  rescue Errors::NoPhotoError
    handle_no_photo
  end

  def checkin_geo_from_message(*)
    GeolocationLoader.call(payload, session[:time_checkin], 'checkins')
    session[:status] = :checkin
    respond_with :message, text: t(:checkin_end)
  rescue Errors::NoGeolocationError
    handle_no_geolocation
  rescue Errors::FarFromCampError
    handle_too_far_from_camp
  end

  private

  def handle_no_geolocation
    respond_with :message, text: t(:no_geolocation)
    save_context :checkin_geo_from_message
  end

  def handle_too_far_from_camp
    respond_with :message, text: t(:too_far_from_camp)
    save_context :checkin_geo_from_message
  end

  def handle_no_photo
    respond_with :message, text: t(:no_photo)
    save_context :checkin_photo_from_message
  end

  def respond_need_to_register
    respond_with :message, text: t(:need_to_register)
  end

  def checkin_without_checkout
    respond_with :message, text: t(:checkin_without_checkout)
  end
end
