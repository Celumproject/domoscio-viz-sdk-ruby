module DomoscioViz
  # A Recommandation.
  class Chart < Resource
    include DomoscioViz::HTTPCalls::GetUrl
  end
end