require_relative 'helper'

class TestComparativeGenomics < Test::Unit::TestCase

  context 'genetree_id' do 

    setup do 
      EnsemblRest.connect_db
    end

    should 'support a basic call and return the correct data' do
      tree = ComparativeGenomics.genetree_id 'ENSGT00390000003602'
      assert tree.index('Euteleostomi') && tree.index('Sarcopterygii')
    end

    should 'work with nh response type' do
      tree1 = ComparativeGenomics.genetree_id 'ENSGT00390000003602',
                response: 'nh',
                nh_format: 'species_short_name'
      tree2 = ComparativeGenomics.genetree_id 'ENSGT00390000003602',
                response: 'nh',
                nh_format: 'species'
      assert tree1.size < tree2.size
      assert tree1.index 'Xmac'
      assert tree2.index 'xiphophorus_maculatus'
    end

    should 'return a Bio::PhyloXML object' do
      tree = ComparativeGenomics.genetree_id 'ENSGT00390000003602',
              response: 'ruby' 
      assert_instance_of Bio::PhyloXML::Parser, tree
    end


  end


  context 'genetree_member_id' do 

    setup do 
      EnsemblRest.connect_db
    end

    should 'support a basic call and return the correct data' do
      tree = ComparativeGenomics.genetree_member_id 'ENSG00000157764'
      assert tree.index('Petromyzon marinus')
    end

    should 'return a Bio::PhyloXML object' do
      tree = ComparativeGenomics.genetree_member_id'ENSG00000157764',
              response: 'ruby' 
      assert_instance_of Bio::PhyloXML::Parser, tree
    end

  end


  context 'genetree_member_symbol' do

    setup do 
      EnsemblRest.connect_db
    end

    should 'support a basic call and return the correct data' do
      tree = ComparativeGenomics.genetree_member_symbol 'homo_sapiens', 'BRCA2'
      assert tree.index('BRCA2')
    end

  end


  context 'homology_id' do 

    setup do
      EnsemblRest.connect_db
      require 'rexml/document'
    end

    should 'support a basic call and return the correct data' do
      hom = ComparativeGenomics.homology_id 'ENSG00000157764'
      assert hom.index 'Bilateria'
      assert hom.index 'ENSG00000157764'
      assert hom.index 'ENSG00000173327'
    end

    should 'return a json object' do
      hom = ComparativeGenomics.homology_id 'ENSG00000157764',
              response: 'json'
      assert_nothing_raised { JSON.parse hom }
    end

    should 'return a xml object' do
      hom = ComparativeGenomics.homology_id 'ENSG00000157764',
              response: 'xml'      
      assert_nothing_raised { REXML::Document.new hom }
    end

    should 'support the sequence parameter' do 
      hom = ComparativeGenomics.homology_id 'ENSG00000157764', sequence: 'none'
      hom2 = ComparativeGenomics.homology_id 'ENSG00000157764', sequence: 'protein'
      assert hom.size < hom2.size
    end

    should 'return a list of Homology objects' do 
      homs = ComparativeGenomics.homology_id 'ENSG00000157764', 
              response: 'ruby'
      homs.each { |hom| assert_instance_of Homology, hom }
      homs.each do |hom|
        hom.bio_methods.each {|met| assert hom.respond_to? met}
      end
    end

    should 'support the aligned parameter' do
      al = ComparativeGenomics.homology_id 'ENSG00000157764'
      nal = ComparativeGenomics.homology_id 'ENSG00000157764', aligned: false
      assert al.size > nal.size
    end

  end
  

  context 'homology_symbol' do

    setup do
      EnsemblRest.connect_db
      require 'rexml/document'
    end

    should 'support a basic call and return the correct data' do
      hom = ComparativeGenomics.homology_symbol 'human', 'BRCA2'
      assert hom.index 'Homininae'
      assert hom.index 'ENSG00000139618'
    end


    should 'return a list of Homology objects' do 
      homs = ComparativeGenomics.homology_symbol 'human', 'BRCA2', 
              response: 'ruby'
      homs.each { |hom| assert_instance_of Homology, hom }
      homs.each do |hom|
        hom.bio_methods.each {|met| assert hom.respond_to? met}
      end
    end

  end


end