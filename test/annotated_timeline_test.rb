require "rubygems"

require 'test/unit'

require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'

require 'ostruct'

require File.join(File.dirname(__FILE__), '../lib/annotated_timeline.rb')
include AnnotatedTimeline

require File.dirname(__FILE__) + '/test_helper.rb'

class AnnotatedTimelineTest < Test::Unit::TestCase

  def test_data_points_inserted
    output  = annotated_timeline({Time.now =>{:foo=>7}, 
                                  1.days.ago=>{:foo=>6, :bar=>10}, 
                                  2.days.ago=>{:bar=>4}, 
                                  3.days.ago=>{:foo=>6, :bar=>2}, 
                                  4.days.ago=>{:foo=>9, :bar=>7}})
  
    output2 = annotated_timeline({3.days.ago=>{:foo=>6, :bar=>2}, 
                                  Time.now =>{:foo=>7}, 
                                  2.days.ago=>{:bar=>4}, 
                                  1.days.ago=>{:foo=>6, :bar=>10}, 
                                  4.days.ago=>{:bar=>7, :foo=>9}})
  
    assert_match(/data\.addColumn\('date', 'Date'\);/, output, "Should Make Date Column")
    assert_match(/data\.addColumn\('number', 'Bar'\);/, output, "Should Make Bar Column")
    assert_match(/data\.addColumn\('number', 'Foo'\);/, output, "Should Make Foo Column")
    
    date_string = "data.setValue(0, 0, new Date(#{4.days.ago.year}, #{4.days.ago.month-1}, #{4.days.ago.day}));"
    assert_match(date_string, output, "should put the first date in properly")
    
    assert_match(/data\.setValue\(0, 1, 7\);/, output, "should put right value for bar" )
    assert_match(/data\.setValue\(0, 2, 9\);/, output, "should put right value for foo")
    
    assert_match(output, output2, "data should be sorted properly")
  end
  
  def test_options_passed
    output = annotated_timeline({Date.today =>{:foo=>7, :bar=>9}, 
                                1.days.ago.to_date=>{:foo=>6, :bar=>10}, 
                                2.days.ago.to_date=>{:foo=>5, :bar=>4}   }, 
                                'graph',
                                {:annotations               => {:foo=>{1.days.ago.to_date=>["asdf"]}},
                                  :displayExactValues       => true, 
                                  :allowHtml                => true,
                                  :allValuesSuffix          => " euros",                              
                                  :annotationsWidth         => 35,
                                  :displayAnnotationsFilter => true,
                                  :displayZoomButtos        => false,
                                  :legendPosition           => "newRow",
                                  :scaleColumns             => [1,0],                                
                                  :scaleType                => "maximize",
                                  :zoomEndTime              => Time.now,
                                  :min                      => 5, 
                                  :colors                   => ['orange', '#AAAAAA'],
                                  :zoomStartTime            => 4.days.ago                   })
    
    assert_match(/displayExactValues: true/, output, "should pass exact values option")
    assert_match(/allowHtml: true/, output, "should pass allow html option")
    assert_match(/allValuesSuffix: " euros"/, output, "should pass suffix option")
    assert_match(/annotationsWidth: 35/, output, "should pass annotations width")
    assert_match(/displayAnnotationsFilter: true/, output, "should pass annotations filter option")
    assert_match(/displayZoomButtos: false/, output, "should pass zoom buttons option")
    assert_match(/legendPosition: "newRow"/, output, "should pass legendPosition")
    assert_match(/scaleColumns: \[1, 0\]/, output, "should pass scaleColumns array")
    assert_match(/scaleType: "maximize"/, output, "should pass scaleType option")               
    
    end_date_string = "zoomEndTime: new Date(#{Time.now.year}, #{Time.now.month-1}, #{Time.now.day})"
    assert_match(end_date_string, output, "should pass zoom end option")
  
    assert_match(/min: 5/, output, "should pass min option")
    assert_match(/scaleType: \"maximize\"/, output, "should pass scale type options")
    assert_match(/colors: \[\"orange\", \"#AAAAAA\"\]/, output, "should pass colors")
    
    start_date_string = "zoomStartTime: new Date(#{4.days.ago.year}, #{4.days.ago.month-1}, #{4.days.ago.day})"
    assert_match(start_date_string, output, "should pass zoom option")
  end

  
  def test_annotations_inserted
    
    annotation_hash = { :foo  =>  {4.days.ago.to_date=>["Step one", "cut a hole in the box"], 1.days.ago.to_date=>["Step three"]},
                        :bar  =>  {3.days.ago.to_date=>["Step two", "put your junk in the box"]} }
    
    data_point_hash =  {3.days.ago.to_date  =>{:foo=>6, :bar=>2}, 
                        Time.now.to_date   =>{:foo=>7}, 
                        2.days.ago.to_date =>{:bar=>4}, 
                        1.days.ago.to_date =>{:foo=>6, :bar=>10}, 
                        4.days.ago.to_date =>{:bar=>7, :foo=>9}}
    
    output = annotated_timeline(data_point_hash,
                                  'graph',
                                  {:annotations  => annotation_hash})
                                  
    assert_match(/data\.addColumn\('string', 'Foo_annotation_title'\);/, output, "Should Make Foo Annotation Title Column")
    assert_match(/data\.addColumn\('string', 'Foo_annotation_text'\);/,  output, "Should Make Foo Annotation Text Column")
    assert_match(/data\.addColumn\('string', 'Bar_annotation_title'\);/, output, "Should Make Bar Annotation Title Column")
    assert_match(/data\.addColumn\('string', 'Bar_annotation_text'\);/,  output, "Should Make Bar Annotation Text Column")                                  
  end
  
end