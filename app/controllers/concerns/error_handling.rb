module ErrorHandling
  def render_record_not_found!
    render json: { error: 'Not found', success: false }, status: :not_found
  end
end