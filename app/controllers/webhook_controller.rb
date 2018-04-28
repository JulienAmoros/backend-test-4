class WebhookController < ApplicationController
  def incoming
    @response = Twilio::TwiML::VoiceResponse.new

    get_or_create_call

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
    get_or_create_call

    @call.update(
             recording_url: params['RecordingUrl'],
             recording_duration: params['RecordingDuration'],
    )

  end

  # Status Callback
  def call_status
    get_or_create_call

    @call.update(
        status: params['CallStatus'],
        duration: params['CallDuration'],
    )
  end

  private
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
