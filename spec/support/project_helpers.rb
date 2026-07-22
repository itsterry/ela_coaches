def setup_factories
  modelnames = [
    Availability,
    Coach,
    Slot
  ]

  modelnames.each do |thing|
    string = thing.to_s.underscore.gsub(/\//, '_')
    symbol = string.to_sym
    symbol_persisted = "#{string}_persisted".to_sym
    things = string.pluralize

    let(symbol) { FactoryBot.build_stubbed symbol }
    let(symbol_persisted) { FactoryBot.create symbol }
    let("no_#{things}".to_sym) { thing.none }
    let("some_#{things}".to_sym) { thing.where(id: eval(symbol_persisted.to_s).id) }
  end
end

def renders_without_error
  it 'renders without error' do
    render
  end
end

def returns_created
  it 'returns http created' do
    expect(response).to have_http_status(:created)
  end
end

def returns_not_found
  it 'returns http not found' do
    expect(response).to have_http_status(:not_found)
  end
end

def returns_see_other
  it 'returns http see_other' do
    expect(response).to have_http_status(:see_other)
  end
end

def returns_unprocessable_content
  it 'returns http unprocessable_content' do
    expect(response).to have_http_status(:unprocessable_content)
  end
end
