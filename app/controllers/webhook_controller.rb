class WebhookController < ApplicationController
  before_action :get_or_create_call #, :authenticate

  def incoming
    @response = Twilio::TwiML::VoiceResponse.new

    # Do things depending on Digits received, ask for action otherwise
    if params['Digits']
      case params['Digits']
        when '1'
          redirect_call
        when '2'
          record_message
        else
          # On error, notify then loop back to start
          digit_error
          @response.pause
          ask_for_action
          @response.redirect('/call/hook')
      end
    else
      ask_for_action
      @response.redirect('/call/hook')
    end

    render xml: @response.to_xml
  end

  # Recording Callback
  def message
    @call.update(
             recording_url: params['RecordingUrl'],
             recording_duration: params['RecordingDuration'],
    )

  end

  # Status Callback
  def call_status
    @call.update(
        status: params['CallStatus'],
        duration: params['CallDuration'],
    )
  end

  private

  # Validate API authenticity
  # def authenticate
  #   auth_token = ENV['TWILIO_TOKEN']
  #   validator = Twilio::Security::RequestValidator.new(auth_token)
  #
  #   post_vars = params.reject { |k, _| k.downcase == k }
  #   twilio_signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
  #
  #   validator.validate(request.url, post_vars, twilio_signature)
  # end

  # Add instructions to redirect call to personnal number defined in <PROJETC_ROOT>/.env
  def redirect_call
    @response.say('You are being redirected')
    @response.dial(number: ENV['PERSONNAL_PHONE'])

    @call.update(final_action: 'redirected')
  end

  # Add instruction to record a message
  def record_message
    @response.say('You can leave a message')
    @response.record(action: '/call/hook/message')

    @call.update(final_action: 'left_message')
  end

  def digit_error
    @response.say('Sorry, I don\'t understand your request.')
  end

  # Add instruction to get user input (1-digit number)
  def ask_for_action
    @response.gather(numDigits: 1) do |g|
      g.say('To call Julien directly, press 1. To leave a message, press 2.')
    end
  end

  # Get the call object based on CallSid, otherwise create it in database
  def get_or_create_call
    @call = Call.find_by(uid: params['CallSid'])
    @call = Call.create(
        uid: params['CallSid'],
        from: params['Caller'],
    ) if @call.nil?
  end
end
