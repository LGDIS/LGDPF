# encoding: utf-8


require "spec_helper"


describe "people/view_mobile.html.erb" do

  let(:mock_photo_url) {
    fixture_file_upload('/testdata/715x536.png', 'image/png') 
  }
  let(:mock_person_const) {
    {"allergy_flag"=>{"1"=>"有", "0"=>"無"}, "baby"=>{"0"=>"該当しない", "1"=>"乳児", "2"=>"幼児"}, "bedridden_elderly"=>{"0"=>"該当しない", "1"=>"該当する"}, "elderly_alon"=>{"0"=>"該当しない", "1"=>"該当する"}, "elderly_couple"=>{"0"=>"該当しない", "1"=>"該当する"}, "elderly_dementia"=>{"0"=>"該当しない", "1"=>"該当する"}, "expiry_date"=>{"30"=>"約 1 か月（30 日）後", "60"=>"約 2 か月（60 日）後", "90"=>"約 3 か月（90 日）後", "180"=>"約 6 か月（180 日）後", "360"=>"約 1 年（360 日）後"}, "family_well"=>{"1"=>"無事", "0"=>"無事か確認できていない"}, "in_city_flag"=>{"1"=>"市内", "0"=>"市外"}, "injury_flag"=>{"1"=>"有", "0"=>"無"}, "invalid_reason"=>{"do_not_want_anymore"=>"この記録に関する最新情報は不要です。", "spam_received"=>"この記録が原因でスパムを受信したから", "record_is_spam"=>"この記録がスパム情報だから", "served_its_purpose"=>"この記録が目的を果たしたから"}, "physical_disability_certificate"=>{"0"=>"該当しない", "1"=>"1級", "2"=>"2級"}, "pregnancy"=>{"0"=>"該当しない", "1"=>"妊娠中"}, "refuge_status"=>{"1"=>"避難済", "2"=>"未避難", "3"=>"避難所を既に退去済"}, "rehabilitation_certificate"=>{"99"=>"所持なし", "01"=>"最重度", "02"=>"OA", "03"=>"A1", "04"=>"1度", "05"=>"重度", "06"=>"A", "07"=>"A2", "08"=>"2度", "09"=>"中度", "10"=>"B", "11"=>"B1", "12"=>"3度", "13"=>"軽度", "14"=>"C", "15"=>"B2", "16"=>"4度"}, "sex"=>{"1"=>" 男性", "2"=>"女性", "3"=>"その他"}, "shelter_name"=>{"1"=>"石巻小学校", "2"=>"石巻中学校", "3"=>"市立体育館"}, "status"=>{""=>"指定なし", "1"=>"指定なし", "2"=>"誰かがこの人物についての情報を求めています", "3"=>"この人からの投稿メッセージがあります", "4"=>"この人が生きているという情報を入手した人がいます", "5"=>"この人を行方不明者として報告した人がいます"}, "upper_care_level_three"=>{"00"=>"該当しない", "01"=>"要支援", "02"=>"要介護1", "03"=>"要介護2", "04"=>"要介護3", "05"=>"要介護4", "06"=>"要介護5", "91"=>"みなし非該当", "92"=>"みなし要支援", "93"=>"みなし要介護"}}
  }
  let(:mock_country_code) {
    {"JP "=>"日本", "US "=>"アメリカ合衆国"}
  }
  let(:mock_person) {
    FactoryGirl.create(:person, photo_url: mock_photo_url)
  }
  let(:mock_request_mobile) { mock(Object, display:mock(Object,width:mock_request_mobile_display), default_charset:'utf-8') }
  let(:mock_request_mobile_display) { 120 }

  before {
    assign :person, mock_person
    assign :note, Note.new
    assign :person_const, mock_person_const
    assign :country_code, mock_country_code
    controller.request.stub!(:mobile).and_return(mock_request_mobile) 
  }

  subject {
    render
    rendered
  }


  context "with person(photo_url = nil)" do
    let(:mock_photo_url) { nil }
    it { should_not have_tag('img', class:'photo') }
  end


  context "with person(photo_url != nil)" do
    it { should have_tag('img', class:'photo') }
    context "with request that respond to mobile.display" do
      context "and mobile.display.width = 120" do
        let(:mock_request_mobile_display) { 120 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_small),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 174" do
        let(:mock_request_mobile_display) { 174 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_small),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 175" do
        let(:mock_request_mobile_display) { 175 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 249" do
        let(:mock_request_mobile_display) { 249 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 250" do
        let(:mock_request_mobile_display) { 250 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_large),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 499" do
        let(:mock_request_mobile_display) { 499 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_large),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 500" do
        let(:mock_request_mobile_display) { 500 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = 1000" do
        let(:mock_request_mobile_display) { 1000 }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end
      context "and mobile.display.width = nil" do
        let(:mock_request_mobile_display) { nil }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end

      context "with request that only respond to mobile.display" do
        let(:mock_request_mobile) { mock(Object, display:false, default_charset:'utf-8') }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end

      context "with request that not respond to mobile.display" do
        let(:mock_request_mobile) { nil }
        it { should have_tag('img', with: { src:mock_person.photo_url_url(:mobile_medium),
                                            style:"width: 100%; height: auto;",
                                            class:'photo'} ) }
      end

    end
  end

end
