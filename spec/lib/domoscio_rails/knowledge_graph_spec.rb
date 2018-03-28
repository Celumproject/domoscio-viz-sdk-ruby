require_relative '../../spec_helper'

describe DomoscioViz::KnowledgeGraph do
  include_context 'knowledge_graphs'
  
  created = nil

  describe 'CREATE' do
    it 'creates a new knowledge_graph to the company' do
      created = new_knowledge_graph
      expect(created["name"]).to eq('La révolution Française')
    end
  end

  describe 'FETCH' do
    it 'fetches all the knowledge_graphs of the company' do
      knowledge_graphs = DomoscioViz::KnowledgeGraph.fetch()
      expect(knowledge_graphs).to be_kind_of(Array)
      expect(knowledge_graphs.map{|kg| kg["name"]}).to include(created["name"])
      expect(knowledge_graphs).not_to be_empty
    end
  end
  
  describe 'DESTROY' do
    it 'destroys the created knowledge_graph of the company' do
      DomoscioViz::KnowledgeGraph.destroy(created["id"])
    end
  end

  describe 'FETCH' do
    it 'fetches all the knowledge_graphs of the company and checks the destroyed student is not present' do
      knowledge_graphs = DomoscioViz::KnowledgeGraph.fetch()
      expect(knowledge_graphs).to be_kind_of(Array)
      expect(knowledge_graphs.map{|kg| kg["id"]}).not_to include(created["id"])
    end
  end
  

end