# encoding: utf-8


require "spec_helper"


describe "people/note_preview_mobile.html.erb" do

  let(:mock_photo_url) {
    fixture_file_upload('/testdata/715x536.png', 'image/png') 
  }

  let(:mock_person) {
    FactoryGirl.create(:person)
  }
  let(:mock_note) {
    FactoryGirl.create(:note, photo_url: mock_photo_url)
  }

  let(:mock_request_mobile) {
    mock Object,
      display: mock(Object,width:mock_request_mobile_display),
      default_charset: 'utf-8'
  }
  let(:mock_request_mobile_display) { 120 }

  before {
    assign :person, mock_person
    assign :note, mock_note
    controller.request.stub!(:mobile).and_return(mock_request_mobile)
    controller.stub!(:params).and_return({id:mock_person.id})
    view.stub!(:reencode_for_mobile).and_return('encoded_name')
  }

  subject {
    render
    rendered
  }


  context "with person(photo_url = nil)" do
    let(:mock_photo_url) { nil }
    it { should_not have_tag(:a, text:'写真') }
    it { should have_tag(:a, text:"<< この人に関するメモに戻る ",
                             with:{
                               href:note_list_path({
                                 id:mock_person.id,
                                 name:"encoded_name",
                               })
                             }) }
  end


  context "with person(photo_url != nil)" do
    it { should have_tag(:a, text:'写真') }
    it { should have_tag(:a, text:"<< この人に関するメモに戻る ",
                             with:{
                               href:note_list_path({
                                 id:mock_person.id,
                                 name:"encoded_name",
                               })
                             }) }
    context "with request that respond to mobile.display" do
      context "and mobile.display.width = 120" do
        let(:mock_request_mobile_display) { 120 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_small) }) }
      end
      context "and mobile.display.width = 174" do
        let(:mock_request_mobile_display) { 174 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_small) }) }
      end
      context "and mobile.display.width = 175" do
        let(:mock_request_mobile_display) { 175 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end
      context "and mobile.display.width = 249" do
        let(:mock_request_mobile_display) { 249 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end
      context "and mobile.display.width = 250" do
        let(:mock_request_mobile_display) { 250 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_large) }) }
      end
      context "and mobile.display.width = 499" do
        let(:mock_request_mobile_display) { 499 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_large) }) }
      end
      context "and mobile.display.width = 500" do
        let(:mock_request_mobile_display) { 500 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end
      context "and mobile.display.width = 1000" do
        let(:mock_request_mobile_display) { 1000 }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end
      context "and mobile.display.width = nil" do
        let(:mock_request_mobile_display) { nil }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end

      context "with request that only respond to mobile.display" do
        let(:mock_request_mobile) { mock(Object, display:false, default_charset:'utf-8') }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end

      context "with request that not respond to mobile.display" do
        let(:mock_request_mobile) { nil }
        it { should have_tag(:a, with: { href:mock_note.photo_url_url(:mobile_medium) }) }
      end

    end
  end

end
